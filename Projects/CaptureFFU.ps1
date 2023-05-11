#=======================================================================
#   Clear Screen
#=======================================================================
#Clear-Host
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
#$host.ui.RawUI.WindowTitle = "Start-CaptureFFU"
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
#   Title
#=======================================================================
$TitleLabel.Content = 'Start-CaptureFFU'
#=======================================================================
#   Variables
#=======================================================================
$Global:Manufacturer = Get-MyComputerManufacturer -Brief
$Global:Model = Get-MyComputerModel -Brief
$Global:SerialNumber = Get-MyBiosSerialNumber -Brief

$Global:DismDescription = "$Global:Manufacturer $Global:Model $Global:SerialNumber"
Write-Host -ForegroundColor Cyan "Description:$Global:DismDescription"

$Global:DismCompress = 'Default'
Write-Host -ForegroundColor Cyan "Compress:$Global:DismCompress"
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
$Global:CaptureDrives = Get-LocalDisk | Where-Object {$_.IsBoot -eq $false}

# Populate the ComboBox
$Global:CaptureDrives | foreach {
    $CaptureDriveComboBox.Items.Add("Disk $($_.DiskNumber) $($_.BusType) $($_.MediaType) - $($_.FriendlyName)") | Out-Null
    $Global:ArrayOfDiskNumbers += $_.Number
}

$CaptureDriveDetails.Content = ''

#Select the first item
$CaptureDriveComboBox.SelectedIndex = 0
#=======================================================================
#   Set-CaptureDriveComboBox
#=======================================================================
function Set-CaptureDriveComboBox {
    $CaptureDrive = Get-LocalDisk | Where-Object { $_.Number -eq $Global:ArrayOfDiskNumbers[$CaptureDriveComboBox.SelectedIndex] }
    
    # Work out if the size should be in GB or TB
    if ([math]::Round(($CaptureDrive.Size/1TB),2) -lt 1) {
        $CaptureDriveSize = "$([math]::Round(($CaptureDrive.Size/1000000000),0))GB"
    }
    else {
        $CaptureDriveSize = "$([math]::Round(($CaptureDrive.Size/1000000000000),2))TB"
    }

    $Global:DiskNumber = $CaptureDrive.DiskNumber

    $Global:DismCaptureDrive = "\\.\PhysicalDrive$($Global:DiskNumber)"
    Write-Host -ForegroundColor Cyan "CaptureDrive: $Global:DismCaptureDrive"
    
    $Global:DismName = "disk$($Global:DiskNumber)"
    Write-Host -ForegroundColor Cyan "Name: $Global:DismName"

$CaptureDriveDetails.Content = @"
$CaptureDriveSize $($CaptureDrive.PartitionStyle) $($CaptureDrive.NumberOfPartitions) Partitions
"@
}
#=======================================================================
#   Set-ImageFileComboBox
#=======================================================================
function Set-ImageFileComboBox {

    $Global:DestinationDrives = @()
    $Global:DestinationDrives = Get-DataDisk | Where-Object {$_.DiskNumber -ne $Global:DiskNumber}

    $ImageFile = $null
    
    $ImageFileComboBox.Items.Clear()

    if (-NOT ($Global:DestinationDrives)) {
        $ImageFileComboBox.IsEnabled = "False"
        $RunButton.IsEnabled = "False"
    }
    else {
        $RunButton.IsEnabled = "True"
        foreach ($DestinationDrive in $Global:DestinationDrives) {
            if ($DestinationDrive.DriveLetter -gt 0) {
                $ImageFileName = "disk$Global:DiskNumber"
                $ImageFile = "$($DestinationDrive.DriveLetter):\CaptureFFU\$Global:Manufacturer\$Global:Model\$($Global:SerialNumber)_$($ImageFileName).ffu"
                $ImageFileComboBox.Items.Add($ImageFile) | Out-Null
            }
        }
        $ImageFileComboBox.SelectedIndex = 0
    }
}
#=======================================================================
#   Set-DismCommandText
#=======================================================================
function Set-DismCommandText {
    #Write-Host "Text: $($ImageFileComboBox.Text)"

    $Global:DismImageFile = $ImageFileComboBox.Text
    if ($Global:DismImageFile -gt 0) {
        Write-Host -ForegroundColor Cyan "ImageFile: $Global:DismImageFile"
    }
    $DismCommand.Text = "Dism.exe /Capture-FFU /ImageFile=`"$Global:DismImageFile`" /CaptureDrive=$Global:DismCaptureDrive /Name:`"$Global:DismName`" /Description:`"$Global:DismDescription`" /Compress:$Global:DismCompress"
    
    $ImageFileComboBox.IsEnabled = "True"
}
Set-CaptureDriveComboBox
Set-ImageFileComboBox
Set-DismCommandText
<# $DestinationDetails.Content = @"
DiskNumber: $($DestinationDrive.DiskNumber)
FileSystemLabel: $($DestinationDrive.FileSystemLabel)
FileSystem: $($DestinationDrive.FileSystem)
Size: $($DestinationDrive.Size)
SizeRemaining: $($DestinationDrive.SizeRemaining)
"@ #>
#=======================================================================
#   CaptureDriveComboBox Events
#=======================================================================
$CaptureDriveComboBox.add_SelectionChanged({
    Set-CaptureDriveComboBox
    Set-ImageFileComboBox
    Set-DismCommandText
})
$CaptureDriveComboBox.add_DropDownClosed({
    Set-CaptureDriveComboBox
    Set-ImageFileComboBox
    Set-DismCommandText
})
#=======================================================================
#   ImageFileComboBox Events
#=======================================================================
$ImageFileComboBox.add_SelectionChanged({
    #Write-Host -ForegroundColor Magenta "add_SelectionChanged"
    Set-DismCommandText
})
$ImageFileComboBox.add_DropDownClosed({
    #Write-Host -ForegroundColor Magenta "add_DropDownClosed"
    Set-DismCommandText
})
$ImageFileComboBox.add_IsKeyboardFocusedChanged({
    #Write-Host -ForegroundColor Magenta "add_IsKeyboardFocusedChanged"
    Set-DismCommandText
})
$ImageFileComboBox.add_IsKeyboardFocusWithinChanged({
    #Write-Host -ForegroundColor Magenta "add_IsKeyboardFocusWithinChanged"
    Set-DismCommandText
})
$ImageFileComboBox.add_KeyUp({
    #Write-Host -ForegroundColor Magenta "add_KeyUp"
    Set-DismCommandText
})
#=======================================================================
#   RunButton
#=======================================================================
$RunButton.add_Click({

    if ($null -eq $Global:DismImageFile) {
        Write-Warning "DismImageFile value is null"
    }
    elseif ($Global:DismImageFile -eq '') {
        Write-Warning "DismImageFile value is nothing"
    }
    else {
        $ParentDirectory = Split-Path $Global:DismImageFile -Parent -ErrorAction Stop
        
        Write-Host "Dism.exe /Capture-FFU /ImageFile=`"$Global:DismImageFile`" /CaptureDrive=$Global:DismCaptureDrive /Name:`"$Global:DismName`" /Description:`"$Global:DismDescription`" /Compress:$Global:DismCompress"

        $xamGUI.Close()
        Show-Powershell
        #=======================================================================
        #   Checks
        #=======================================================================
        if (Test-Path $Global:DismImageFile) {
            Write-Warning "ImageFile already exists.  Rename the ImageFile and try again"; Break
        }
        if (-NOT (Test-InWinPE)) {
            Write-Warning "CaptureFFU must be run in WinPE"
            Break
        }
        #=======================================================================
        #   Create FFU
        #=======================================================================
        if (!(Test-Path "$ParentDirectory")) {
            Try {New-Item -Path $ParentDirectory -ItemType Directory -Force -ErrorAction Stop}
            Catch {Write-Warning "Destination appears to be Read Only.  Try another Destination Drive"; Break}
        }

        $CommandLine = "Dism.exe /Capture-FFU /ImageFile=`"$Global:DismImageFile`" /CaptureDrive=$Global:DismCaptureDrive /Name:`"$Global:DismName`" /Description:`"$Global:DismDescription`" /Compress:$Global:DismCompress"
        Write-Host "CommandLine: $CommandLine"
        Get-OSDPower -Property High
        Start-Process PowerShell.exe -Wait -WorkingDirectory $ParentDirectory -ArgumentList '-NoExit','-NoLogo','Dism.exe','/Capture-FFU',"/ImageFile='$Global:DismImageFile'","/CaptureDrive='$Global:DismCaptureDrive'","/Name:'$Global:DismName'","/Description:'$Global:DismDescription'","/Compress:$Global:DismCompress"
        Get-OSDPower -Property Balanced
        if (Test-Path $Global:DismImageFile) {
            Get-WindowsImage -ImagePath $Global:DismImageFile
        }
        #=======================================================================
    }
})
#=======================================================================
#   ShowDialog
#=======================================================================
$xamGUI.ShowDialog() | Out-Null
#=======================================================================