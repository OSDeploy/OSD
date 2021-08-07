#================================================
#   Window Functions
#================================================
$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
function Hide-CMDWindow() {
    $CMDProcess = (Get-Process -Name cmd).id
    if ($CMDProcess) {
        $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $CMDProcess).MainWindowHandle, 2)
    }
}
Hide-CMDWindow
function Hide-PowershellWindow() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
}
function Show-PowershellWindow() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
}
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
$host.ui.RawUI.WindowTitle = "Start-OSDCloudGUI"
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
    $OSBuildComboBox.Items.Add($_) | Out-Null
}

$OSDCloudParams["OSEdition"].Attributes.ValidValues | ForEach-Object {
    $OSEditionComboBox.Items.Add($_) | Out-Null
}

$OSDCloudParams["OSLicense"].Attributes.ValidValues | ForEach-Object {
    $OSLicenseComboBox.Items.Add($_) | Out-Null
}

$OSDCloudParams["OSLanguage"].Attributes.ValidValues | ForEach-Object {
    $OSLanguageComboBox.Items.Add($_) | Out-Null
}

$ManufacturerTextBox.Text = Get-MyComputerManufacturer -Brief
$ProductTextBox.Text = Get-MyComputerProduct
$ModelTextBox.Text = Get-MyComputerModel -Brief
#================================================
#   SetDefaultValues
#================================================
function SetDefaultValues {
    $OSBuildComboBox.SelectedIndex = 0      #21H1
    $OSLanguageComboBox.SelectedIndex = 7   #en-us
    $OSEditionComboBox.SelectedIndex = 5    #Enterprise
    $OSLicenseComboBox.SelectedIndex = 1    #Volume
    $CustomImageComboBox.SelectedIndex = 0  #Nothing
    $AutopilotComboBox.SelectedIndex = 1    #OOBE
    $ImageIndexTextBox.Text = 6             #Enterprise

    $OSBuildComboBox.IsEnabled = $true
    $OSLanguageComboBox.IsEnabled = $true
    $OSEditionComboBox.IsEnabled = $true
    $OSLicenseComboBox.IsEnabled = $false
    $ImageIndexTextBox.IsEnabled = $false
    $ModelTextBox.IsEnabled = $false
    $AutopilotComboBox.IsEnabled = $true
}
SetDefaultValues
#================================================
#   CustomImage
#================================================
$CustomImageComboBox.IsEnabled = $false
$CustomImageChildItem = Find-OSDCloudFile -Name '*.wim' -Path '\OSDCloud\OS\'
$CustomImageChildItem = $CustomImageChildItem | Sort-Object -Property Length -Unique | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
        
if ($CustomImageChildItem) {
    $CustomImageComboBox.Items.Add('') | Out-Null
    $CustomImageComboBox.IsEnabled = $true
    $CustomImageChildItem | ForEach-Object {
        $CustomImageComboBox.Items.Add($_) | Out-Null
    }
    $CustomImageComboBox.SelectedIndex = 0
}
else {
    $CustomImageLabel.Visibility = "Collapsed"  
    $CustomImageComboBox.Visibility = "Collapsed"  
}
#================================================
#   AutopilotComboBox
#================================================
$AutopilotComboBox.IsEnabled = $false
$AutopilotJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Autopilot\Profiles\' | Sort-Object FullName
$AutopilotJsonChildItem = $AutopilotJsonChildItem | Where-Object {$_.FullName -notlike "C*"}
if ($AutopilotJsonChildItem) {
    $AutopilotComboBox.Items.Add('') | Out-Null
    $AutopilotComboBox.IsEnabled = $true
    $AutopilotJsonChildItem | ForEach-Object {
        $AutopilotComboBox.Items.Add($_) | Out-Null
    }
    $AutopilotComboBox.SelectedIndex = 1
}
else {
    $AutopilotLabel.Visibility = "Collapsed" 
    $AutopilotComboBox.Visibility = "Collapsed"  
}
#================================================
#   OOBEDeployComboBox
#================================================
$OOBEDeployComboBox.IsEnabled = $false
$OOBEDeployJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\OOBEDeploy\' | Sort-Object FullName
$OOBEDeployJsonChildItem = $OOBEDeployJsonChildItem | Where-Object {$_.FullName -notlike "C*"}
if ($OOBEDeployJsonChildItem) {
    $OOBEDeployComboBox.Items.Add('') | Out-Null
    $OOBEDeployComboBox.IsEnabled = $true
    $OOBEDeployJsonChildItem | ForEach-Object {
        $OOBEDeployComboBox.Items.Add($_) | Out-Null
    }
    $OOBEDeployComboBox.SelectedIndex = 1
}
else {
    $OOBEDeployLabel.Visibility = "Collapsed"  
    $OOBEDeployComboBox.Visibility = "Collapsed"  
}
#================================================
#   AutopilotOOBEComboBox
#================================================
$AutopilotOOBEComboBox.IsEnabled = $false
$AutopilotOOBEJsonChildItem = Find-OSDCloudFile -Name "*.json" -Path '\OSDCloud\Config\AutopilotOOBE\' | Sort-Object FullName
$AutopilotOOBEJsonChildItem = $AutopilotOOBEJsonChildItem | Where-Object {$_.FullName -notlike "C*"}
if ($AutopilotOOBEJsonChildItem) {
    $AutopilotOOBEComboBox.Items.Add('') | Out-Null
    $AutopilotOOBEComboBox.IsEnabled = $true
    $AutopilotOOBEJsonChildItem | ForEach-Object {
        $AutopilotOOBEComboBox.Items.Add($_) | Out-Null
    }
    $AutopilotOOBEComboBox.SelectedIndex = 1
}
else {
    $AutopilotOOBELabel.Visibility = "Collapsed"  
    $AutopilotOOBEComboBox.Visibility = "Collapsed"  
}
#================================================
#   OSEditionComboBox
#================================================
$OSEditionComboBox.add_SelectionChanged({
    #Home
    if ($OSEditionComboBox.SelectedIndex -eq 0) {
        $ImageIndexTextBox.Text = 4
        $ImageIndexLabel.IsEnabled = $false
        $ImageIndexTextBox.IsEnabled = $false   #Disable
        $OSLicenseComboBox.SelectedIndex = 0    #Retail
        $OSLicenseComboBox.IsEnabled = $false   #Disable
    }
    #Home N
    if ($OSEditionComboBox.SelectedIndex -eq 1) {
        $ImageIndexTextBox.Text = 5
        $ImageIndexTextBox.IsEnabled = $false   #Disable
        $OSLicenseComboBox.SelectedIndex = 0    #Retail
        $OSLicenseComboBox.IsEnabled = $false   #Disable
    }
    #Home Single Language
    if ($OSEditionComboBox.SelectedIndex -eq 2) {
        $ImageIndexTextBox.Text = 6
        $ImageIndexTextBox.IsEnabled = $false   #Disable
        $OSLicenseComboBox.SelectedIndex = 0    #Retail
        $OSLicenseComboBox.IsEnabled = $false   #Disable
    }
    #Education
    if ($OSEditionComboBox.SelectedIndex -eq 3) {
        $OSLicenseComboBox.IsEnabled = $true
        if ($OSLicenseComboBox.SelectedIndex -eq 0) {
            $ImageIndexTextBox.Text = 7
        }
        else {
            $ImageIndexTextBox.Text = 4
        }
    }
    #Education N
    if ($OSEditionComboBox.SelectedIndex -eq 4) {
        $OSLicenseComboBox.IsEnabled = $true
        if ($OSLicenseComboBox.SelectedIndex -eq 0) {
            $ImageIndexTextBox.Text = 8
        }
        else {
            $ImageIndexTextBox.Text = 5
        }
    }
    #Enterprise
    if ($OSEditionComboBox.SelectedIndex -eq 5) {
        $OSLicenseComboBox.SelectedIndex = 1
        $OSLicenseComboBox.IsEnabled = $false
        $ImageIndexTextBox.Text = 6
    }
    #Enterprise N
    if ($OSEditionComboBox.SelectedIndex -eq 6) {
        $OSLicenseComboBox.SelectedIndex = 1
        $OSLicenseComboBox.IsEnabled = $false
        $ImageIndexTextBox.Text = 7
    }
    #Pro
    if ($OSEditionComboBox.SelectedIndex -eq 7) {
        $OSLicenseComboBox.IsEnabled = $true
        if ($OSLicenseComboBox.SelectedIndex -eq 0) {
            $ImageIndexTextBox.Text = 9
        }
        else {
            $ImageIndexTextBox.Text = 8
        }
    }
    #Pro N
    if ($OSEditionComboBox.SelectedIndex -eq 8) {
        $OSLicenseComboBox.IsEnabled = $true
        if ($OSLicenseComboBox.SelectedIndex -eq 0) {
            $ImageIndexTextBox.Text = 10
        }
        else {
            $ImageIndexTextBox.Text = 9
        }
    }
})
#================================================
#   OSLicenseComboBox
#================================================
$OSLicenseComboBox.add_SelectionChanged({
    if ($OSLicenseComboBox.SelectedIndex -eq 0) {
        if ($OSEditionComboBox.SelectedIndex -eq 3) {$ImageIndexTextBox.Text = 7}
        if ($OSEditionComboBox.SelectedIndex -eq 4) {$ImageIndexTextBox.Text = 8}
        if ($OSEditionComboBox.SelectedIndex -eq 7) {$ImageIndexTextBox.Text = 9}
        if ($OSEditionComboBox.SelectedIndex -eq 8) {$ImageIndexTextBox.Text = 10}
    }
    if ($OSLicenseComboBox.SelectedIndex -eq 1) {
        if ($OSEditionComboBox.SelectedIndex -eq 3) {$ImageIndexTextBox.Text = 4}
        if ($OSEditionComboBox.SelectedIndex -eq 4) {$ImageIndexTextBox.Text = 5}
        if ($OSEditionComboBox.SelectedIndex -eq 7) {$ImageIndexTextBox.Text = 8}
        if ($OSEditionComboBox.SelectedIndex -eq 8) {$ImageIndexTextBox.Text = 9}
    }
})
#================================================
#   CustomImageComboBox
#================================================
$CustomImageComboBox.add_SelectionChanged({
    if ($CustomImageComboBox.SelectedIndex -eq 0) {
        SetDefaultValues
    }
    else {
        $OSBuildComboBox.IsEnabled = $false
        $OSLanguageComboBox.IsEnabled = $false
        $OSEditionComboBox.IsEnabled = $false
        $OSLicenseComboBox.IsEnabled = $false
        $ImageIndexTextBox.IsEnabled = $true
        $ImageIndexTextBox.Text = 1
    }
})
#================================================
#   GoButton
#================================================
$GoButton.add_Click({
    $Global:XamlWindow.Close()
    Show-PowershellWindow
    #================================================
    #   Variables
    #================================================
    $OSImageIndex = $ImageIndexTextBox.Text
    $OSBuild = $OSBuildComboBox.SelectedItem
    $OSEdition = $OSEditionComboBox.SelectedItem
    $OSLanguage = $OSLanguageComboBox.SelectedItem
    $OSLicense = $OSLicenseComboBox.SelectedItem
    #================================================
    #   AutopilotJson
    #================================================
    $AutopilotJsonName = $AutopilotComboBox.SelectedValue
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
    $OOBEDeployJsonName = $OOBEDeployComboBox.SelectedValue
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
    $AutopilotOOBEJsonName = $AutopilotOOBEComboBox.SelectedValue
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
    $ImageFileFullName = $CustomImageComboBox.SelectedValue
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
        Manufacturer                = $ManufacturerTextBox.Text
        OOBEDeployJsonChildItem     = $OOBEDeployJsonChildItem
        OOBEDeployJsonItem          = $OOBEDeployJsonItem
        OOBEDeployJsonName          = $OOBEDeployJsonName
        OOBEDeployJsonObject        = $OOBEDeployJsonObject
        OSBuild                     = $OSBuild
        OSEdition                   = $OSEdition
        OSImageIndex                = $OSImageIndex
        OSLanguage                  = $OSLanguage
        OSLicense                   = $OSLicense
        Product                     = $ProductTextBox.Text
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
#$Global:XamlWindow | Out-Host
#================================================
#   Launch
#================================================
$Global:XamlWindow.ShowDialog() | Out-Null
#================================================