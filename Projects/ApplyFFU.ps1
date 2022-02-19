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
#$host.ui.RawUI.WindowTitle = "Start-ApplyFFU"
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
LoadForm -XamlPath (Join-Path $Global:MyScriptDir 'ApplyFFU.xaml')
#=======================================================================
#   Title
#=======================================================================
$TitleLabel.Content = 'Start-ApplyFFU'
#=======================================================================
#   ApplyDrives
#=======================================================================
# Create empty array of hard disk numbers
$Global:ArrayOfDiskNumbers = @()

#Get all the ApplyDrives
$Global:ApplyDrives = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false}

# Populate the ComboBox
$Global:ApplyDrives | foreach {
    $ApplyDriveComboBox.Items.Add("Disk $($_.DiskNumber) $($_.BusType) $($_.MediaType) - $($_.FriendlyName)") | Out-Null
    $Global:ArrayOfDiskNumbers += $_.Number
}

$ApplyDriveDetails.Content = ''

#Select the first item
$ApplyDriveComboBox.SelectedIndex = 0
#=======================================================================
#   Set-ApplyDriveComboBox
#=======================================================================
function Set-ApplyDriveComboBox {
    $ApplyDrive = Get-Disk.fixed | Where-Object { $_.Number -eq $Global:ArrayOfDiskNumbers[$ApplyDriveComboBox.SelectedIndex] }
    
    # Work out if the size should be in GB or TB
    if ([math]::Round(($ApplyDrive.Size/1TB),2) -lt 1) {
        $ApplyDriveSize = "$([math]::Round(($ApplyDrive.Size/1000000000),0))GB"
    }
    else {
        $ApplyDriveSize = "$([math]::Round(($ApplyDrive.Size/1000000000000),2))TB"
    }

    $Global:DiskNumber = $ApplyDrive.DiskNumber

    $Global:DismApplyDrive = "\\.\PhysicalDrive$($Global:DiskNumber)"
    Write-Host -ForegroundColor Cyan "ApplyDrive: $Global:DismApplyDrive"
    
    $Global:DismName = "disk$($Global:DiskNumber)"
    Write-Host -ForegroundColor Cyan "Name: $Global:DismName"

$ApplyDriveDetails.Content = @"
$ApplyDriveSize $($ApplyDrive.PartitionStyle) $($ApplyDrive.NumberOfPartitions) Partitions
"@
}
#=======================================================================
#   Set-ImageFileComboBox
#=======================================================================
function Set-ImageFileComboBox {

    $Global:DestinationDrives = @()
    $Global:DestinationDrives = Get-Disk.storage | Where-Object {$_.DiskNumber -ne $Global:DiskNumber}

    $ImageFileComboBox.Items.Clear()

    $ImageFiles = @()

    if (-NOT ($Global:DestinationDrives)) {
        $ImageFileComboBox.IsEnabled = "False"
    }
    else {
        foreach ($DestinationDrive in $Global:DestinationDrives) {
            if (Test-Path "$($DestinationDrive.DriveLetter):\CaptureFFU") {
                $ImageFiles += Get-ChildItem "$($DestinationDrive.DriveLetter):\CaptureFFU" -Include *.ffu -File -Recurse -Force -ErrorAction Ignore | Select-Object -ExpandProperty FullName
            }
        }

        if ($ImageFiles) {
            foreach ($Item in $ImageFiles) {
                $ImageFileComboBox.Items.Add($Item) | Out-Null
            }
            $ImageFileComboBox.SelectedIndex = 0
        }
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
    $DismCommand.Text = "Dism.exe /Apply-FFU /ImageFile=`"$Global:DismImageFile`" /ApplyDrive=$Global:DismApplyDrive"
    
    $ImageFileComboBox.IsEnabled = "True"
}
Set-ApplyDriveComboBox
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
#   ApplyDriveComboBox Events
#=======================================================================
$ApplyDriveComboBox.add_SelectionChanged({
    Set-ApplyDriveComboBox
    Set-ImageFileComboBox
    Set-DismCommandText
})
$ApplyDriveComboBox.add_DropDownClosed({
    Set-ApplyDriveComboBox
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
        
        Write-Host "Dism.exe /Apply-FFU /ImageFile=`"$Global:DismImageFile`" /ApplyDrive=$Global:DismApplyDrive"

        $xamGUI.Close()
        Show-Powershell
        #=======================================================================
        #   Checks
        #=======================================================================
        if (-NOT (Test-InWinPE)) {
            Write-Warning "ApplyFFU must be run in WinPE"
            Break
        }
        #=======================================================================
        #   Create FFU
        #=======================================================================
        $CommandLine = "Dism.exe /Apply-FFU /ImageFile=`"$Global:DismImageFile`" /ApplyDrive=$Global:DismApplyDrive"
        Write-Host "CommandLine: $CommandLine"
        Get-OSDPower -Property High
        Start-Process PowerShell.exe -Wait -WorkingDirectory $ParentDirectory -ArgumentList '-NoExit','-NoLogo','Dism.exe','/Apply-FFU',"/ImageFile='$Global:DismImageFile'","/ApplyDrive='$Global:DismApplyDrive'"
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