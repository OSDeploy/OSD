<#
.SYNOPSIS
Saves a Drive as Full Flash Update Windows Image (FFU)

.DESCRIPTION
Saves a Drive as Full Flash Update Windows Image (FFU)

.LINK
https://osd.osdeploy.com/module/functions/backup/backup-disktoffu
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/deploy-windows-using-full-flash-update--ffu

.NOTES
21.1.27    Initial Release
#>
function Backup-DiskToFFU {
    [CmdletBinding()]
    Param (
        #Disk Number of the Drive to capture
        #Use Get-Disk to get the DiskNumber Property
        [Alias('Number')]
        [ValidateScript({$_ -in (Get-DiskToBackup | Select-Object -ExpandProperty DiskNumber)})]
        [int] $DiskNumber = (Get-DiskToBackup | Select-Object -ExpandProperty DiskNumber -First 1),

        [ValidateScript({$_ -in (Get-DriveForBackupFile | Where-Object {$_.DiskNumber -ne $DiskNumber} | Select-Object -ExpandProperty DriveLetter)})]
        [string] $DestinationDriveLetter = "$(Get-DriveForBackupFile | Where-Object {$_.DiskNumber -ne $DiskNumber} | Select-Object -ExpandProperty DriveLetter -First 1)",
        
        #Windows Image Property: Specifies the name of an image
        [string] $Name = "disk$DiskNumber",

        #Full path to save the Windows Image
        [Alias('ImagePath')]
        [string] $ImageFile = "$($DestinationDriveLetter):\BackupFFU\$(Get-MyComputerManufacturer -Brief)\$(Get-MyComputerModel -Brief)\$(Get-MyBiosSerialNumber -Brief)_$Name.ffu",

        #Windows Image Property: Specifies the description of the image
        [string] $Description = "$(Get-MyComputerManufacturer -Brief) $(Get-MyComputerModel -Brief) $(Get-MyBiosSerialNumber -Brief)",

        #Compression level.  Default or None
        [ValidateSet('Default','None')]
        [string] $Compress = 'Default',

        #Executes the capture
        [switch] $Force
    )
    #======================================================================================================
    #	Enable Verbose
    #======================================================================================================
    if ($Force -eq $false) {$VerbosePreference = 'Continue'}
    #======================================================================================================
    #	Gather
    #======================================================================================================
    $GetCommandNoun = Get-Command -Name Backup-DiskToFFU | Select-Object -ExpandProperty Noun
    $GetCommandVersion = Get-Command -Name Backup-DiskToFFU | Select-Object -ExpandProperty Version
    $GetCommandHelpUri = Get-Command -Name Backup-DiskToFFU | Select-Object -ExpandProperty HelpUri
    $GetCommandModule = Get-Command -Name Backup-DiskToFFU | Select-Object -ExpandProperty Module
    $GetModuleDescription = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty Description
    $GetModuleProjectUri = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty ProjectUri
    $GetModulePath = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty Path

    $GetDriveForBackupFile = $(Get-DriveForBackupFile)
    $DiskIsBoot = $(Get-DiskIsBoot)
    $DiskToBackup = $(Get-DiskToBackup)
    $Volumes = $(Get-Volume)
    #======================================================================================================
    #	Validate
    #======================================================================================================
    if ($ImageFile -like ":*") {
        $ImageFile = "C$ImageFile"
    }
    #======================================================================================================
    #	Usage
    #======================================================================================================
    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    Write-Host -ForegroundColor White       "Backup-DiskToFFU " -NoNewline
    Write-Host -ForegroundColor Cyan        "$GetCommandVersion $GetModulePath"
    Write-Host -ForegroundColor DarkCyan    $GetCommandHelpUri
    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    Write-Host -ForegroundColor Yellow       "The following Partitions will be saved in the FFU:"
    foreach ($item in (Get-Partition | Where-Object {$_.DiskNumber -eq $DiskNumber})) {
        Write-Host -ForegroundColor White "DiskNumber:$($item.DiskNumber) Partition:$($item.PartitionNumber) DriveLetter:$($item.DriveLetter) Type:$($item.Type) $([math]::round($item.Size / 1000000000, 0)) GB"
    }
    
    if ($DiskToBackup -or $DiskIsBoot) {
        Write-Host -ForegroundColor DarkGray    '======================================================================================================'
        Write-Host -ForegroundColor Cyan        "-DiskNumber $DiskNumber"
        Write-Host -ForegroundColor White       "The Disk Number of the Disk to capture as an FFU. The default is the first available Disk"
        foreach ($item in $DiskToBackup) {
            Write-Host -ForegroundColor Cyan    "$($item.DiskNumber) " -NoNewline
            Write-Host -ForegroundColor Gray    "$($item.PartitionStyle) Partitions:$($item.NumberOfPartitions) $($item.FriendlyName) $($item.BusType) [$([math]::round($item.Size / 1000000000, 0))GB]"
        }
        if ($DiskIsBoot) {
            Write-Warning "Disks from a running OS cannot be selected"
            foreach ($item in $DiskIsBoot) {
                Write-Host -ForegroundColor Red "$($item.DiskNumber) $($item.PartitionStyle) Partitions:$($item.NumberOfPartitions) $($item.FriendlyName) $($item.BusType) [$([math]::round($item.Size / 1000000000, 0))GB]"
            }
        }
    }

    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    Write-Host -ForegroundColor Cyan        "-DestinationDriveLetter $DestinationDriveLetter"

    if ($GetDriveForBackupFile | Where-Object {$_.DiskNumber -ne $DiskNumber}) {
        Write-Host -ForegroundColor White   "Verify that the Drive you select below has plenty of space for your image"
        foreach ($item in ($GetDriveForBackupFile | Where-Object {$_.DiskNumber -ne $DiskNumber})) {
            Write-Host -ForegroundColor Cyan    "$($item.DriveLetter) " -NoNewline
            Write-Host -ForegroundColor Gray    "$($item.FileSystem) $($item.FileSystemLabel) [$($item.DriveType) TotalSize:$([math]::round($item.Size / 1000000000, 0))GB SizeRemaining:$([math]::round($item.SizeRemaining / 1000000000, 0))GB]"
        }
        foreach ($item in ($GetDriveForBackupFile | Where-Object {$_.DiskNumber -eq $DiskNumber})) {
            Write-Warning "Volumes that are being captured cannot be used as a Destination Drive"
            Write-Host -ForegroundColor Red    "$($item.DriveLetter) $($item.FileSystem) $($item.FileSystemLabel) [$($item.DriveType) TotalSize:$([math]::round($item.Size / 1000000000, 0))GB SizeRemaining:$([math]::round($item.SizeRemaining / 1000000000, 0))GB]"
        }
    } else {
        Write-Warning "Could not find any drives that you can backup to"
        Break
    }
    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    Write-Host -ForegroundColor Cyan        "-ImageFile  $ImageFile"
    Write-Host -ForegroundColor White       'This path is generated automatically by combining the DestinationDriveLetter, CimComputerManufacturer,'
    Write-Host -ForegroundColor White       'ComputerModel SerialNumber and DiskNumber.  You can fully modify this path to override the'
    Write-Host -ForegroundColor White       'DestinationDriveLetter or to save to a Network share'
    $ParentDirectory = Split-Path $ImageFile -Parent
    if (!(Test-Path "$ParentDirectory")) {
        Write-Host -ForegroundColor Yellow "Directory '$ParentDirectory' does not exist and will be created automatically"
    }

    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    Write-Host -ForegroundColor Cyan        'Other Parameters'
    Write-Host -ForegroundColor White       ' -Name             ' -NoNewline
    Write-Host -ForegroundColor Gray        'Windows Image Property: Specifies the name of an image'
    Write-Host -ForegroundColor White       ' -Description      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Windows Image Property: Specifies the description of the image'
    Write-Host -ForegroundColor White       ' -Compress         ' -NoNewline
    Write-Host -ForegroundColor Gray        'Compression level | Values: Default None'
    Write-Host -ForegroundColor Yellow      ' -Force            ' -NoNewline
    Write-Host -ForegroundColor Gray        'Executes the capture'
    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    Write-Host -ForegroundColor Cyan        'Cmd Syntax:'
    Write-Host -ForegroundColor White       "DISM.exe /Capture-FFU /ImageFile=`"$ImageFile`" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:`"$Name`" /Description:`"$Description`" /Compress:$Compress"
    Write-Host -ForegroundColor DarkCyan    ''
    Write-Host -ForegroundColor Cyan        "PowerShell Syntax:"
    Write-Host -ForegroundColor White       "Backup-DiskToFFU -ImageFile `"$ImageFile`" -DiskNumber $DiskNumber -Name `"$Name`" -Description `"$Description`" -Compress $Compress " -NoNewline
    Write-Host -ForegroundColor Yellow      "-Force"
    Write-Host -ForegroundColor DarkCyan    ''
    Write-Host -ForegroundColor Cyan        "PowerShell Splatting:"
    Write-Host -ForegroundColor White       '$FFU = @{'
    Write-Host -ForegroundColor White       "   ImageFile = `"$ImageFile`""
    Write-Host -ForegroundColor White       "   DiskNumber = $DiskNumber"
    Write-Host -ForegroundColor White       "   Name = `"$Name`""
    Write-Host -ForegroundColor White       "   Description = `"$Description`""
    Write-Host -ForegroundColor White       "   Compress = `"$Compress`""
    Write-Host -ForegroundColor White       "}"
    Write-Host -ForegroundColor White       "Backup-DiskToFFU @FFU " -NoNewline
    Write-Host -ForegroundColor Yellow      "-Force"
    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    
    if ([string]::IsNullOrEmpty($DestinationDriveLetter)) {
        Write-Warning "Unable to find a proper DestinationDriveLetter to store the Windows Image FFU file"
        Write-Warning "-Destination Drive must be larger than 10 GB and formatted NTFS"
        Write-Warning "-Destination Drive must not exist on the disk you are capturing (DiskNumber: $DiskNumber)"
        Write-Warning "-Network Drives are not supported in this release"
        Write-Warning "To bypass these issues, adjust and use the Command Prompt Syntax"
        Break
    }

    
    if ($env:SystemDrive -ne 'X:') {
        Write-Warning "You should be in WinPE to capure a proper FFU.  If you have issues, that's on you!"
    }

    if ($Force) {
        if (!(Test-Path "$ParentDirectory")) {
            New-Item -Path $ParentDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        DISM.exe /Capture-FFU /ImageFile="$ImageFile" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:"$Name" /Description:"$Description" /Compress:$Compress
        #Return Get-WindowsImage -ImagePath $ImageFile
    } else {
        Write-Warning "If everything looks good, add the -Force parameter to capture the FFU"
    }
}

$ScriptBlock = {
    param($CommandName,$ParameterName,$stringMatch)
    Get-DriveForBackupFile | Select-Object -ExpandProperty DriveLetter 
}

Register-ArgumentCompleter -CommandName Backup-DiskToFFU -ParameterName DestinationDriveLetter -ScriptBlock $ScriptBlock