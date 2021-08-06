#================================================
#   PowershellWindow Functions
#================================================
$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
function Show-PowershellWindow() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
}
function Hide-PowershellWindow() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
}
#Hide-PowershellWindow
#================================================
#   Load Assemblies
#================================================
$Global:MyScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
[System.Reflection.Assembly]::LoadWithPartialName("presentationframework") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\System.Windows.Interactivity.dll") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\MahApps.Metro.dll") | Out-Null
#================================================
#   Set PowerShell Window Title
#================================================
$host.ui.RawUI.WindowTitle = ""
#================================================
#   Test-InWinPE
#================================================
function Test-InWinPE {
    return Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT
}
#================================================
#   LoadForm
#================================================
function LoadForm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False, Position = 1)]
        [string]$XamlPath
    )
    
    # Import the XAML code
    [xml]$Global:XamlCode = Get-Content -Path $XamlPath

    # Add WPF and Windows Forms assemblies
    try {
        Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
    } 
    catch {
        throw "Failed to load Windows Presentation Framework assemblies."
    }

    #Create the XAML reader using a new XML node reader
    $Global:XamlWindow = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $Global:XamlCode))

    #Create hooks to each named object in the XAML
    $Global:XamlCode.SelectNodes("//*[@Name]") | ForEach-Object {
        Set-Variable -Name ($_.Name) -Value $XamlWindow.FindName($_.Name) -Scope Global
    }
}
#================================================
#   LoadForm
#================================================
#LoadForm
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'Git2PS.xaml')
#================================================
#   Initialize
#================================================
if ($Global:Git2PS) {
    $Global:Git2PS | ForEach-Object {
        $ComboBoxGit2PSName.Items.Add($_.Path) | Out-Null
        New-Variable -Name $_.Guid -Value $($_.ContentRAW) -Force -Scope Global
    }
    $LabelTitle.Content = "GitHub $($Global:Git2PS.GitOwner[0]) $($Global:Git2PS.GitRepo[0])"
}
else {
    $LabelTitle.Content = ''
}
$ComboBoxGit2PSName.Items.Add('NewScript.ps1') | Out-Null
if (-NOT (Get-Variable -Name 'NewScript.ps1' -Scope Global -ErrorAction Ignore)) {
    New-Variable -Name 'NewScript.ps1' -Value '#Blank PowerShell Script' -Scope Global -Force -ErrorAction Stop
}
$LabelGit2PSDescription.Content = 'NewScript.ps1 is a blank PowerShell Script that you can edit and Start-Process'
Write-Host -ForegroundColor DarkGray "================================================"
#================================================
#   Set-Git2PSContent
#================================================
function Set-Git2PSContent {
    if ($ComboBoxGit2PSName.SelectedValue -eq 'NewScript.ps1') {
        Write-Host -ForegroundColor Cyan 'NewScript.ps1'
        $TextBoxGit2PSContent.Text = (Get-Variable -Name 'NewScript.ps1' -Scope Global).Value
        $LabelGit2PSDescription.Content = 'NewScript.ps1 is a blank PowerShell Script that you can edit and Start-Process'
        $TextBoxGit2PSContent.IsReadOnly = $false
        $GoButton.Visibility = "Visible"
    }
    else {
        $Global:WorkingScript = $Global:Git2PS | Where-Object {$_.Path -eq $ComboBoxGit2PSName.SelectedValue} | Select-Object -First 1
        Write-Host -ForegroundColor Cyan $Global:WorkingScript.Path
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Git
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Download
        #Write-Host -ForegroundColor DarkCyan "Get-Variable -Name $($Global:WorkingScript.Guid)"

        $LabelGit2PSDescription.Content = $Global:WorkingScript.Guid
        $TextBoxGit2PSContent.Text = (Get-Variable -Name $Global:WorkingScript.Guid).Value

        if ($Global:WorkingScript.Name -match 'README.md') {
            $TextBoxGit2PSContent.IsReadOnly = $true
            $GoButton.Visibility = "Collapsed"
        }
        else {
            $TextBoxGit2PSContent.IsReadOnly = $false
            $GoButton.Visibility = "Visible"
        }
    }
    Write-Host -ForegroundColor DarkGray "================================================"
}

Set-Git2PSContent
#================================================
#   Change Selection
#================================================
<# $ComboBoxGit2PSName.add_SelectionChanged({
    Set-Git2PSContent
}) #>
$ComboBoxGit2PSName.add_SelectionChanged({
    Set-Git2PSContent
})
$TextBoxGit2PSContent.add_TextChanged({
    if ($ComboBoxGit2PSName.SelectedValue -eq 'NewScript.ps1') {
        Set-Variable -Name 'NewScript.ps1' -Value $($TextBoxGit2PSContent.Text) -Scope Global -Force
    }
    else {
        Set-Variable -Name $($Global:WorkingScript.Guid) -Value $($TextBoxGit2PSContent.Text) -Scope Global -Force
    }
})
#================================================
#   GO
#================================================
$GoButton.add_Click({
    Write-Host -ForegroundColor Cyan "Start-Process"
    $Global:Git2PSScriptBlock = [scriptblock]::Create($TextBoxGit2PSContent.Text)

    if ($Global:Git2PSScriptBlock) {
        if ($ComboBoxGit2PSName.SelectedValue -eq 'NewScript.ps1') {
            $ScriptFile = 'NewScript.ps1'
        }
        else {
            $ScriptFile = $Global:WorkingScript.Name
        }
        if (!(Test-Path "$env:Temp\Git2PS")) {New-Item "$env:Temp\Git2PS" -ItemType Directory}
        
        $ScriptPath = "$env:Temp\Git2PS\$ScriptFile"
        Write-Host -ForegroundColor DarkGray "Saving contents of `$Global:Git2PSScriptBlock` to $ScriptPath"
        $Global:Git2PSScriptBlock | Out-File $ScriptPath -Encoding utf8

        #$XamlWindow.Close()
        #Invoke-Command $Global:Git2PSScriptBlock
        #Start-Process PowerShell.exe -ArgumentList "-NoExit Invoke-Command -ScriptBlock {$Global:Git2PSScriptBlock}"

        Write-Host -ForegroundColor DarkCyan "Start-Process -WorkingDirectory `"$env:Temp\Git2PS`" -FilePath PowerShell.exe -ArgumentList '-NoExit',`"-File `"$ScriptFile`"`""
        Start-Process -WorkingDirectory "$env:Temp\Git2PS" -FilePath PowerShell.exe -ArgumentList '-NoExit',"-File `"$ScriptFile`""
    }
    #Write-Host -ForegroundColor DarkGray "================================================"
})
#================================================
#   Launch
#================================================
$XamlWindow.ShowDialog() | Out-Null
#================================================