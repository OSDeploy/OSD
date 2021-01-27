<#
.SYNOPSIS
Saves a Drive as Full Flash Update Windows Image (FFU)

.DESCRIPTION
Saves a Drive as Full Flash Update Windows Image (FFU)

.LINK
https://osd.osdeploy.com/module/functions/new-ezwindowsimageffu

.NOTES
21.1.27    David Segura @SeguraOSD
#>
function New-EZWindowsImageFFU {
    [CmdletBinding()]
    Param (
        #Full path to save the Windows Image
        [Alias('ImagePath')]
        [string] $ImageFile = 'D:\Windows10Enterprise.ffu',
        
        #Disk Number of the Drive to capture
        #Use Get-Disk to get the DiskNumber Property
        [Alias('Number')]
        [int] $DiskNumber = 0,
        
        #Windows Image Property: Specifies the name of an image
        [string] $Name = 'disk0',

        #Windows Image Property: Specifies the description of the image
        [string] $Description = 'Windows 10 FFU',

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
    #	Usage
    #======================================================================================================
    Write-Verbose '======================================================================================================'
    Write-Verbose "New-EZWindowsImageFFU $GetCommandVersion"
    Write-Verbose $GetCommandHelpUri
    Write-Verbose "OSD Module Path: $GetModulePath"
    Write-Verbose '======================================================================================================'
    Write-Verbose '-ImageFile   Full path of the Windows Image FFU'
    Write-Verbose ''
    Write-Verbose '-DiskNumber  Disk Number of the Drive to capture.  Use Get-Disk to get the DiskNumber Property'
    Write-Verbose ''
    Write-Verbose '-Name        Windows Image Property: Specifies the name of an image'
    Write-Verbose ''
    Write-Verbose '-Description Windows Image Property: Specifies the description of the image'
    Write-Verbose ''
    Write-Verbose '-Compress    Compression level.  Default or None'
    Write-Verbose ''
    Write-Verbose '-Force       Executes the capture'
    Write-Verbose '======================================================================================================'
    Write-Verbose 'Dism Command Line:'
    Write-Verbose "DISM.exe /Capture-FFU /ImageFile=`"$ImageFile`" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:`"$Name`" /Description:`"$Description`" /Compress:$Compress"
    Write-Verbose ''
    Write-Verbose "PowerShell New-EZWindowsImageFFU Command Line:"
    Write-Verbose "New-EZWindowsImageFFU -ImageFile `"$ImageFile`" -DiskNumber $DiskNumber -Name `"$Name`" -Description `"$Description`" -Compress $Compress -Force"

    if ($Force) {
        DISM.exe /Capture-FFU /ImageFile="$ImageFile" /CaptureDrive=\\.\PhysicalDrive$DiskNumber /Name:"$Name" /Description:"$Description" /Compress:$Compress
        Return Get-WindowsImage -ImagePath $ImageFile
    }
}