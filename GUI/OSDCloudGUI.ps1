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
#   Load Assemblies
#================================================
$Global:MyScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
[System.Reflection.Assembly]::LoadWithPartialName("presentationframework") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\System.Windows.Interactivity.dll") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\MahApps.Metro.dll") | Out-Null
#================================================
#   Set PowerShell Window Title
#================================================
#$host.ui.RawUI.WindowTitle = "Start-OSDCloudGUI"
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
    param(
        [Parameter(Mandatory = $false, Position = 1)]
        [string]$XamlPath
    )

    # Import the XAML code
    [xml]$Global:XamlCode = Get-Content -Path $XamlPath

    Try {
        Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
    } 
    Catch {
        Throw "Failed to load Windows Presentation Framework assemblies."
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
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'OSDCloudGUI.xaml')
#================================================
#   Initialize
#================================================
$OSDCloudParams = (Get-Command Start-OSDCloud).Parameters

$OSDCloudParams["OSBuild"].Attributes.ValidValues | ForEach-Object {
    $OSBuildControl.Items.Add($_) | Out-Null
}

$OSDCloudParams["OSEdition"].Attributes.ValidValues | ForEach-Object {
    $OSEditionControl.Items.Add($_) | Out-Null
}

$OSDCloudParams["OSLicense"].Attributes.ValidValues | ForEach-Object {
    $OSLicenseControl.Items.Add($_) | Out-Null
}

$OSDCloudParams["OSLanguage"].Attributes.ValidValues | ForEach-Object {
    $OSLanguageControl.Items.Add($_) | Out-Null
}

$CSManufacturerControl.Text = Get-MyComputerManufacturer -Brief
$CSProductControl.Text = Get-MyComputerProduct
$CSModelControl.Text = Get-MyComputerModel -Brief
#================================================
#   SetDefaultValues
#================================================
function SetDefaultValues {
    $OSBuildControl.SelectedIndex = 0      #21H1
    $OSLanguageControl.SelectedIndex = 7   #en-us
    $OSEditionControl.SelectedIndex = 5    #Enterprise
    $OSLicenseControl.SelectedIndex = 1    #Volume
    $CustomImageControl.SelectedIndex = 0  #Nothing
    $AutopilotJsonControl.SelectedIndex = 1    #OOBE
    $ImageIndexControl.Text = 6             #Enterprise

    $OSBuildControl.IsEnabled = $true
    $OSLanguageControl.IsEnabled = $true
    $OSEditionControl.IsEnabled = $true
    $OSLicenseControl.IsEnabled = $false
    $ImageIndexControl.IsEnabled = $false
    $CSModelControl.IsEnabled = $false
    $AutopilotJsonControl.IsEnabled = $true
}
SetDefaultValues
#================================================
#   CustomImage
#================================================
$CustomImageControl.IsEnabled = $false
$CustomImageChildItem = Find-OSDCloudFile -Name '*.wim' -Path '\OSDCloud\OS\'
$CustomImageChildItem = $CustomImageChildItem | Sort-Object -Property Length -Unique | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
        
if ($CustomImageChildItem) {
    $CustomImageControl.Items.Add('') | Out-Null
    $CustomImageControl.IsEnabled = $true
    $CustomImageChildItem | ForEach-Object {
        $CustomImageControl.Items.Add($_) | Out-Null
    }
    $CustomImageControl.SelectedIndex = 0
}
else {
    $CustomImageLabel.Visibility = "Collapsed"  
    $CustomImageControl.Visibility = "Collapsed"  
}
#================================================
#   AutopilotJsonControl
#================================================
$AutopilotJsonControl.IsEnabled = $false
$AutopilotJsonChildItem = @()
[array]$AutopilotJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
[array]$AutopilotJsonChildItem += Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\AutopilotJSON\' | Sort-Object FullName
$AutopilotJsonChildItem = $AutopilotJsonChildItem | Where-Object {$_.FullName -notlike "C*"}
if ($AutopilotJsonChildItem) {
    $AutopilotJsonControl.Items.Add('') | Out-Null
    $AutopilotJsonControl.IsEnabled = $true
    $AutopilotJsonChildItem | ForEach-Object {
        $AutopilotJsonControl.Items.Add($_) | Out-Null
    }
    $AutopilotJsonControl.SelectedIndex = 1
}
else {
    $AutopilotJsonLabel.Visibility = "Collapsed" 
    $AutopilotJsonControl.Visibility = "Collapsed"  
}
#================================================
#   OOBEDeployControl
#================================================
$OOBEDeployControl.IsEnabled = $false
$OOBEDeployJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\OOBEDeploy\' | Sort-Object FullName
$OOBEDeployJsonChildItem = $OOBEDeployJsonChildItem | Where-Object {$_.FullName -notlike "C*"}
if ($OOBEDeployJsonChildItem) {
    $OOBEDeployControl.Items.Add('') | Out-Null
    $OOBEDeployControl.IsEnabled = $true
    $OOBEDeployJsonChildItem | ForEach-Object {
        $OOBEDeployControl.Items.Add($_) | Out-Null
    }
    $OOBEDeployControl.SelectedIndex = 1
}
else {
    $OOBEDeployLabel.Visibility = "Collapsed"  
    $OOBEDeployControl.Visibility = "Collapsed"  
}
#================================================
#   AutopilotOOBEControl
#================================================
$AutopilotOOBEControl.IsEnabled = $false
$AutopilotOOBEJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\AutopilotOOBE\' | Sort-Object FullName
$AutopilotOOBEJsonChildItem = $AutopilotOOBEJsonChildItem | Where-Object {$_.FullName -notlike "C*"}
if ($AutopilotOOBEJsonChildItem) {
    $AutopilotOOBEControl.Items.Add('') | Out-Null
    $AutopilotOOBEControl.IsEnabled = $true
    $AutopilotOOBEJsonChildItem | ForEach-Object {
        $AutopilotOOBEControl.Items.Add($_) | Out-Null
    }
    $AutopilotOOBEControl.SelectedIndex = 1
}
else {
    $AutopilotOOBELabel.Visibility = "Collapsed"  
    $AutopilotOOBEControl.Visibility = "Collapsed"  
}
#================================================
#   OSEditionControl
#================================================
$OSEditionControl.add_SelectionChanged({
    #Home
    if ($OSEditionControl.SelectedIndex -eq 0) {
        $ImageIndexControl.Text = 4
        $ImageIndexLabel.IsEnabled = $false
        $ImageIndexControl.IsEnabled = $false   #Disable
        $OSLicenseControl.SelectedIndex = 0    #Retail
        $OSLicenseControl.IsEnabled = $false   #Disable
    }
    #Home N
    if ($OSEditionControl.SelectedIndex -eq 1) {
        $ImageIndexControl.Text = 5
        $ImageIndexControl.IsEnabled = $false   #Disable
        $OSLicenseControl.SelectedIndex = 0    #Retail
        $OSLicenseControl.IsEnabled = $false   #Disable
    }
    #Home Single Language
    if ($OSEditionControl.SelectedIndex -eq 2) {
        $ImageIndexControl.Text = 6
        $ImageIndexControl.IsEnabled = $false   #Disable
        $OSLicenseControl.SelectedIndex = 0    #Retail
        $OSLicenseControl.IsEnabled = $false   #Disable
    }
    #Education
    if ($OSEditionControl.SelectedIndex -eq 3) {
        $OSLicenseControl.IsEnabled = $true
        if ($OSLicenseControl.SelectedIndex -eq 0) {
            $ImageIndexControl.Text = 7
        }
        else {
            $ImageIndexControl.Text = 4
        }
    }
    #Education N
    if ($OSEditionControl.SelectedIndex -eq 4) {
        $OSLicenseControl.IsEnabled = $true
        if ($OSLicenseControl.SelectedIndex -eq 0) {
            $ImageIndexControl.Text = 8
        }
        else {
            $ImageIndexControl.Text = 5
        }
    }
    #Enterprise
    if ($OSEditionControl.SelectedIndex -eq 5) {
        $OSLicenseControl.SelectedIndex = 1
        $OSLicenseControl.IsEnabled = $false
        $ImageIndexControl.Text = 6
    }
    #Enterprise N
    if ($OSEditionControl.SelectedIndex -eq 6) {
        $OSLicenseControl.SelectedIndex = 1
        $OSLicenseControl.IsEnabled = $false
        $ImageIndexControl.Text = 7
    }
    #Pro
    if ($OSEditionControl.SelectedIndex -eq 7) {
        $OSLicenseControl.IsEnabled = $true
        if ($OSLicenseControl.SelectedIndex -eq 0) {
            $ImageIndexControl.Text = 9
        }
        else {
            $ImageIndexControl.Text = 8
        }
    }
    #Pro N
    if ($OSEditionControl.SelectedIndex -eq 8) {
        $OSLicenseControl.IsEnabled = $true
        if ($OSLicenseControl.SelectedIndex -eq 0) {
            $ImageIndexControl.Text = 10
        }
        else {
            $ImageIndexControl.Text = 9
        }
    }
})
#================================================
#   OSLicenseControl
#================================================
$OSLicenseControl.add_SelectionChanged({
    if ($OSLicenseControl.SelectedIndex -eq 0) {
        if ($OSEditionControl.SelectedIndex -eq 3) {$ImageIndexControl.Text = 7}
        if ($OSEditionControl.SelectedIndex -eq 4) {$ImageIndexControl.Text = 8}
        if ($OSEditionControl.SelectedIndex -eq 7) {$ImageIndexControl.Text = 9}
        if ($OSEditionControl.SelectedIndex -eq 8) {$ImageIndexControl.Text = 10}
    }
    if ($OSLicenseControl.SelectedIndex -eq 1) {
        if ($OSEditionControl.SelectedIndex -eq 3) {$ImageIndexControl.Text = 4}
        if ($OSEditionControl.SelectedIndex -eq 4) {$ImageIndexControl.Text = 5}
        if ($OSEditionControl.SelectedIndex -eq 7) {$ImageIndexControl.Text = 8}
        if ($OSEditionControl.SelectedIndex -eq 8) {$ImageIndexControl.Text = 9}
    }
})
#================================================
#   CustomImageControl
#================================================
$CustomImageControl.add_SelectionChanged({
    if ($CustomImageControl.SelectedIndex -eq 0) {
        SetDefaultValues
    }
    else {
        $OSBuildControl.IsEnabled = $false
        $OSLanguageControl.IsEnabled = $false
        $OSEditionControl.IsEnabled = $false
        $OSLicenseControl.IsEnabled = $false
        $ImageIndexControl.IsEnabled = $true
        $ImageIndexControl.Text = 1
    }
})
#================================================
#   StartButtonControl
#================================================
$StartButtonControl.add_Click({
    $Global:XamlWindow.Close()
    Show-PowershellWindow
    #================================================
    #   Variables
    #================================================
    $OSImageIndex = $ImageIndexControl.Text
    $OSBuild = $OSBuildControl.SelectedItem
    $OSEdition = $OSEditionControl.SelectedItem
    $OSLanguage = $OSLanguageControl.SelectedItem
    $OSLicense = $OSLicenseControl.SelectedItem
    #================================================
    #   AutopilotJson
    #================================================
    $AutopilotJsonName = $AutopilotJsonControl.SelectedValue
    if ($AutopilotJsonName) {
        $AutopilotJsonItem = $AutopilotJsonChildItem | Where-Object {$_.FullName -eq "$AutopilotJsonName"}
    }
    else {
        $SkipAutopilot = $true
        $AutopilotJsonName = $null
        $AutopilotJsonItem = $null
    }
    if ($AutopilotJsonItem) {
        $AutopilotJsonObject = Get-Content -Raw $AutopilotJsonItem.FullName | ConvertFrom-Json
        $SkipAutopilot = $false
    }
    else {
        $SkipAutopilot = $true
        $AutopilotJsonObject = $null
    }
    #================================================
    #   OOBEDeployJson
    #================================================
    $OOBEDeployJsonName = $OOBEDeployControl.SelectedValue
    if ($OOBEDeployJsonName) {
        $OOBEDeployJsonItem = $OOBEDeployJsonChildItem | Where-Object {$_.FullName -eq "$OOBEDeployJsonName"}
    }
    else {
        $SkipOOBEDeploy = $true
        $OOBEDeployJsonName = $null
        $OOBEDeployJsonItem = $null
    }
    if ($OOBEDeployJsonItem) {
        $OOBEDeployJsonObject = Get-Content -Raw $OOBEDeployJsonItem.FullName | ConvertFrom-Json
        $SkipOOBEDeploy = $false
    }
    else {
        $SkipOOBEDeploy = $true
        $OOBEDeployJsonObject = $null
    }
    #================================================
    #   AutopilotOOBEJson
    #================================================
    $AutopilotOOBEJsonName = $AutopilotOOBEControl.SelectedValue
    if ($AutopilotOOBEJsonName) {
        $AutopilotOOBEJsonItem = $AutopilotOOBEJsonChildItem | Where-Object {$_.FullName -eq "$AutopilotOOBEJsonName"}
    }
    else {
        $SkipAutopilotOOBE = $true
        $AutopilotOOBEJsonName = $null
        $AutopilotOOBEJsonItem = $null
    }
    if ($AutopilotOOBEJsonItem) {
        $AutopilotOOBEJsonObject = Get-Content -Raw $AutopilotOOBEJsonItem.FullName | ConvertFrom-Json
        $SkipAutopilotOOBE = $false
    }
    else {
        $SkipAutopilotOOBE = $true
        $AutopilotOOBEJsonObject = $null
    }
    #================================================
    #   ImageFile
    #================================================
    $ImageFileFullName = $CustomImageControl.SelectedValue
    if ($ImageFileFullName) {
        $ImageFileItem = $CustomImageChildItem | Where-Object {$_.FullName -eq "$ImageFileFullName"}
        $ImageFileName = Split-Path -Path $ImageFileItem.FullName -Leaf
        $OSBuild = $null
        $OSEdition = $null
        $OSLanguage = $null
        $OSLicense = $null
    }
    else {
        $ImageFileItem = $null
        $ImageFileFullName = $null
        $ImageFileName = $null
    }
    #================================================
    #   Global Variables
    #================================================
    $Global:StartOSDCloudGUI = $null
    $Global:StartOSDCloudGUI = [ordered]@{
        AutopilotJsonChildItem      = $AutopilotJsonChildItem
        AutopilotJsonItem           = $AutopilotJsonItem
        AutopilotJsonName           = $AutopilotJsonName
        AutopilotJsonObject         = $AutopilotJsonObject
        AutopilotOOBEJsonChildItem  = $AutopilotOOBEJsonChildItem
        AutopilotOOBEJsonItem       = $AutopilotOOBEJsonItem
        AutopilotOOBEJsonName       = $AutopilotOOBEJsonName
        AutopilotOOBEJsonObject     = $AutopilotOOBEJsonObject
        ImageFileFullName           = $ImageFileFullName
        ImageFileItem               = $ImageFileItem
        ImageFileName               = $ImageFileName
        Manufacturer                = $CSManufacturerControl.Text
        OOBEDeployJsonChildItem     = $OOBEDeployJsonChildItem
        OOBEDeployJsonItem          = $OOBEDeployJsonItem
        OOBEDeployJsonName          = $OOBEDeployJsonName
        OOBEDeployJsonObject        = $OOBEDeployJsonObject
        OSBuild                     = $OSBuild
        OSEdition                   = $OSEdition
        OSImageIndex                = $OSImageIndex
        OSLanguage                  = $OSLanguage
        OSLicense                   = $OSLicense
        Product                     = $CSProductControl.Text
        Restart                     = $RestartCheckbox.IsChecked
        SkipAutopilot               = $SkipAutopilot
        SkipAutopilotOOBE           = $SkipAutopilotOOBE
        SkipODT                     = $true
        SkipOOBEDeploy              = $SkipOOBEDeploy
        ZTI                         = $ZTICheckbox.IsChecked
    }
    #$Global:StartOSDCloudGUI | Out-Host
    if ($ScreenshotCheckbox.IsChecked) {
        $Params = @{
            Screenshot = $true
        }
        Start-OSDCloud @Params
    }
    else {
        Start-OSDCloud 
    }
})
#================================================
#   Customizations
#================================================
[string]$ModuleVersion = Get-Module -Name OSD | Sort-Object -Property Version | Select-Object -ExpandProperty Version -Last 1
$Global:XamlWindow.Title = "$ModuleVersion Start-OSDCloudGUI"
if ($Global:OSDCloudGuiBranding) {
    $TitleBranding.Content = $Global:OSDCloudGuiBranding.Branding
    $TitleBranding.Foreground = $Global:OSDCloudGuiBranding.Color
}
#$Global:XamlWindow | Out-Host
#================================================
#   Launch
#================================================
$Global:XamlWindow.ShowDialog() | Out-Null
#================================================