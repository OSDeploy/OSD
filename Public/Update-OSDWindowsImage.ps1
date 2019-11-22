<#
.SYNOPSIS
Updates a mounted WIM

.DESCRIPTION
Updates a mounted WIM files.  Requires OSDSUS Catalog

.LINK
https://osd.osdeploy.com/module/functions/update-osdwindowsimage

.NOTES
19.11.19 David Segura @SeguraOSD
#>
function Update-OSDWindowsImage {
    [CmdletBinding()]
    Param (
        #Specifies the full path to the root directory of the offline Windows image that you will service.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Path,

        #Check or Install the specified Update Group
        [ValidateSet('Check','All','AdobeSU','DotNet','DotNetCU','LCU','SSU')]
        [string]$Update = 'Check',

        #Download the file using BITS-Transfer
        #Interactive Login required
        [switch]$BitsTransfer,

        #Updates are only installed if they are needed.  Force parameter will install the update even if it is already installed
        [switch]$Force
    )

    Begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning 'Update-WindowsImage: This function requires Admin Rights ELEVATED'
            Break
        }
        #===================================================================================================
        #   Require OSDSUS Module
        #===================================================================================================
        if (-not (Get-Module -ListAvailable -Name OSDSUS)) {
            Write-Warning "Update-WindowsImage: PowerShell Module OSDSUS is required"
            Break
        }
        #===================================================================================================
        #   Get-WindowsImage Mounted
        #===================================================================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
    }
    Process {
        foreach ($Input in $Path) {
            #===================================================================================================
            #   Path
            #===================================================================================================
            $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
            Write-Verbose "Path: $MountPath" -Verbose
            #===================================================================================================
            #   Validate Mount Path
            #===================================================================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Update-WindowsImage: Unable to locate Mounted WindowsImage at $Input"
                Break
            }
            #===================================================================================================
            #   Get Registry Information
            #===================================================================================================
            $global:GetRegCurrentVersion = Get-RegCurrentVersion -Path $Input
            #===================================================================================================
            #   Require OSMajorVersion 10
            #===================================================================================================
            if ($global:GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
                Write-Warning "Update-WindowsImage: OS MajorVersion 10 is required"
                Break
            }
            #===================================================================================================
            #   Get-OSDSUS and Filter Results
            #===================================================================================================
            $global:GetOSDSUS = Get-OSDSUS -Catalog OSDBuilder | Sort-Object UpdateGroup -Descending
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateBuild -eq $global:GetRegCurrentVersion.ReleaseId}
            
            if ($global:GetRegCurrentVersion.BuildLabEx -match 'amd64') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateArch -eq 'x64'}
            } else {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateArch -eq 'x86'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'WindowsPE') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateOS -eq 'Windows 10'}
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -notmatch 'DotNet'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Core') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Client') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateOS -notmatch 'Server'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Server') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateOS -match 'Server'}
            }

            #Don't install Optional Updates
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -ne ''}

            if ($Update -ne 'Check' -and $Update -ne 'All') {
                $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -match $Update}
            }
            #===================================================================================================
            #   Get-OSDSessions
            #===================================================================================================
            $global:GetOSDSessions = Get-OSDSessions -Path "$Input" | Where-Object {$_.targetState -eq 'Installed'} | Sort-Object id
            #===================================================================================================
            #   Apply Update
            #===================================================================================================
            foreach ($item in $global:GetOSDSUS) {
                if (! ($Force.IsPresent)) {
                    if ($global:GetOSDSessions | Where-Object {$_.KBNumber -match "$($item.FileKBNumber)"}) {
                        Write-Verbose "Installed: $($item.Title) $($item.FileName)" -Verbose
                        Continue
                    } else {
                        Write-Warning "Not Installed: $($item.Title) $($item.FileName)"
                    }
                }

                if ($Update -eq 'Check') {Continue}
                

                if ($BitsTransfer.IsPresent) {
                    $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -BitsTransfer -Verbose
                } else {
                    $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -Verbose
                }
                $CurrentLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Update-OSDWindowsImage.log"

                if (! (Test-Path "$env:TEMP\OSD")) {New-Item -Path "$env:TEMP\OSD" -Force | Out-Null}

                if (Test-Path $UpdateFile.FullName) {
                    #Write-Verbose "Add-WindowsPackage -PackagePath $($UpdateFile.FullName) -Path $Input" -Verbose
                    Try {
                        Write-Verbose "Add-WindowsPackage -Path $Input -PackagePath $($UpdateFile.FullName)" -Verbose
                        Add-WindowsPackage -Path $Input -PackagePath $UpdateFile.FullName -LogPath $CurrentLog | Out-Null
                    }
                    Catch {
                        if ($_.Exception.Message -match '0x800f081e') {
                        Write-Verbose "Update-WindowsImage: 0x800f081e The package is not applicable to this image" -Verbose}
                        Write-Verbose $CurrentLog -Verbose
                    }
                } else {
                    Write-Warning "Unable to download $($UpdateFile.FullName)"
                }
            }
            #===================================================================================================
            #   Return for PassThru
            #===================================================================================================
            Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
        }
    }
    End {}
}