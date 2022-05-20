<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module should be loaded in WinPE and OOBE
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpeoobe.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpeoobe.psm1')
#>
#=================================================
#region Environment Variables
$oobePowerShellProfile = @'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[System.Environment]::SetEnvironmentVariable('Path',$Env:Path + ";$Env:ProgramFiles\WindowsPowerShell\Scripts",'Process')
'@
$winpePowerShellProfile = @'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[System.Environment]::SetEnvironmentVariable('APPDATA',"$Env:UserProfile\AppData\Roaming",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEDRIVE',"$Env:SystemDrive",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEPATH',"$Env:UserProfile",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$Env:UserProfile\AppData\Local",[System.EnvironmentVariableTarget]::Process)
'@
#endregion
#=================================================
#region Functions
function osdcloud-RemoveAppx {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [Parameter(Mandatory,ParameterSetName='Basic')]
        [System.Management.Automation.SwitchParameter]$Basic,

        [Parameter(Mandatory,ParameterSetName='ByName',Position=0)]
        [System.String[]]$Name
    )
    if ($WindowsPhase -eq 'WinPE') {
        if (Get-Command Get-AppxProvisionedPackage) {
            if ($Basic) {
                $Name = @('CommunicationsApps','OfficeHub','People','Skype','Solitaire','Xbox','ZuneMusic','ZuneVideo')
            }
            elseif ($Name) {
                #Do Nothing
            }
            if ($Name) {
                Write-Host -ForegroundColor Cyan "Remove-AppxProvisionedPackage -Path 'C:\' -PackageName"
                foreach ($Item in $Name) {
                    Get-AppxProvisionedPackage -Path 'C:\' | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {
                        Write-Host -ForegroundColor DarkGray $_.DisplayName
                        Try {
                            $null = Remove-AppxProvisionedPackage -Path 'C:\' -PackageName $_.PackageName
                        }
                        Catch {
                            Write-Warning "Appx Provisioned Package $($_.PackageName) did not remove successfully"
                        }
                    }
                }
            }
        }
    }
    if ($WindowsPhase -eq 'OOBE') {
        if (Get-Command Get-AppxProvisionedPackage) {
            if ($Basic) {
                $Name = @('CommunicationsApps','OfficeHub','People','Skype','Solitaire','Xbox','ZuneMusic','ZuneVideo')
            }
            elseif ($Name) {
                #Do Nothing
            }
            else {
                $Name = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | `
                Select-Object -Property DisplayName, PackageName | `
                Out-GridView -PassThru -Title 'Select one or more Appx Provisioned Packages to remove' | `
                Select-Object -ExpandProperty DisplayName
            }
            if ($Name) {
                Write-Host -ForegroundColor Cyan 'Remove-AppxProvisionedPackage -Online -AllUsers -PackageName'
                foreach ($Item in $Name) {
                    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {
                        Write-Host -ForegroundColor DarkGray $_.DisplayName
                        if ((Get-Command Remove-AppxProvisionedPackage).Parameters.ContainsKey('AllUsers')) {
                            Try {
                                $null = Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $_.PackageName
                            }
                            Catch {
                                Write-Warning "AllUsers Appx Provisioned Package $($_.PackageName) did not remove successfully"
                            }
                        }
                        else {
                            Try {
                                $null = Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName
                            }
                            Catch {
                                Write-Warning "Appx Provisioned Package $($_.PackageName) did not remove successfully"
                            }
                        }
                    }
                }
            }
        }
    }
}
New-Alias -Name 'RemoveAppx' -Value 'osdcloud-RemoveAppx' -Description 'OSDCloud' -Force
function osdcloud-SetPowerShellProfile {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        if (-not (Test-Path "$env:UserProfile\Documents\WindowsPowerShell")) {
            $null = New-Item -Path "$env:UserProfile\Documents\WindowsPowerShell" -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        Write-Host -ForegroundColor DarkGray 'Set LocalAppData in PowerShell Profile'
        $winpePowerShellProfile | Set-Content -Path "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force -Encoding Unicode
    }
    if ($WindowsPhase -eq 'OOBE') {
        if (-not (Test-Path $Profile.CurrentUserAllHosts)) {
            
            Write-Host -ForegroundColor DarkGray 'Set PowerShell Profile [CurrentUserAllHosts]'
            $null = New-Item $Profile.CurrentUserAllHosts -ItemType File -Force

            #[System.Environment]::SetEnvironmentVariable('Path',"$Env:LocalAppData\Microsoft\WindowsApps;$Env:ProgramFiles\WindowsPowerShell\Scripts;",'User')

            #[System.Environment]::SetEnvironmentVariable('Path',$Env:Path + ";$Env:ProgramFiles\WindowsPowerShell\Scripts")
            #[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

            $oobePowerShellProfile | Set-Content -Path $Profile.CurrentUserAllHosts -Force -Encoding Unicode
        }
    }
}
function osdcloud-TrustPSGallery {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        $PSRepository = Get-PSRepository -Name PSGallery
        if ($PSRepository) {
            if ($PSRepository.InstallationPolicy -ne 'Trusted') {
                Write-Host -ForegroundColor DarkGray 'Set-PSRepository PSGallery Trusted'
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            }
        }
    }
    if ($WindowsPhase -eq 'OOBE') {
        $PSRepository = Get-PSRepository -Name PSGallery
        if ($PSRepository) {
            if ($PSRepository.InstallationPolicy -ne 'Trusted') {
                Write-Host -ForegroundColor DarkGray 'Set-PSRepository PSGallery Trusted [CurrentUser]'
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            }
        }
    }
}
#endregion
#=================================================