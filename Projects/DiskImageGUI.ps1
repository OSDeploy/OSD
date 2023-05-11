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
# Assign current script directory to a global variable
$Global:MyScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

# Load presentationframework and Dlls for the MahApps.Metro theme
[System.Reflection.Assembly]::LoadWithPartialName("presentationframework") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\MahApps.Metro.dll") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\System.Windows.Interactivity.dll") | Out-Null
#================================================
#   Set PowerShell Window Title
#================================================
$host.ui.RawUI.WindowTitle = "PowerShell Start-DiskImageGUI"
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
    [xml]$Global:xmlWPF = Get-Content -Path $XamlPath

    # Add WPF and Windows Forms assemblies
    Try {
        Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase, system.windows.forms
    } 
    Catch {
        Throw "Failed to load Windows Presentation Framework assemblies."
    }

    #Create the XAML reader using a new XML node reader
    $Global:xamGUI = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $xmlWPF))

    #Create hooks to each named object in the XAML
    $xmlWPF.SelectNodes("//*[@Name]") | foreach {
        Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.Name) -Scope Global
    }
}
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'DiskImageGUI.xaml')
#================================================
#   GlobalVariables
#================================================
$Global:DiskImageGUI = @{
    BiosVersion = Get-MyBiosVersion
    AvailableDisks = Get-LocalDisk | Where-Object {$_.IsBoot -eq $false}
    Manufacturer = Get-MyComputerManufacturer -Brief
    Model = Get-MyComputerModel -Brief
    RegCurrentVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    SerialNumber = Get-MyBiosSerialNumber -Brief
    Title = 'DiskImageGUI'
    Version = Get-Module -Name OSDeploy | Sort-Object -Property Version | Select-Object -ExpandProperty Version -Last 1
}
#================================================
#   RemovedDisks
#================================================
$RemovedDisks = @()
$RemovedDisks = Get-LocalDisk | Where-Object {$_.IsBoot -eq $true}
if ($RemovedDisks) {
    foreach ($Item in $RemovedDisks) {
        Write-Warning "Removing Disk $($Item.Number) $($Item.FriendlyName) as you cannot capture or apply to a running disk"
    }
}
#================================================
#   Subtitle
#================================================
$Global:DiskImageGUI.ProductName = ($Global:DiskImageGUI.RegCurrentVersion).ProductName

if ($Global:DiskImageGUI.RegCurrentVersion.DisplayVersion -gt 0) {
    $Global:DiskImageGUI.DisplayVersion = ($Global:DiskImageGUI.RegCurrentVersion).DisplayVersion
}
else {
    $Global:DiskImageGUI.DisplayVersion = ($Global:DiskImageGUI.RegCurrentVersion).ReleaseId
}
$Global:DiskImageGUI.BuildNumber = "$($Global:DiskImageGUI.RegCurrentVersion.CurrentBuild).$($Global:DiskImageGUI.RegCurrentVersion.UBR)"
#================================================
#   Content
#================================================
$LabelTitle.Content = $Global:DiskImageGUI.Title
$LabelVersion.Content = $Global:DiskImageGUI.Version
$LabelManufacturer.Content = $Global:DiskImageGUI.Manufacturer
$LabelModel.Content = $Global:DiskImageGUI.Model
$LabelSerialNumber.Content = $Global:DiskImageGUI.SerialNumber
$LabelSubtitle.Content = "$($Global:DiskImageGUI.ProductName) $($Global:DiskImageGUI.DisplayVersion) ($($Global:DiskImageGUI.BuildNumber))"
$LabelBiosVersion.Content = "BIOS: $($Global:DiskImageGUI.BiosVersion)"
$DismDescriptionTextbox.Text = "$($Global:DiskImageGUI.Manufacturer) $($Global:DiskImageGUI.Model) $($Global:DiskImageGUI.SerialNumber)"
#================================================
#   Right Side TPM
#================================================
try {
    $TpmSpecVersion = (Get-CimInstance -Namespace "root\CIMV2\Security\MicrosoftTPM" -ClassName Win32_Tpm).SpecVersion
}
catch {}

if ($TpmSpecVersion -match '2.0') {
    $LabelTpmVersion.Content = "TPM: 2.0"
    $LabelTpmVersion.Background = "Green"
}
elseif ($TpmSpecVersion -match '1.2') {
    $LabelTpmVersion.Content = "TPM: 1.2"
    $LabelTpmVersion.Background = "Red"
}
else {
    $LabelTpmVersion.Visibility = "Collapsed"
}
#================================================
#   Hide
#================================================
function Reset-DismSource {
    $DismSourceLabel.Content = ""
    $DismSourceLabel.Visibility = "Collapsed"

    $DismSourceCombobox.Items.Clear()
    $DismSourceCombobox.Visibility = "Collapsed"
}
function Reset-DismDestination {
    $DismDestinationLabel.Content = "/ImageFile:"
    $DismDestinationLabel.Visibility = "Collapsed"

    $DismDestinationCombobox.Items.Clear()
    $DismDestinationCombobox.Visibility = "Collapsed"
}
function Reset-DismName {
    $DismNameLabel.Content = "/Name:"
    $DismNameLabel.Visibility = "Collapsed"

    $DismNameTextbox.Text = ""
    $DismNameTextbox.Visibility = "Collapsed"
}
function Reset-DismDescription {
    $DismDescriptionLabel.Content = "/Description:"
    $DismDescriptionLabel.Visibility = "Collapsed"

    $DismDescriptionTextbox.Text = ""
    $DismDescriptionTextbox.Visibility = "Collapsed"
}
function Reset-DismCompress {
    $DismCompressLabel.Content = "/Compress:"
    $DismCompressLabel.Visibility = "Collapsed"
    
    $DismCompressCombobox.Items.Clear()
    $DismCompressCombobox.Visibility = "Collapsed"
}
#================================================
#   Show
#================================================
function Show-DismSource {
    $DismSourceLabel.Visibility = "Visible"
    $DismSourceCombobox.Visibility = "Visible"
}
function Show-DismDestination {
    $DismDestinationLabel.Visibility = "Visible"
    $DismDestinationCombobox.Visibility = "Visible"
}
function Show-DismName {
    $DismNameLabel.Visibility = "Visible"
    $DismNameTextbox.Visibility = "Visible"
}
function Show-DismDescription {
    $DismDescriptionLabel.Visibility = "Visible"
    $DismDescriptionTextbox.Visibility = "Visible"
    $DismDescriptionTextbox.Text = "$($Global:DiskImageGUI.Manufacturer) $($Global:DiskImageGUI.Model) $($Global:DiskImageGUI.SerialNumber)"
}
function Show-DismCompress {
    $DismCompressLabel.Visibility = "Visible"
    $DismCompressCombobox.Visibility = "Visible"
}
#================================================
#   DismAction Defaults
#================================================
function Set-DismAction {
    $DismActionLabel.Content = "Dism.exe"

    $DismActionCombobox.Items.Clear()
    $DismActionCombobox.Items.Add('Command Line Help') | Out-Null
    $DismActionCombobox.Items.Add('/Apply-FFU') | Out-Null
    $DismActionCombobox.Items.Add('/Capture-FFU') | Out-Null
    $DismActionCombobox.SelectedIndex = "0"

    $DismCommandTextbox.Text = "Dism.exe /?"
    $StartButton.Visibility = "Visible"
}
function Reset-DismAction {
    #Write-Verbose -Verbose 'Start Reset-DismAction'
    $DismCommandTextbox.Text = "Dism.exe /?"
    $StartButton.Visibility = "Visible"

    Reset-DismSource
    Reset-DismDestination
    Reset-DismName
    Reset-DismDescription
    Reset-DismCompress
    #Write-Verbose -Verbose 'End Reset-DismAction'
}
Set-DismAction
#================================================
#   DismAction add_SelectionChanged
#================================================
$DismActionCombobox.add_SelectionChanged({
    Reset-DismAction
    Start-DismAction
})
#================================================
#   Start-DismAction
#================================================
function Start-DismAction {
    $DismCommandTextbox.Background = "#002846"
    $DismCommandTextbox.Foreground = "White"

    if ($DismActionCombobox.SelectedValue -eq 'Command Line Help') {

    }
    if ($DismActionCombobox.SelectedValue -eq '/Apply-FFU') {
        Write-Host -ForegroundColor Cyan        'Dism.exe /Apply-FFU /?'
        Write-Host -ForegroundColor DarkGray    'Applies an .ffu image'

        $DismCommandTextbox.Text = "Dism.exe /Apply-FFU /?"
        $StartButton.Visibility = "Collapsed"
        Start-SourceAction
    }
    if ($DismActionCombobox.SelectedValue -eq '/Capture-FFU') {
        Write-Host -ForegroundColor Cyan        'Dism.exe /Capture-FFU /?'
        Write-Host -ForegroundColor DarkGray    'Captures a physical disk image into a new FFU file'

        $DismCommandTextbox.Text = "Dism.exe /Capture-FFU /?"
        $StartButton.Visibility = "Collapsed"

        $DismCompressLabel.Content = "/Compress:"

        $DismCompressCombobox.Items.Clear()
        $DismCompressCombobox.Items.Add('Default') | Out-Null
        $DismCompressCombobox.Items.Add('None') | Out-Null
        $DismCompressCombobox.SelectedIndex = "0"
        
        Start-SourceAction
    }
}
#================================================
#   SourceAction
#================================================
function Start-SourceAction {
    if ($DismActionCombobox.SelectedValue -eq '/Apply-FFU') {
        $DismSourceCombobox.Items.Clear()

        if (!($Global:DiskImageGUI.AvailableDisks)) {
            $DismCommandTextbox.Background = "Pink"
            $DismCommandTextbox.Foreground = "Red"
            $DismCommandTextbox.Text = "There are no disks present that can be used as the ApplyDrive.  Make sure you are not booting to the disk that you want to Apply and try again"
            Write-Warning 'There are no disks present that can be used as the ApplyDrive'
            Write-Warning 'Make sure you are not booting to the disk that you want to Apply and try again'
        }
        else {
            $Global:ArrayOfDiskNumbers = @()
            $Global:DiskImageGUI.AvailableDisks | foreach {
                $DismSourceCombobox.Items.Add("\\.\PhysicalDrive$($_.DiskNumber) [$($_.BusType) $($_.MediaType) - $($_.FriendlyName)]") | Out-Null
                $Global:ArrayOfDiskNumbers += $_.Number
            }
            $DismSourceLabel.Content = "/ApplyDrive:"
            Show-DismSource
        }
    }
    if ($DismActionCombobox.SelectedValue -eq '/Capture-FFU') {
        $DismSourceCombobox.Items.Clear()

        if (!($Global:DiskImageGUI.AvailableDisks)) {
            $DismCommandTextbox.Background = "Pink"
            $DismCommandTextbox.Foreground = "Red"
            $DismCommandTextbox.Text = "There are no disks present that can be used as the CaptureDrive.  Make sure you are not booting to the disk that you want to Capture and try again"
            Write-Warning 'There are no disks present that can be used as the CaptureDrive'
            Write-Warning 'Make sure you are not booting to the disk that you want to Capture and try again'
        }
        else {
            $Global:ArrayOfDiskNumbers = @()
            $Global:DiskImageGUI.AvailableDisks | foreach {
                $DismSourceCombobox.Items.Add("\\.\PhysicalDrive$($_.DiskNumber) [$($_.BusType) $($_.MediaType) - $($_.FriendlyName)]") | Out-Null
                $Global:ArrayOfDiskNumbers += $_.Number
            }
            $DismSourceLabel.Content = "/CaptureDrive:"
            Show-DismSource
        }
    }
}
#================================================
#   DismSource add_SelectionChanged
#================================================
$DismSourceCombobox.add_SelectionChanged({
    Start-DestinationAction
})
#================================================
#   DismDestination Start-DestinationAction
#================================================
function Start-DestinationAction {
    $DismCommandTextbox.Background = "#002846"
    $DismCommandTextbox.Foreground = "White"

    if ($DismActionCombobox.SelectedValue -eq '/Apply-FFU') {
        #Determine the Selected Disk information
        $Global:DiskImageGUI.SourceDiskNumber = (Get-LocalDisk | Where-Object { $_.Number -eq $Global:ArrayOfDiskNumbers[$DismSourceCombobox.SelectedIndex] }).DiskNumber
        $Global:DiskImageGUI.PhysicalDrive = "\\.\PhysicalDrive$($Global:DiskImageGUI.SourceDiskNumber)"

        $DismCommandTextbox.Text = "Dism.exe /Apply-FFU /ApplyDrive:$($Global:DiskImageGUI.PhysicalDrive) /?"

        $DismDestinationCombobox.Items.Clear()

        $Global:DiskImageGUI.ApplyDrives = @()
        $Global:DiskImageGUI.ApplyDrives = Get-DataDisk | Where-Object {$_.DiskNumber -ne $($Global:DiskImageGUI.SourceDiskNumber)}

        if (!($Global:DiskImageGUI.ApplyDrives)) {
            $DismCommandTextbox.Background = "Pink"
            $DismCommandTextbox.Foreground = "Red"
            $DismCommandTextbox.Text = "There are no drives present that can contain an ImageFile.  Make sure you are not Applying on the drive that contains the ImageFile and try again"
            Write-Warning 'There are no drives present that can contain an ImageFile'
            Write-Warning 'Make sure you are not Applying on the drive that contains the ImageFile and try again'
        }
        else {
            $DismDestinationLabel.Content = "/ImageFile:"
            Show-DismDestination
            $ApplyImageFiles = @()

            foreach ($ApplyDrive in $Global:DiskImageGUI.ApplyDrives) {
                if (Test-Path "$($ApplyDrive.DriveLetter):\Images") {
                    $ApplyImageFiles += Get-ChildItem "$($ApplyDrive.DriveLetter):\Images" -Include *.ffu -File -Recurse -Force -ErrorAction Ignore | Select-Object FullName
                }
            }
    
            if ($ApplyImageFiles) {
                foreach ($Item in $ApplyImageFiles) {
                    $DismDestinationCombobox.Items.Add($Item.FullName) | Out-Null
                }
                $DismDestinationCombobox.SelectedIndex = 0
            }
            $DismDestinationCombobox.IsEditable = "True"
            Set-DismCommandApplyFFU
            $StartButton.Visibility = "Visible"
        }
    }
    if ($DismActionCombobox.SelectedValue -eq '/Capture-FFU') {
        #Determine the Selected Disk information
        $Global:DiskImageGUI.SourceDiskNumber = (Get-LocalDisk | Where-Object { $_.Number -eq $Global:ArrayOfDiskNumbers[$DismSourceCombobox.SelectedIndex] }).DiskNumber
        $Global:DiskImageGUI.PhysicalDrive = "\\.\PhysicalDrive$($Global:DiskImageGUI.SourceDiskNumber)"

        $DismCommandTextbox.Text = "Dism.exe /Capture-FFU /CaptureDrive:$($Global:DiskImageGUI.PhysicalDrive) /?"

        $DismDestinationCombobox.Items.Clear()

        $Global:DiskImageGUI.ApplyDrives = @()
        $Global:DiskImageGUI.ApplyDrives = Get-DataDisk | Where-Object {$_.DiskNumber -ne $Global:DiskImageGUI.SourceDiskNumber}

        if (!($Global:DiskImageGUI.ApplyDrives)) {
            $DismCommandTextbox.Background = "Pink"
            $DismCommandTextbox.Foreground = "Red"
            $DismCommandTextbox.Text = "There are no drives present that you can save an ImageFile on.  Insert a FAST USB Drive or map a Network Drive and try again"
            Write-Warning 'There are no drives present that you can save an ImageFile on'
            Write-Warning 'Insert a FAST USB Drive or map a Network Drive and try again'
        }
        else {
            $DismDestinationLabel.Content = "/ImageFile:"
            Show-DismDestination
            #Dism Name
            $Global:DiskImageGUI.Name = "disk$($Global:DiskImageGUI.SourceDiskNumber)"
            $DismNameTextbox.Text = $Global:DiskImageGUI.Name

            foreach ($DestinationDrive in $Global:DiskImageGUI.ApplyDrives) {
                if ($DestinationDrive.DriveLetter -gt 0) {
                    $Global:DiskImageGUI.ImageFile = "$($DestinationDrive.DriveLetter):\Images\$($Global:DiskImageGUI.Manufacturer)\$($Global:DiskImageGUI.Model)\$($Global:DiskImageGUI.SerialNumber)_$($Global:DiskImageGUI.Name).ffu"
                    $DismDestinationCombobox.Items.Add($Global:DiskImageGUI.ImageFile) | Out-Null
                }
            }
            $DismDestinationCombobox.SelectedIndex = 0
            $DismDestinationCombobox.IsEditable = "True"

            Show-DismName
            Show-DismDescription
            Show-DismCompress
            Set-DismCommandCaptureFFU
            $StartButton.Visibility = "Visible"
        }
    }
}
#================================================
#   Set-DismCommand
#================================================
function Set-DismCommandApplyFFU {
    $DismCommandTextbox.Text = "Dism.exe /Apply-FFU /ApplyDrive:$($Global:DiskImageGUI.PhysicalDrive) /ImageFile=`"$($DismDestinationCombobox.Text)`""
}
function Set-DismCommandCaptureFFU {
    $DismCommandTextbox.Text = "Dism.exe /Capture-FFU /CaptureDrive:$($Global:DiskImageGUI.PhysicalDrive) /ImageFile=`"$($DismDestinationCombobox.Text)`" /Name:`"$($DismNameTextbox.Text)`" /Description:`"$($DismDescriptionTextbox.Text)`" /Compress:$($DismCompressCombobox.SelectedValue)"
}
#================================================
#   add_SelectionChanged
#================================================
$DismDestinationCombobox.add_SelectionChanged({
    if ($DismActionCombobox.SelectedValue -eq '/Apply-FFU') {
        Set-DismCommandApplyFFU
    }
    if ($DismActionCombobox.SelectedValue -eq '/Capture-FFU') {
        Set-DismCommandCaptureFFU
    }
})
$DismDestinationCombobox.add_DropDownClosed({
    if ($DismActionCombobox.SelectedValue -eq '/Apply-FFU') {
        Set-DismCommandApplyFFU
    }
    if ($DismActionCombobox.SelectedValue -eq '/Capture-FFU') {
        Set-DismCommandCaptureFFU
    }
})
$DismDestinationCombobox.add_KeyUp({
    if ($DismActionCombobox.SelectedValue -eq '/Apply-FFU') {
        Set-DismCommandApplyFFU
    }
    if ($DismActionCombobox.SelectedValue -eq '/Capture-FFU') {
        Set-DismCommandCaptureFFU
    }
})
$DismNameTextbox.add_KeyUp({
    if ($DismActionCombobox.SelectedValue -eq '/Apply-FFU') {
        Set-DismCommandApplyFFU
    }
    if ($DismActionCombobox.SelectedValue -eq '/Capture-FFU') {
        Set-DismCommandCaptureFFU
    }
})
$DismDescriptionTextbox.add_KeyUp({
    if ($DismActionCombobox.SelectedValue -eq '/Apply-FFU') {
        Set-DismCommandApplyFFU
    }
    if ($DismActionCombobox.SelectedValue -eq '/Capture-FFU') {
        Set-DismCommandCaptureFFU
    }
})
#================================================
#   StartButton
#================================================
$StartButton.add_Click({
    #$xamGUI.Close()
    $Global:DismParams = @{}
    #================================================
    #   Command Line Help
    #================================================
    if ($DismActionCombobox.SelectedValue -eq 'Command Line Help') {
        Start-Process PowerShell.exe -ArgumentList '-NoExit','-NoLogo','Dism.exe','/?'
    }
    #================================================
    #   /Apply-FFU
    #================================================
    if ($DismActionCombobox.SelectedValue -eq '/Apply-FFU') {
        $ParentDirectory = Split-Path $DismDestinationCombobox.Text -Parent -ErrorAction Stop

        if (!(Test-Path $DismDestinationCombobox.Text)) {
            Write-Warning "ImageFile already exists.  Rename the ImageFile and try again"
        }
        elseif (!(Test-InWinPE)) {
            Write-Warning "Dism.exe /Apply-FFU requires WinPE so nothing is going to happen here"
        }
        else {
            $xamGUI.Close()
            $Global:DismParams = @{
                Dism = '/Apply-FFU'
                ApplyDrive = $Global:DiskImageGUI.PhysicalDrive
                ImageFile = $DismDestinationCombobox.Text
            }
    
            Get-OSDPower -Property High
            Start-Process PowerShell.exe -Wait -WorkingDirectory $ParentDirectory -ArgumentList '-NoExit','-NoLogo','Dism.exe','/Apply-FFU',"/ApplyDrive:'$($Global:DismParams.ApplyDrive)'","/ImageFile:'$($Global:DismParams.ImageFile)'"
            Get-OSDPower -Property Balanced
        }
    }
    #================================================
    #   /Capture-FFU
    #================================================
    if ($DismActionCombobox.SelectedValue -eq '/Capture-FFU') {
        $ParentDirectory = Split-Path $DismDestinationCombobox.Text -Parent -ErrorAction Stop
        New-Item -Path $ParentDirectory -ItemType Directory -Force -ErrorAction Ignore | Out-Null

        if (Test-Path $DismDestinationCombobox.Text) {
            Write-Warning "ImageFile already exists.  Rename the ImageFile and try again"
        }
        elseif (!(Test-Path "$ParentDirectory")) {
            Write-Warning "ImageFile appears to be in a Read Only directory or some junk path.  Try another Path"
        }
        elseif (!(Test-InWinPE)) {
            Write-Warning "Dism.exe /Capture-FFU requires WinPE so nothing is going to happen here"
        }
        else {
            $xamGUI.Close()
            $Global:DismParams = @{
                Dism = '/Capture-FFU'
                CaptureDrive = $Global:DiskImageGUI.PhysicalDrive
                ImageFile = $DismDestinationCombobox.Text
                Name = $DismNameTextbox.Text
                Description = $DismDescriptionTextbox.Text
                Compress = $DismCompressCombobox.SelectedValue
            }
    
            Get-OSDPower -Property High
            Start-Process PowerShell.exe -Wait -WorkingDirectory $ParentDirectory -ArgumentList '-NoExit','-NoLogo','Dism.exe','/Capture-FFU',"/CaptureDrive:'$($Global:DismParams.CaptureDrive)'","/ImageFile:'$($Global:DismParams.ImageFile)'","/Name:'$($Global:DismParams.Name)'","/Description:'$($Global:DismParams.Description)'","/Compress:$($Global:DismParams.Compress)"
            Get-OSDPower -Property Balanced
            
            if (Test-Path $DismDestinationCombobox.Text) {
                Get-WindowsImage -ImagePath $DismDestinationCombobox.Text -ErrorAction Ignore
            }
        }
    }
})
#================================================
#   ShowDialog
#================================================
$xamGUI.ShowDialog() | Out-Null
#================================================