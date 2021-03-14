<#
.SYNOPSIS
Saves a Drive as Full Flash Update Windows Image (FFU)

.DESCRIPTION
Saves a Drive as Full Flash Update Windows Image (FFU)

.LINK
https://osd.osdeploy.com/module/functions/disk/backup-disktoffu
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/deploy-windows-using-full-flash-update--ffu

.NOTES
21.1.27    Initial Release
#>
function Backup-DiskToFFU {
    [CmdletBinding()]
    param (
        #Disk Number of the Drive to capture
        #Use Get-Disk to get the DiskNumber Property
        [Alias('Number')]
        [ValidateScript({$_ -in (Get-FFUSourceDisks | Select-Object -ExpandProperty DiskNumber)})]
        [int] $DiskNumber = (Get-FFUSourceDisks | Select-Object -ExpandProperty DiskNumber -First 1),

        [ValidateScript({$_ -in (Get-FFUDestinationDisks | Where-Object {$_.DiskNumber -ne $DiskNumber} | Select-Object -ExpandProperty DriveLetter)})]
        [string] $DestinationDriveLetter = "$(Get-FFUDestinationDisks | Where-Object {$_.DiskNumber -ne $DiskNumber} | Select-Object -ExpandProperty DriveLetter -First 1)",
        
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
    #	PSBoundParameters
    #======================================================================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #======================================================================================================
    #	Module and Command Information
    #======================================================================================================
    $GetCommandName = $MyInvocation.MyCommand | Select-Object -ExpandProperty Name
    $GetModuleBase = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty ModuleBase
    $GetModulePath = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty Path
    $GetModuleVersion = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty Version
    $GetCommandHelpUri = Get-Command -Name $GetCommandName | Select-Object -ExpandProperty HelpUri
    Write-Host "$GetCommandName" -NoNewline
    Write-Host " $GetModuleVersion $GetModuleBase" -ForegroundColor Cyan
    Write-Host "$GetCommandHelpUri" -ForegroundColor Cyan
    #======================================================================================================
    #	IsAdmin
    #======================================================================================================
    if (-NOT (Get-OSDGather -Property IsAdmin)) {
        Write-Warning "Administrative Rights are required for execution"
        Break
    }
    #===================================================================================================
    #	Gather
    #===================================================================================================
    $GetLocalDisk = Get-LocalDisk | Where-Object {$_.NumberOfPartitions -ge '1'} | Where-Object {$_.OperationalStatus -eq 'Online'} | Where-Object {$_.Size -gt 0} | Where-Object {$_.IsOffline -eq $false}
    $BootDisks = $GetLocalDisk | Where-Object {$_.IsBoot -eq $true}
    $SourceDisks = $GetLocalDisk | Where-Object {$_.IsBoot -eq $false}
    $DestinationDisks = $(Get-FFUDestinationDisks)
    $Volumes = $(Get-Volume)
    #===================================================================================================
    #	Validate
    #===================================================================================================
    if ($ImageFile -like ":*") {
        $ImageFile = "C$ImageFile"
    }
    #===================================================================================================
    #	Source
    #===================================================================================================
    if ($SourceDisks -or $BootDisks) {
        Write-Host -ForegroundColor DarkGray    '======================================================================================================'
        Write-Host -ForegroundColor Cyan        "-DiskNumber $DiskNumber" -NoNewline
        Write-Host -ForegroundColor Yellow       " [Disk to capture in the FFU. Default is the first available Disk]"
        foreach ($item in $SourceDisks) {
            Write-Host -ForegroundColor Cyan    "$($item.DiskNumber) " -NoNewline
            Write-Host -ForegroundColor White    "$($item.PartitionStyle) Partitions:$($item.NumberOfPartitions) $($item.FriendlyName) $($item.BusType) [$([math]::round($item.Size / 1000000000, 0))GB]"
        }
        if (Get-Partition | Where-Object {$_.DiskNumber -eq $DiskNumber}) {
            Write-Host ""
            Write-Host -ForegroundColor Yellow       "The following Partitions will be saved in the FFU:"
            foreach ($item in (Get-Partition | Where-Object {$_.DiskNumber -eq $DiskNumber})) {
                Write-Host -ForegroundColor White "Partition:$($item.PartitionNumber) DriveLetter:$($item.DriveLetter) Type:$($item.Type) $([math]::round($item.Size / 1000000000, 0)) GB"
            }
        }
        if ($BootDisks) {
            Write-Host ""
            Write-Warning "Disks from a running OS cannot be selected"
            foreach ($item in $BootDisks) {
                Write-Host -ForegroundColor Gray "$($item.DiskNumber) $($item.PartitionStyle) Partitions:$($item.NumberOfPartitions) $($item.FriendlyName) $($item.BusType) [$([math]::round($item.Size / 1000000000, 0))GB]"
            }
        }
    } else {
        Write-Warning "Unable to find a Source Disk to backup"
        Break
    }
    #===================================================================================================
    #	Destination
    #===================================================================================================
    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    Write-Host -ForegroundColor Cyan        "-DestinationDriveLetter $DestinationDriveLetter" -NoNewline
    Write-Host -ForegroundColor Yellow       " [Verify that the Volume selected has enough free space for the FFU]"

    if ($DestinationDisks | Where-Object {$_.DiskNumber -ne $DiskNumber}) {
        foreach ($item in ($DestinationDisks | Where-Object {$_.DiskNumber -ne $DiskNumber})) {
            Write-Host -ForegroundColor Cyan    "$($item.DriveLetter) " -NoNewline
            Write-Host -ForegroundColor White    "$($item.FileSystem) $($item.FileSystemLabel) [$($item.DriveType) TotalSize:$([math]::round($item.Size / 1000000000, 0))GB SizeRemaining:$([math]::round($item.SizeRemaining / 1000000000, 0))GB]"
        }
        if ($DestinationDisks | Where-Object {$_.DiskNumber -eq $DiskNumber}) {
            Write-Host ""
            foreach ($item in ($DestinationDisks | Where-Object {$_.DiskNumber -eq $DiskNumber})) {
                Write-Warning "Volumes that are being captured cannot be used as a Destination Drive"
                Write-Host -ForegroundColor Gray    "$($item.DriveLetter) $($item.FileSystem) $($item.FileSystemLabel) [$($item.DriveType) TotalSize:$([math]::round($item.Size / 1000000000, 0))GB SizeRemaining:$([math]::round($item.SizeRemaining / 1000000000, 0))GB]"
            }
        }
    } else {
        Write-Warning "Could not find any drives that you can backup to"
        Break
    }
    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    Write-Host -ForegroundColor Cyan        "-ImageFile  $ImageFile"
    Write-Host ""
    Write-Host -ForegroundColor Yellow       'This path is generated automatically by combining the DestinationDriveLetter, CimComputerManufacturer,'
    Write-Host -ForegroundColor Yellow       'ComputerModel SerialNumber and DiskNumber.  You can fully modify this path to override the'
    Write-Host -ForegroundColor Yellow       'DestinationDriveLetter or to save to a Network share'
    $ParentDirectory = Split-Path $ImageFile -Parent
    if (!(Test-Path "$ParentDirectory")) {
        Write-Warning "Directory '$ParentDirectory' does not exist and will be created automatically"
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
            Try {New-Item -Path $ParentDirectory -ItemType Directory -Force -ErrorAction Stop}
            Catch {Write-Warning "Destination appears to be Read Only.  Try another Destination Drive";Break}
        }
        DISM.exe /Capture-FFU /ImageFile="$ImageFile" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:"$Name" /Description:"$Description" /Compress:$Compress
        #Return Get-WindowsImage -ImagePath $ImageFile
    } else {
        Write-Warning "If everything looks good, add the -Force parameter e.g. Backup-DiskToFFU -Force"
    }
}

$ScriptBlock = {
    param($CommandName,$ParameterName,$stringMatch)
    Get-FFUDestinationDisks | Select-Object -ExpandProperty DriveLetter 
}

Register-ArgumentCompleter -CommandName Backup-DiskToFFU -ParameterName DestinationDriveLetter -ScriptBlock $ScriptBlock