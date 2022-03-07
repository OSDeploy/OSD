<#
.SYNOPSIS
Updates a mounted WIM

.DESCRIPTION
Updates a mounted WIM files.  Requires WSUSXML Catalog

.PARAMETER Path
Specifies the full path to the root directory of the offline Windows image that you will service

.PARAMETER Update
Check or Install the specified Update Group
Check = Validate installed Updates
All = Install all required Updates
AdobeSU = Adobe Security Update
DotNet = DotNet Update
DotNetCU = DotNet Cumulative Update
LCU = Latest Cumulative Update
SSU = Servicing Stack Update

.PARAMETER BitsTransfer
Download the file using BITS-Transfer
Interactive Login required

.PARAMETER Force
Updates are only installed if they are needed
Force parameter will install the update even if it is already installed

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Update-MyWindowsImage {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String[]]$Path,

        [ValidateSet('Check','All','AdobeSU','DotNet','DotNetCU','LCU','SSU')]
        [System.String]$Update = 'Check',

        [switch]$BitsTransfer,

        [switch]$Force
    )

    begin {
        #=================================================
        #   Block
        #=================================================
        Block-StandardUser
        Block-WindowsVersionNe10
        #=================================================
        #   Get-WindowsImage Mounted
        #=================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
        #=================================================
    }
    process {
        foreach ($Input in $Path) {
            #=================================================
            #   Path
            #=================================================
            $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
            Write-Verbose "Path: $MountPath" -Verbose
            #=================================================
            #   Validate Mount Path
            #=================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Update-MyWindowsImage: Unable to locate Mounted WindowsImage at $Input"
                Break
            }
            #=================================================
            #   Get Registry Information
            #=================================================
            $global:GetRegCurrentVersion = Get-RegCurrentVersion -Path $Input
            #=================================================
            #   Require OSMajorVersion 10
            #=================================================
            if ($global:GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
                Write-Warning "Update-MyWindowsImage: OS MajorVersion 10 is required"
                Break
            }

            Write-Verbose -Verbose $global:GetRegCurrentVersion.ReleaseId
            #=================================================
            #   Get-WSUSXML and Filter Results
            #=================================================
            $global:GetWSUSXML = Get-WSUSXML -Catalog Windows -Silent | Sort-Object UpdateGroup -Descending

            if ($global:GetRegCurrentVersion.ReleaseId -gt 0) {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateBuild -eq $global:GetRegCurrentVersion.DisplayVersion}
            }
            else {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateBuild -eq $global:GetRegCurrentVersion.ReleaseId}
            }

            if ($global:GetRegCurrentVersion.BuildLabEx -match 'amd64') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateArch -eq 'x64'}
            } else {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateArch -eq 'x86'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'WindowsPE') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateOS -eq 'Windows 10'}
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -notmatch 'DotNet'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Core') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Client') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateOS -notmatch 'Server'}
            }
            if ($global:GetRegCurrentVersion.InstallationType -match 'Server') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateOS -match 'Server'}
            }

            #Don't install Optional Updates
            $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -ne ''}

            if ($Update -ne 'Check' -and $Update -ne 'All') {
                $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -match $Update}
            }
            #=================================================
            #   Get-SessionsXml
            #=================================================
            $global:GetSessionsXml = Get-SessionsXml -Path "$Input" | Where-Object {$_.targetState -eq 'Installed'} | Sort-Object id
            #=================================================
            #   Apply Update
            #=================================================
            foreach ($item in $global:GetWSUSXML) {
                if (! ($Force.IsPresent)) {
                    if ($global:GetSessionsXml | Where-Object {$_.KBNumber -match "$($item.FileKBNumber)"}) {
                        Write-Verbose "Installed: $($item.Title) $($item.FileName)" -Verbose
                        Continue
                    } else {
                        Write-Warning "Not Installed: $($item.Title) $($item.FileName)"
                    }
                }

                if ($Update -eq 'Check') {Continue}
                
<#                 if ($BitsTransfer.IsPresent) {
                    $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -BitsTransfer -Verbose
                } else {
                    $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -Verbose
                } #>
                $UpdateFile = Save-WebFile -SourceUrl $item.OriginUri
                $CurrentLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Update-MyWindowsImage.log"

                if (! (Test-Path "$env:TEMP\OSD")) {New-Item -Path "$env:TEMP\OSD" -Force | Out-Null}

                if (Test-Path $UpdateFile.FullName) {
                    #Write-Verbose "Add-WindowsPackage -PackagePath $($UpdateFile.FullName) -Path $Input" -Verbose
                    Try {
                        Write-Verbose "Add-WindowsPackage -Path $Input -PackagePath $($UpdateFile.FullName)" -Verbose
                        Add-WindowsPackage -Path $Input -PackagePath $UpdateFile.FullName -LogPath $CurrentLog | Out-Null
                    }
                    Catch {
                        if ($_.Exception.Message -match '0x800f081e') {
                        Write-Verbose "Update-MyWindowsImage: 0x800f081e The package is not applicable to this image" -Verbose}
                        Write-Verbose $CurrentLog -Verbose
                    }
                } else {
                    Write-Warning "Unable to download $($UpdateFile.FullName)"
                }
            }
            #=================================================
            #   Return for PassThru
            #=================================================
            Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
            #=================================================
        }
    }
    end {}
}