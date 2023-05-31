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
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'OSDPad.xaml')
#================================================
#   Initialize Script Selection
#================================================
if ($Global:OSDPad) {
    $Global:OSDPad | ForEach-Object {
        $ScriptSelectionControl.Items.Add($_.Path) | Out-Null
        New-Variable -Name $_.Guid -Value $($_.ContentRAW) -Force -Scope Global

        if ($_.Path -like "*Readme.md") {
            $ScriptSelectionControl.SelectedValue = $_.Path
        }
        if ($Global:OSDPadBranding.Title -eq 'OSDPad') {
            switch ($RepoType) {
                'GitHub' {
                    $Global:OSDPadBranding.Title = "github.com/$RepoOwner/$RepoName/"
                }
                'GitLab' {
                    $Global:OSDPadBranding.Title = "$RepoDomain/$RepoName/"
                }
            }
        }
    }
}
#================================================
#   Initialize Empty Script
#================================================
$ScriptSelectionControl.Items.Add('New PowerShell Script.ps1') | Out-Null

if (-NOT (Get-Variable -Name 'New PowerShell Script.ps1' -Scope Global -ErrorAction Ignore)) {
    New-Variable -Name 'New PowerShell Script.ps1' -Value '#This script is empty' -Scope Global -Force -ErrorAction Stop
}
Write-Host -ForegroundColor DarkGray "========================================================================="
#================================================
#   Set-OSDPadContent
#================================================
function Set-OSDPadContent {
    if ($ScriptSelectionControl.SelectedValue -eq 'New PowerShell Script.ps1') {
        Write-Host -ForegroundColor Cyan 'New PowerShell Script.ps1'
        $ScriptTextControl.Foreground = 'Blue'
        $ScriptTextControl.IsReadOnly = $false
        $ScriptTextControl.Text = (Get-Variable -Name 'New PowerShell Script.ps1' -Scope Global).Value
        $StartButtonControl.Visibility = "Visible"
        $BrandingTitleControl.Content = 'OSDPad'
        #$BrandingTitleControl.Visibility = "Collapsed"
    }
    else {
        #$BrandingTitleControl.Visibility = "Visible"
        $Global:WorkingScript = $Global:OSDPad | Where-Object {$_.Path -eq $ScriptSelectionControl.SelectedValue} | Select-Object -First 1
        Write-Host -ForegroundColor Cyan $Global:WorkingScript.Path
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Git
        Write-Host -ForegroundColor DarkGray $Global:WorkingScript.Download
        #Write-Host -ForegroundColor DarkCyan "Get-Variable -Name $($Global:WorkingScript.Guid)"

        $ScriptTextControl.Text = (Get-Variable -Name $Global:WorkingScript.Guid).Value

        if ($Global:WorkingScript.Name -like "*.md") {
            $ScriptTextControl.Foreground = 'Black'
            $ScriptTextControl.IsReadOnly = $true
            $StartButtonControl.Visibility = "Collapsed"
        }
        else {
            $ScriptTextControl.Foreground = 'Blue'
            $ScriptTextControl.IsReadOnly = $false
            $StartButtonControl.Visibility = "Visible"
        }
        $BrandingTitleControl.Content = $Global:OSDPadBranding.Title
    }
    foreach ($Item in $Hide) {
        if ($Item -eq 'Branding') {$BrandingTitleControl.Visibility = "Collapsed"}
        if ($Item -eq 'Script') {
            $Global:XamlWindow.Height="140"
            $ScriptTextControl.Visibility = "Collapsed"
        }
    }
    Write-Host -ForegroundColor DarkGray "========================================================================="
}

Set-OSDPadContent
#================================================
#   Change Selection
#================================================
<# $ScriptSelectionControl.add_SelectionChanged({
    Set-OSDPadContent
}) #>
$ScriptSelectionControl.add_SelectionChanged({
    Set-OSDPadContent
})
$ScriptTextControl.add_TextChanged({
    if ($ScriptSelectionControl.SelectedValue -eq 'New PowerShell Script.ps1') {
        Set-Variable -Name 'New PowerShell Script.ps1' -Value $($ScriptTextControl.Text) -Scope Global -Force
    }
    else {
        Set-Variable -Name $($Global:WorkingScript.Guid) -Value $($ScriptTextControl.Text) -Scope Global -Force
    }
})
#================================================
#   GO
#================================================
$StartButtonControl.add_Click({
    Write-Host -ForegroundColor Cyan "Start-Process"
    $Global:OSDPadScriptBlock = [scriptblock]::Create($ScriptTextControl.Text)

    if ($Global:OSDPadScriptBlock) {
       if ($ScriptSelectionControl.SelectedValue -like "*#Requires -PSEdition Core*")  {
            Write-Host -ForegroundColor DarkCyan "PowerShell Core detected"
            $global:PwshCore = $true
        }
       
        if ($ScriptSelectionControl.SelectedValue -eq 'New PowerShell Script.ps1') {
            $ScriptFile = 'New PowerShell Script.ps1'
        }
        else {
            $ScriptFile = $Global:WorkingScript.Name
        }
        if (!(Test-Path "$env:Temp\OSDPad")) {New-Item "$env:Temp\OSDPad" -ItemType Directory}
        
        $ScriptPath = "$env:Temp\OSDPad\$ScriptFile"
        Write-Host -ForegroundColor DarkGray "Saving contents of `$Global:OSDPadScriptBlock` to $ScriptPath"
        $Global:OSDPadScriptBlock | Out-File $ScriptPath -Encoding utf8 -Width 2000 -Force

        #$Global:XamlWindow.Close()
        #Invoke-Command $Global:OSDPadScriptBlock
        #Start-Process PowerShell.exe -ArgumentList "-NoExit Invoke-Command -ScriptBlock {$Global:OSDPadScriptBlock}"

        if ($global:PwshCore -eq $true) {
            Write-Host -ForegroundColor DarkCyan "Start-Process -WorkingDirectory `"$env:Temp\OSDPad`" -FilePath pwsh.exe -ArgumentList '-NoLogo -NoExit',`"-File `"$ScriptFile`"`""
            Start-Process -WorkingDirectory "$env:Temp\OSDPad" -FilePath pwsh.exe -ArgumentList '-NoLogo -NoExit',"-File `"$ScriptFile`"" -Wait
        }
        else {
            Write-Host -ForegroundColor DarkCyan "Start-Process -WorkingDirectory `"$env:Temp\OSDPad`" -FilePath PowerShell.exe -ArgumentList '-NoLogo -NoExit',`"-File `"$ScriptFile`"`""
            Start-Process -WorkingDirectory "$env:Temp\OSDPad" -FilePath PowerShell.exe -ArgumentList '-NoLogo -NoExit',"-File `"$ScriptFile`"" -Wait
        }
        #Write-Host -ForegroundColor DarkCyan "Start-Process -WorkingDirectory `"$env:Temp\OSDPad`" -FilePath PowerShell.exe -ArgumentList '-NoLogo -NoExit',`"-File `"$ScriptFile`"`""
        #Start-Process -WorkingDirectory "$env:Temp\OSDPad" -FilePath PowerShell.exe -ArgumentList '-NoLogo -NoExit',"-File `"$ScriptFile`""
    }
    #Write-Host -ForegroundColor DarkGray "========================================================================="
})
#================================================
#   Customizations
#================================================
[string]$ModuleVersion = Get-Module -Name OSD | Sort-Object -Property Version | Select-Object -ExpandProperty Version -Last 1
$Global:XamlWindow.Title = "$ModuleVersion OSDPad"
#================================================
#   Branding
#================================================
if ($Global:OSDPadBranding) {
    $BrandingTitleControl.Content = $Global:OSDPadBranding.Title
    $BrandingTitleControl.Foreground = $Global:OSDPadBranding.Color
}
#================================================
#   Launch
#================================================
$Global:XamlWindow.ShowDialog() | Out-Null
#================================================