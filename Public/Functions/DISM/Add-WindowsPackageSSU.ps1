<#
.SYNOPSIS
Adds the SSU from a Cumulative Update .cab or .msu to a Windows Image

.DESCRIPTION
The Add-WindowsPackageSSU cmdlet installs a specified .cab or .msu package in the image

.PARAMETER Path
Specifies the full path to the root directory of the offline Windows image that you will service.

.PARAMETER PackagePath
Specifies the location of the package to add to the image

.PARAMETER Online
Specifies that the action is to be taken on the operating system that is currently running on the local computer.

.PARAMETER LogPath
Specifies the full path and file name to log to. If not set, the default is %WINDIR%\Logs\Dism\dism.log.
In Windows PE, the default directory is the RAMDISK scratch space which can be as low as 32 MB. The log file will automatically be archived. The archived log file will be saved with .bak appended to the file name and a new log file will be generated. Each time the log file is archived the .bak file will be overwritten. 
When using a network share that is not joined to a domain, use the net use command together with domain credentials to set access permissions before you set the log path for the DISM log.

.LINK

.NOTES
#>
function Add-WindowsPackageSSU {
    [CmdletBinding(DefaultParameterSetName = 'Offline')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackagePath,

        [Parameter(ParameterSetName = 'Offline', Mandatory = $true)]
        [string]$Path,

        [Parameter(ParameterSetName = 'Online', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]$Online,

        [string]$LogPath = "$env:windir\Logs\Dism\dism.log"
    )
    #=================================================
    #   Blocks
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    #=================================================
    #   Test PackagePath
    #=================================================
    if (!(Test-Path "$PackagePath" -PathType Leaf)) {
        Write-Warning "Add-WindowsPackageLCU could not find $Path"; Continue
    }
    $PackagePathItem = Get-Item $PackagePath
    #=================================================
    #   SSU Temp Path
    #=================================================
    $SSUTemp = Join-Path $env:Temp 'SSU'

    #See if the path already exists and remove it
    if (Test-Path $SSUTemp) {
        Remove-Item -Path $SSUTemp -Recurse -Force -ErrorAction Ignore | Out-Null
    }

    #Create the SSU Temp Path
    New-Item -Path $SSUTemp -ItemType Directory -Force -ErrorAction Ignore | Out-Null

    #Bail if SSU Temp Path doesn't exist
    if (!(Test-Path $SSUTemp)) {
        Write-Warning "Add-WindowsPackageLCU could not create $SSUTemp"; Continue
    }
    #=================================================
    #   Expand MSU
    #=================================================
    if ($PackagePathItem.Extension -match '.msu') {
        & Expand.exe "$($PackagePathItem.FullName)" /f:Windows*.cab "$SSUTemp"
        Get-ChildItem -Path $SSUTemp *.cab | Where-Object {$_.Name -notmatch 'SSU'} | foreach {
            & Expand.exe $_.FullName /f:SSU*.cab "$SSUTemp"
        }
    }
    else {
        #Write-Host -ForegroundColor DarkGray "Expand SSU: $PackagePath"
        & Expand.exe "$($PackagePathItem.FullName)" /f:SSU*.cab "$SSUTemp"
    }
    #=================================================
    #   Apply SSU
    #=================================================
    if ($Online.IsPresent) {
        Get-ChildItem -Path $SSUTemp SSU*.cab | foreach {
            Write-Host -ForegroundColor DarkGray $_.FullName
            Add-WindowsPackage -PackagePath $_.FullName -Online -LogPath $LogPath -Verbose | Out-Null
        }
    }
    else {
        Get-ChildItem -Path $SSUTemp SSU*.cab | foreach {
            Write-Host -ForegroundColor DarkGray $_.FullName
            Add-WindowsPackage -PackagePath $_.FullName -Path $Path -LogPath $LogPath -Verbose | Out-Null
        }
    }
    #=================================================
}