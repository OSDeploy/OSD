<#
.SYNOPSIS
Saves a Drive as Full Flash Update Windows Image (FFU)

.DESCRIPTION
Saves a Drive as Full Flash Update Windows Image (FFU)

.LINK
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/deploy-windows-using-full-flash-update--ffu

.NOTES
21.1.27    Initial Release
#>
function Backup-Disk.ffu {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Start the Clock
    #=================================================
    $backupdiskffuStartTime = Get-Date
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Set Variables
    #=================================================
    $ErrorActionPreference = 'Stop'
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #	Module and Command Information
    #=================================================
    $GetCommandName = $MyInvocation.MyCommand | Select-Object -ExpandProperty Name
    $GetModuleBase = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty ModuleBase
    $GetModulePath = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty Path
    $GetModuleVersion = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty Version
    $GetCommandHelpUri = Get-Command -Name $GetCommandName | Select-Object -ExpandProperty HelpUri
    Write-Host "$GetCommandName" -ForegroundColor Cyan
    Write-Host "$GetCommandHelpUri"
    Write-Host ""
    #=================================================
    #	Select-Disk.ffu
    #=================================================
    $SelectFFUDisk = Select-Disk.ffu -SelectOne
    #=================================================
    #	Bail if there are no results
    #=================================================
    if (-NOT ($SelectFFUDisk)) {
        Write-Warning "No Fixed Drives that met the required criteria were detected"
        Break
    }
    #=================================================
    #	Select-Disk.storage
    #=================================================
    $SelectFFUDestination = Select-Disk.storage -NotDiskNumber $SelectFFUDisk.DiskNumber
    #=================================================
    #	Bail if there are no results
    #=================================================
    if (-NOT ($SelectFFUDestination)) {
        Write-Warning "Could not find a Disk to use for an FFU Backup"
        Break
    }

    $Description = "$(Get-MyComputerManufacturer -Brief) $(Get-MyComputerModel -Brief) $(Get-MyBiosSerialNumber -Brief)"
    $Compress = 'Default'
    $DiskNumber = $SelectFFUDisk.DiskNumber
    $Name = "disk$DiskNumber"
    $ImageFile = "$($SelectFFUDestination.DriveLetter):\BackupFFU\$(Get-MyComputerManufacturer -Brief)\$(Get-MyComputerModel -Brief)\$(Get-MyBiosSerialNumber -Brief)_$Name.ffu"
    $ParentDirectory = Split-Path $ImageFile -Parent

    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    Write-Host -ForegroundColor Cyan        'Cmd Syntax:'
    Write-Host -ForegroundColor White       "DISM.exe /Capture-FFU /ImageFile=`"$ImageFile`" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:`"$Name`" /Description:`"$Description`" /Compress:$Compress"
    Write-Host -ForegroundColor DarkGray    '======================================================================================================'
    
    do {$ConfirmFFU = Read-Host "Type FFU to create the Backup, or X to Exit"}
    until (($ConfirmFFU -eq 'FFU') -or ($ConfirmFFU -eq 'X'))

    if ($env:SystemDrive -ne 'X:') {
        Write-Warning "You need to boot into WinPE to capture the FFU, but you aren't so I'm not gonna do it for you!"
    }
    elseif ($ConfirmFFU -eq 'FFU') {
        if (!(Test-Path "$ParentDirectory")) {
            Try {New-Item -Path $ParentDirectory -ItemType Directory -Force -ErrorAction Stop}
            Catch {Write-Warning "Destination appears to be Read Only.  Try another Destination Drive"; Break}
        }
        DISM.exe /Capture-FFU /ImageFile="$ImageFile" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:"$Name" /Description:"$Description" /Compress:$Compress
        Return Get-WindowsImage -ImagePath $ImageFile
    }
}