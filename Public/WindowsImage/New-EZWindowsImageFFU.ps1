<#
.SYNOPSIS
Saves a Drive as Full Flash Update Windows Image (FFU)

.DESCRIPTION
Saves a Drive as Full Flash Update Windows Image (FFU)

.LINK
https://osd.osdeploy.com/module/functions/new-ezwindowsimageffu
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/deploy-windows-using-full-flash-update--ffu

.NOTES
21.1.27    Initial Release
#>
function New-EZWindowsImageFFU {
    [CmdletBinding()]
    Param (
        #Disk Number of the Drive to capture
        #Use Get-Disk to get the DiskNumber Property
        [Alias('Number')]
        [int] $DiskNumber = 0,

        [ValidateScript({$_ -in (Get-AvailableBackupDriveLetters)})]
        [string] $DestinationDriveLetter = "$(Get-AvailableBackupDriveLetters | Select-Object -First 1)",
        
        #Windows Image Property: Specifies the name of an image
        [string] $Name = "disk$DiskNumber",

        #Full path to save the Windows Image
        [Alias('ImagePath')]
        [string] $ImageFile = "$($DestinationDriveLetter):\Backup\$(Get-EZComputerManufacturer)\$(Get-EZComputerModel)\$(Get-EZComputerSerialNumber)_$Name.ffu",

        #Windows Image Property: Specifies the description of the image
        [string] $Description = "$(Get-EZComputerManufacturer) $(Get-EZComputerModel) $(Get-EZComputerSerialNumber)",

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
    $GetCommandNoun = Get-Command -Name New-EZWindowsImageFFU | Select-Object -ExpandProperty Noun
    $GetCommandVersion = Get-Command -Name New-EZWindowsImageFFU | Select-Object -ExpandProperty Version
    $GetCommandHelpUri = Get-Command -Name New-EZWindowsImageFFU | Select-Object -ExpandProperty HelpUri
    $GetCommandModule = Get-Command -Name New-EZWindowsImageFFU | Select-Object -ExpandProperty Module
    $GetModuleDescription = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty Description
    $GetModuleProjectUri = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty ProjectUri
    $GetModulePath = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty Path
    #======================================================================================================
    #	Validate
    #======================================================================================================
    if ($ImageFile -like ":*") {
        $ImageFile = "C$ImageFile"
    }
    #======================================================================================================
    #	Usage
    #======================================================================================================
    Write-Host -ForegroundColor Gray        '======================================================================================================'
    Write-Host -ForegroundColor White       "New-EZWindowsImageFFU " -NoNewline
    Write-Host -ForegroundColor Cyan        "$GetCommandVersion $GetModulePath"
    Write-Host -ForegroundColor DarkCyan    $GetCommandHelpUri
    Write-Host -ForegroundColor Gray        '======================================================================================================'
    Write-Host -ForegroundColor Cyan        'Parameters'
    Write-Host -ForegroundColor White       '-ImageFile     ' -NoNewline
    Write-Host -ForegroundColor Gray        'Full path of the Windows Image FFU'
    Write-Host -ForegroundColor White       '-DiskNumber    ' -NoNewline
    Write-Host -ForegroundColor Gray        'Disk Number of the Drive to capture.  Use Get-Disk to get the DiskNumber Property'
    Write-Host -ForegroundColor White       '-Name          ' -NoNewline
    Write-Host -ForegroundColor Gray        'Windows Image Property: Specifies the name of an image'
    Write-Host -ForegroundColor White       '-Description   ' -NoNewline
    Write-Host -ForegroundColor Gray        'Windows Image Property: Specifies the description of the image'
    Write-Host -ForegroundColor White       '-Compress      ' -NoNewline
    Write-Host -ForegroundColor Gray        'Compression level.  Default or None'
    Write-Host -ForegroundColor White       '-Force         ' -NoNewline
    Write-Host -ForegroundColor Gray        'Executes the capture'
    Write-Host -ForegroundColor Gray        '======================================================================================================'
    Write-Host -ForegroundColor Cyan        'Command Prompt Syntax:'
    Write-Host -ForegroundColor Gray        "DISM.exe /Capture-FFU /ImageFile=`"$ImageFile`" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:`"$Name`" /Description:`"$Description`" /Compress:$Compress"
    Write-Host -ForegroundColor DarkCyan    ''
    Write-Host -ForegroundColor Cyan        "PowerShell Syntax:"
    Write-Host -ForegroundColor White       "New-EZWindowsImageFFU -ImageFile `"$ImageFile`" -DiskNumber $DiskNumber -Name `"$Name`" -Description `"$Description`" -Compress $Compress " -NoNewline
    Write-Host -ForegroundColor Yellow      "-Force"
    Write-Host -ForegroundColor Gray        '======================================================================================================'
    
    if ([string]::IsNullOrEmpty($DestinationDriveLetter)) {
        Write-Warning "Unable to find a proper DestinationDriveLetter to store the Windows Image FFU file"
        Write-Warning "-Destination Drive must be larger than 10 GB and formatted NTFS"
        Write-Warning "-Destination Drive must not exist on the disk you are capturing (DiskNumber: $DiskNumber)"
        Write-Warning "-Network Drives are not supported in this release"
        Write-Warning "To bypass these issues, adjust and use the Command Prompt Syntax"
        Break
    }              


    $AvailableBackupDriveLetters = Get-Partition | `
    Where-Object {$_.DiskNumber -ne $IgnoreDisk} | `
    Where-Object {$_.DriveLetter -gt 0} | `
    Where-Object {$_.IsOffline -eq $false} | `
    Where-Object {$_.IsReadOnly -ne $true} | `
    Where-Object {$_.Size -gt 10000000000} | `
    Sort-Object -Property DriveLetter | Select-Object -ExpandProperty DriveLetter


    $ParentDirectory = Split-Path $ImageFile -Parent
    if (!(Test-Path "$ParentDirectory")) {
        Write-Host -ForegroundColor Yellow "Directory '$ParentDirectory' does not exist and will be created automatically"
        if ($Force) {
            New-Item -Path $ParentDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
    }
    if ($Force) {
        DISM.exe /Capture-FFU /ImageFile="$ImageFile" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:"$Name" /Description:"$Description" /Compress:$Compress
        Return Get-WindowsImage -ImagePath $ImageFile
    }
}

$ScriptBlock = {
    param($CommandName,$ParameterName,$stringMatch)
    Get-AvailableBackupDriveLetters
}

Register-ArgumentCompleter -CommandName New-EZWindowsImageFFU -ParameterName DestinationDriveLetter -ScriptBlock $ScriptBlock