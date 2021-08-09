#================================================
#   Window Functions
#   Minimize Command and PowerShell Windows
#================================================
$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
function Hide-CmdWindow() {
    $CMDProcess = Get-Process -Name cmd -ErrorAction Ignore
    foreach ($Item in $CMDProcess) {
        $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $Item.id).MainWindowHandle, 2)
    }
}
function Hide-PowershellWindow() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
}
function Show-PowershellWindow() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
}
Hide-CmdWindow
Hide-PowershellWindow
#================================================
#   Get MyScriptDir
#================================================
$Global:MyScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
#================================================
#   Load Assemblies
#================================================
[System.Reflection.Assembly]::LoadWithPartialName("presentationframework") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\System.Windows.Interactivity.dll") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\MahApps.Metro.dll") | Out-Null
#================================================
#   Set PowerShell Window Title
#================================================
#$host.ui.RawUI.WindowTitle = "OSDPad"
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
        Set-Variable -Name ($_.Name) -Value $Global:XamlWindow.FindName($_.Name) -Scope Global
    }
}
#================================================
#   LoadForm
#================================================
#LoadForm
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'OSDPad.xaml')
#================================================
#   Initialize GitHub Content
#================================================
if ($Global:OSDPad) {
    $Global:OSDPad | ForEach-Object {
        $ScriptComboBox.Items.Add($_.Path) | Out-Null
        New-Variable -Name $_.Guid -Value $($_.ContentRAW) -Force -Scope Global
    }
    $Branding.Content = "github.com/$RepoOwner/$RepoName/"
}
else {
    $Branding.Content = 'OSDPad'
}
#================================================
#   Initialize Empty Script
#================================================
$ScriptComboBox.Items.Add('New PowerShell Script.ps1') | Out-Null

if (-NOT (Get-Variable -Name 'New PowerShell Script.ps1' -Scope Global -ErrorAction Ignore)) {
    New-Variable -Name 'New PowerShell Script.ps1' -Value '#Paint on your blank canvas' -Scope Global -Force -ErrorAction Stop
}
Write-Host -ForegroundColor DarkGray "================================================"
#================================================
#   Set-OSDPadContent
#================================================
function Set-OSDPadContent {
    if ($ScriptComboBox.SelectedValue -eq 'New PowerShell Script.ps1') {
        Write-Host -ForegroundColor Cyan 'New PowerShell Script.ps1'
        $ScriptTextBox.Foreground = 'Blue'
        $ScriptTextBox.IsReadOnly = $false
        $ScriptTextBox.Text = (Get-Variable -Name 'New PowerShell Script.ps1' -Scope Global).Value
        $StartButton.Visibility = "Visible"
        $Branding.Visibility = "Collapsed"
    }
    else {
        $Branding.Visibility = "Visible"
        $Global:WorkingScript = $Global:OSDPad | Where-Object {$_.Path -eq $ScriptComboBox.SelectedValue} | Select-Object -First 1
        Write-Host -ForegroundColor Cyan $Global:WorkingScript.Path
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Git
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Download
        #Write-Host -ForegroundColor DarkCyan "Get-Variable -Name $($Global:WorkingScript.Guid)"

        $ScriptTextBox.Text = (Get-Variable -Name $Global:WorkingScript.Guid).Value

        if ($Global:WorkingScript.Name -like "*.md") {
            $ScriptTextBox.Foreground = 'Black'
            $ScriptTextBox.IsReadOnly = $true
            $StartButton.Visibility = "Collapsed"
        }
        else {
            $ScriptTextBox.Foreground = 'Blue'
            $ScriptTextBox.IsReadOnly = $false
            $StartButton.Visibility = "Visible"
        }
    }
    if ($Branding -ne 'OSDPad') {
        $Branding.Content = $Branding
    }
    foreach ($Item in $Hide) {
        if ($Item -eq 'Branding') {$Branding.Visibility = "Collapsed"}
        if ($Item -eq 'TextBox') {$ScriptTextBox.Visibility = "Collapsed"}
    }
    Write-Host -ForegroundColor DarkGray "================================================"
}

Set-OSDPadContent
#================================================
#   Change Selection
#================================================
<# $ScriptComboBox.add_SelectionChanged({
    Set-OSDPadContent
}) #>
$ScriptComboBox.add_SelectionChanged({
    Set-OSDPadContent
})
$ScriptTextBox.add_TextChanged({
    if ($ScriptComboBox.SelectedValue -eq 'New PowerShell Script.ps1') {
        Set-Variable -Name 'New PowerShell Script.ps1' -Value $($ScriptTextBox.Text) -Scope Global -Force
    }
    else {
        Set-Variable -Name $($Global:WorkingScript.Guid) -Value $($ScriptTextBox.Text) -Scope Global -Force
    }
})
#================================================
#   GO
#================================================
$StartButton.add_Click({
    Write-Host -ForegroundColor Cyan "Start-Process"
    $Global:OSDPadScriptBlock = [scriptblock]::Create($ScriptTextBox.Text)

    if ($Global:OSDPadScriptBlock) {
        if ($ScriptComboBox.SelectedValue -eq 'New PowerShell Script.ps1') {
            $ScriptFile = 'New PowerShell Script.ps1'
        }
        else {
            $ScriptFile = $Global:WorkingScript.Name
        }
        if (!(Test-Path "$env:Temp\OSDPad")) {New-Item "$env:Temp\OSDPad" -ItemType Directory}
        
        $ScriptPath = "$env:Temp\OSDPad\$ScriptFile"
        Write-Host -ForegroundColor DarkGray "Saving contents of `$Global:OSDPadScriptBlock` to $ScriptPath"
        $Global:OSDPadScriptBlock | Out-File $ScriptPath -Encoding utf8

        #$Global:XamlWindow.Close()
        #Invoke-Command $Global:OSDPadScriptBlock
        #Start-Process PowerShell.exe -ArgumentList "-NoExit Invoke-Command -ScriptBlock {$Global:OSDPadScriptBlock}"

        Write-Host -ForegroundColor DarkCyan "Start-Process -WorkingDirectory `"$env:Temp\OSDPad`" -FilePath PowerShell.exe -ArgumentList '-NoExit',`"-File `"$ScriptFile`"`""
        Start-Process -WorkingDirectory "$env:Temp\OSDPad" -FilePath PowerShell.exe -ArgumentList '-NoExit',"-File `"$ScriptFile`""
    }
    #Write-Host -ForegroundColor DarkGray "================================================"
})
#================================================
#   Customizations
#================================================
[string]$ModuleVersion = Get-Module -Name OSD | Sort-Object -Property Version | Select-Object -ExpandProperty Version -Last 1
$Global:XamlWindow.Title = "$ModuleVersion OSDPad"
#$Global:XamlWindow | Out-Host
#Get-Variable
#================================================
#   Launch
#================================================
$Global:XamlWindow.ShowDialog() | Out-Null
#================================================