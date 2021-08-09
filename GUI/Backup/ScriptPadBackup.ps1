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
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'ScriptRepo.xaml')
#================================================
#   Initialize
#================================================
if ($Global:ScriptRepo) {
    $Global:ScriptRepo | ForEach-Object {
        $ComboBoxRepoName.Items.Add($_.Path) | Out-Null
        New-Variable -Name $_.Guid -Value $($_.ContentRAW) -Force -Scope Global
    }
    $LabelTitle.Content = "GitHub $($Global:ScriptRepo.Owner[0]) $($Global:ScriptRepo.Repo[0])"
}
else {
    $LabelTitle.Content = ''
}
$ComboBoxRepoName.Items.Add('New PowerShell Script.ps1') | Out-Null
if (-NOT (Get-Variable -Name 'New PowerShell Script.ps1' -Scope Global -ErrorAction Ignore)) {
    New-Variable -Name 'New PowerShell Script.ps1' -Value '#Blank PowerShell Script' -Scope Global -Force -ErrorAction Stop
}
$LabelScriptRepoDescription.Content = 'New PowerShell Script.ps1 is a blank PowerShell Script that you can edit and Start-Process'
Write-Host -ForegroundColor DarkGray "================================================"
#================================================
#   Set-ScriptRepoContent
#================================================
function Set-ScriptRepoContent {
    if ($ComboBoxRepoName.SelectedValue -eq 'New PowerShell Script.ps1') {
        Write-Host -ForegroundColor Cyan 'New PowerShell Script.ps1'
        $TextBoxScriptRepoContent.Text = (Get-Variable -Name 'New PowerShell Script.ps1' -Scope Global).Value
        $LabelScriptRepoDescription.Content = 'New PowerShell Script.ps1 is a blank PowerShell Script that you can edit and Start-Process'
        $TextBoxScriptRepoContent.IsReadOnly = $false
        $GoButton.Visibility = "Visible"
    }
    else {
        $Global:WorkingScript = $Global:ScriptRepo | Where-Object {$_.Path -eq $ComboBoxRepoName.SelectedValue} | Select-Object -First 1
        Write-Host -ForegroundColor Cyan $Global:WorkingScript.Path
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Git
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Download
        #Write-Host -ForegroundColor DarkCyan "Get-Variable -Name $($Global:WorkingScript.Guid)"

        $LabelScriptRepoDescription.Content = $Global:WorkingScript.Guid
        $TextBoxScriptRepoContent.Text = (Get-Variable -Name $Global:WorkingScript.Guid).Value

        if ($Global:WorkingScript.Name -match 'README.md') {
            $TextBoxScriptRepoContent.IsReadOnly = $true
            $GoButton.Visibility = "Collapsed"
        }
        else {
            $TextBoxScriptRepoContent.IsReadOnly = $false
            $GoButton.Visibility = "Visible"
        }
    }
    Write-Host -ForegroundColor DarkGray "================================================"
}

Set-ScriptRepoContent
#================================================
#   Change Selection
#================================================
<# $ComboBoxRepoName.add_SelectionChanged({
    Set-ScriptRepoContent
}) #>
$ComboBoxRepoName.add_SelectionChanged({
    Set-ScriptRepoContent
})
$TextBoxScriptRepoContent.add_TextChanged({
    if ($ComboBoxRepoName.SelectedValue -eq 'New PowerShell Script.ps1') {
        Set-Variable -Name 'New PowerShell Script.ps1' -Value $($TextBoxScriptRepoContent.Text) -Scope Global -Force
    }
    else {
        Set-Variable -Name $($Global:WorkingScript.Guid) -Value $($TextBoxScriptRepoContent.Text) -Scope Global -Force
    }
})
#================================================
#   GO
#================================================
$GoButton.add_Click({
    Write-Host -ForegroundColor Cyan "Start-Process"
    $Global:ScriptRepoScriptBlock = [scriptblock]::Create($TextBoxScriptRepoContent.Text)

    if ($Global:ScriptRepoScriptBlock) {
        if ($ComboBoxRepoName.SelectedValue -eq 'New PowerShell Script.ps1') {
            $ScriptFile = 'New PowerShell Script.ps1'
        }
        else {
            $ScriptFile = $Global:WorkingScript.Name
        }
        if (!(Test-Path "$env:Temp\ScriptRepo")) {New-Item "$env:Temp\ScriptRepo" -ItemType Directory}
        
        $ScriptPath = "$env:Temp\ScriptRepo\$ScriptFile"
        Write-Host -ForegroundColor DarkGray "Saving contents of `$Global:ScriptRepoScriptBlock` to $ScriptPath"
        $Global:ScriptRepoScriptBlock | Out-File $ScriptPath -Encoding utf8

        #$XamlWindow.Close()
        #Invoke-Command $Global:ScriptRepoScriptBlock
        #Start-Process PowerShell.exe -ArgumentList "-NoExit Invoke-Command -ScriptBlock {$Global:ScriptRepoScriptBlock}"

        Write-Host -ForegroundColor DarkCyan "Start-Process -WorkingDirectory `"$env:Temp\ScriptRepo`" -FilePath PowerShell.exe -ArgumentList '-NoExit',`"-File `"$ScriptFile`"`""
        Start-Process -WorkingDirectory "$env:Temp\ScriptRepo" -FilePath PowerShell.exe -ArgumentList '-NoExit',"-File `"$ScriptFile`""
    }
    #Write-Host -ForegroundColor DarkGray "================================================"
})
#================================================
#   Launch
#================================================
$XamlWindow.ShowDialog() | Out-Null
#================================================