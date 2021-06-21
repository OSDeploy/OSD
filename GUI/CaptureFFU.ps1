#=======================================================================
#   Clear Screen
#=======================================================================
#Clear-Host
#=======================================================================
#	Block
#=======================================================================
Block-StandardUser
Block-WindowsVersionNe10
Block-PowerShellVersionLt5
#=======================================================================
#   PowershellWindow Functions
#   Hide the PowerShell Window
#   https://community.spiceworks.com/topic/1710213-hide-a-powershell-console-window-when-running-a-script
#=======================================================================
$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
function Show-Powershell() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
}
function Hide-Powershell() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
}
#Hide-Powershell
#=======================================================================
#   MahApps.Metro
#=======================================================================
# Assign current script directory to a global variable
$Global:MyScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

# Load presentationframework and Dlls for the MahApps.Metro theme
[System.Reflection.Assembly]::LoadWithPartialName("presentationframework") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\System.Windows.Interactivity.dll") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$Global:MyScriptDir\assembly\MahApps.Metro.dll") | Out-Null
#=======================================================================
#   Console Title
#=======================================================================
#$host.ui.RawUI.WindowTitle = "CaptureFFU"
#=======================================================================
#   Test-InWinPE
#=======================================================================
function Test-InWinPE {
    return Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT
}
#=======================================================================
#   LoadForm
#=======================================================================
function LoadForm {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$XamlPath
    )
    
    # Import the XAML code
    [xml]$Global:xmlWPF = Get-Content -Path $XamlPath

    # Add WPF and Windows Forms assemblies
    try {
        Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
    } 
    catch {
        throw "Failed to load Windows Presentation Framework assemblies."
    }

    #Create the XAML reader using a new XML node reader
    $Global:xamGUI = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $xmlWPF))

    #Create hooks to each named object in the XAML
    $xmlWPF.SelectNodes("//*[@Name]") | ForEach {
        Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.Name) -Scope Global
    }
}
#=======================================================================
#   LoadForm
#=======================================================================
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'CaptureFFU.xaml')
#=======================================================================
#   Variables
#=======================================================================
$Global:Manufacturer = Get-MyComputerManufacturer -Brief
$Global:Model = Get-MyComputerModel -Brief
$Global:SerialNumber = Get-MyBiosSerialNumber -Brief
#=======================================================================
#   Title
#=======================================================================
#$TitleLabel.Content = 'CaptureFFU'
#=======================================================================
#   CaptureDrives
#=======================================================================
# Create empty array of hard disk numbers
$Global:ArrayOfDiskNumbers = @()

#Get all the CaptureDrives
$Global:CaptureDrives = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false}

# Populate the ComboBox
$Global:CaptureDrives | foreach {
    $CaptureDriveComboBox.Items.Add($_.FriendlyName) | Out-Null
    $Global:ArrayOfDiskNumbers += $_.Number
}

$CaptureDriveDetails.Content = ''

#Select the first item
$CaptureDriveComboBox.SelectedIndex = 0
#=======================================================================
#   Get-CaptureDriveDetails
#=======================================================================
function Get-CaptureDriveDetails {
    $CaptureDrive = Get-Disk.fixed | Where-Object { $_.Number -eq $Global:ArrayOfDiskNumbers[$CaptureDriveComboBox.SelectedIndex] }
    
    # Work out if the size should be in GB or TB
    if ([math]::Round(($CaptureDrive.Size/1TB),2) -lt 1) {
        $CaptureDriveSize = "$([math]::Round(($CaptureDrive.Size/1000000000),0)) GB"
    }
    else {
        $CaptureDriveSize = "$([math]::Round(($CaptureDrive.Size/1000000000000),2)) TB"
    }

    $Global:DiskNumber = $CaptureDrive.DiskNumber

$CaptureDriveDetails.Content = @"
BusType: $($CaptureDrive.BusType)
MediaType: $($CaptureDrive.MediaType)
Size: $CaptureDriveSize
DiskNumber: $Global:DiskNumber
NumberOfPartitions: $($CaptureDrive.NumberOfPartitions)
PartitionStyle: $($CaptureDrive.PartitionStyle)
"@

    Get-StorageDriveDetails
}
#=======================================================================
#   Get-StorageDriveDetails
#=======================================================================
function Get-StorageDriveDetails {
    $Global:DestinationDrives = @()
    $Global:DestinationDrives = Get-Disk.storage | Where-Object {$_.DiskNumber -ne $Global:DiskNumber}

    $ImageFile = $null

    if (-NOT ($Global:DestinationDrives)) {
        $ImageFileComboBox.IsEnabled = "False"
    }
    else {
        foreach ($DestinationDrive in $Global:DestinationDrives) {
            if ($DestinationDrive.DriveLetter -gt 0) {
                $ImageFileName = "disk$Global:DiskNumber"
                $ImageFile = "$($DestinationDrive.DriveLetter):\BackupFFU\$Global:Manufacturer\$Global:Model\$($Global:SerialNumber)_$($ImageFileName).ffu"
                $ImageFileComboBox.Items.Add($ImageFile) | Out-Null
            }
        }
        $ImageFileComboBox.SelectedIndex = 0
    }
}

<# $DestinationDetails.Content = @"
DiskNumber: $($DestinationDrive.DiskNumber)
FileSystemLabel: $($DestinationDrive.FileSystemLabel)
FileSystem: $($DestinationDrive.FileSystem)
Size: $($DestinationDrive.Size)
SizeRemaining: $($DestinationDrive.SizeRemaining)
"@ #>

Get-CaptureDriveDetails
#=======================================================================
#   CaptureDriveComboBox
#=======================================================================
$CaptureDriveComboBox.add_SelectionChanged({
    Get-CaptureDriveDetails
    $ImageFileComboBox.Items.Clear()
    Get-StorageDriveDetails
})
#=======================================================================
#   GoButton
#=======================================================================
$GoButton.add_Click({

    $DismImageFile = $ImageFileComboBox.Text
    Write-Host -ForegroundColor Cyan "DismImageFile: $DismImageFile"
    $ParentDirectory = Split-Path $DismImageFile -Parent

    $DismCaptureDrive = "\\.\PhysicalDrive$($Global:DiskNumber)"
    Write-Host -ForegroundColor Cyan "DismCaptureDrive: $DismCaptureDrive"

    $DismName = "disk$($Global:DiskNumber)"
    Write-Host -ForegroundColor Cyan "DismName: $DismName"

    $DismDescription = "$Global:Manufacturer $Global:Model $Global:SerialNumber"
    Write-Host -ForegroundColor Cyan "DismDescription: $DismDescription"

    $DismCompress = 'Default'
    Write-Host -ForegroundColor Cyan "DismCompress: $DismCompress"
    
    Write-Host "DISM.exe /Capture-FFU /ImageFile=`"$DismImageFile`" /CaptureDrive=$DismCaptureDrive /Name:`"$DismName`" /Description:`"$DismDescription`" /Compress:$DismCompress"

    if ($null -eq $DismImageFile) {
        #Do nothing
    }
    else {
        $xamGUI.Close()
        Show-Powershell
        #=======================================================================
        #   Verify WinPE
        #=======================================================================
        if (-NOT (Test-InWinPE)) {
            Write-Warning "CaptureFFU must be run in WinPE"
            PAUSE
            Break
        }
        #=======================================================================
        #   Enable High Performance Power Plan
        #=======================================================================
        Get-OSDPower -Property High
        #=======================================================================
        if (!(Test-Path "$ParentDirectory")) {
            Try {New-Item -Path $ParentDirectory -ItemType Directory -Force -ErrorAction Stop}
            Catch {Write-Warning "Destination appears to be Read Only.  Try another Destination Drive"; Break}
        }
        DISM.exe /Capture-FFU /ImageFile="$DismImageFile" /CaptureDrive=$DismCaptureDrive /Name:"$DismName" /Description:"$DismDescription" /Compress:$DismCompress
        #Get-WindowsImage -ImagePath $ImageFile
        #=======================================================================
    }
})
#=======================================================================
#   ShowDialog
#=======================================================================
$xamGUI.ShowDialog() | Out-Null
#=======================================================================