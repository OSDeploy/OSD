<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module is designed for OOBE
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobe.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobe.psm1')
#>
#=================================================
#region Windows Settings
function osdcloud-SetWindowsDateTime {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor Yellow 'Verify the Date and Time is set properly including the Time Zone'
    Write-Host -ForegroundColor Yellow 'If this is not configured properly, Certificates and Domain Join may fail'
    Start-Process 'ms-settings:dateandtime' | Out-Null
    $ProcessId = (Get-Process -Name 'SystemSettings').Id
    if ($ProcessId) {
        Wait-Process $ProcessId
    }
}
function osdcloud-SetWindowsDisplay {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor Yellow 'Verify the Display Resolution and Scale is set properly'
    Start-Process 'ms-settings:display' | Out-Null
    $ProcessId = (Get-Process -Name 'SystemSettings').Id
    if ($ProcessId) {
        Wait-Process $ProcessId
    }
}
function osdcloud-SetWindowsLanguage {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor Yellow 'Verify the Language, Region, and Keyboard are set properly'
    Start-Process 'ms-settings:regionlanguage' | Out-Null
    $ProcessId = (Get-Process -Name 'SystemSettings').Id
    if ($ProcessId) {
        Wait-Process $ProcessId
    }
}
#endregion
#=================================================
#region Autopilot Functions
function osdcloud-AutopilotRegisterCommand {
    [CmdletBinding()]
    param (
        [System.String]
        $Command = 'Get-WindowsAutopilotInfo -Online -Assign'
    )
    Write-Host -ForegroundColor Cyan 'Registering Device in Autopilot in new PowerShell window ' -NoNewline
    $AutopilotProcess = Start-Process PowerShell.exe -ArgumentList "-Command $Command" -PassThru
    Write-Host -ForegroundColor Green "(Process Id $($AutopilotProcess.Id))"
    Return $AutopilotProcess
}
#endregion
#=================================================
#region Windows Functions
function osdcloud-AddCapability {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [Parameter(Mandatory,ParameterSetName='ByName',Position=0)]
        [System.String[]]$Name
    )
    if ($Name) {
        #Do Nothing
    }
    else {
        $Name = Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'} | Select-Object Name | Out-GridView -PassThru -Title 'Select one or more Capabilities' | Select-Object -ExpandProperty Name
    }
    if ($Name) {
        Write-Host -ForegroundColor Cyan "Add-WindowsCapability -Online"
        foreach ($Item in $Name) {
            $WindowsCapability = Get-WindowsCapability -Online -Name "*$Item*" -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
            if ($WindowsCapability) {
                foreach ($Capability in $WindowsCapability) {
                    Write-Host -ForegroundColor DarkGray $Capability.DisplayName
                    $Capability | Add-WindowsCapability -Online | Out-Null
                }
            }
        }
    }
}
New-Alias -Name 'AddCapability' -Value 'osdcloud-AddCapability' -Description 'OSDCloud' -Force
function osdcloud-NetFX {
    [CmdletBinding()]
    param ()
    $WindowsCapability = Get-WindowsCapability -Online -Name "*NetFX*" -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
    if ($WindowsCapability) {
        Write-Host -ForegroundColor Cyan "Add-WindowsCapability NetFX"
        foreach ($Capability in $WindowsCapability) {
            Write-Host -ForegroundColor DarkGray $Capability.DisplayName
            $Capability | Add-WindowsCapability -Online | Out-Null
        }
    }
}
New-Alias -Name 'NetFX' -Value 'osdcloud-NetFX' -Description 'OSDCloud' -Force
function osdcloud-Rsat {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [Parameter(Mandatory,ParameterSetName='Basic')]
        [System.Management.Automation.SwitchParameter]$Basic,

        [Parameter(Mandatory,ParameterSetName='Full')]
        [System.Management.Automation.SwitchParameter]$Full,

        [Parameter(Mandatory,ParameterSetName='ByName',Position=0)]
        [System.String[]]$Name
    )
    if ($Basic) {
        $Name = @('ActiveDirectory','BitLocker','GroupPolicy','RemoteDesktop','VolumeActivation')
    }
    elseif ($Full) {
        $Name = 'Rsat'
    }
    elseif ($Name) {
        #Do Nothing
    }
    else {
        $Name = Get-WindowsCapability -Online -Name "*Rsat*" -ErrorAction SilentlyContinue | `
        Where-Object {$_.State -ne 'Installed'} | `
        Select-Object Name, DisplayName, Description | `
        Out-GridView -PassThru -Title 'Select one or more Rsat Capabilities to install' | `
        Select-Object -ExpandProperty Name
    }
    if ($Name) {
        Write-Host -ForegroundColor Cyan "Add-WindowsCapability -Online Rsat"
        foreach ($Item in $Name) {
            $WindowsCapability = Get-WindowsCapability -Online -Name "*$Item*" -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
            if ($WindowsCapability) {
                foreach ($Capability in $WindowsCapability) {
                    Write-Host -ForegroundColor DarkGray $Capability.DisplayName
                    $Capability | Add-WindowsCapability -Online | Out-Null
                }
            }
        }
    }
}
New-Alias -Name 'Rsat' -Value 'osdcloud-Rsat' -Description 'OSDCloud' -Force
#endregion
#=================================================
#region Update Functions
function osdcloud-UpdateDrivers {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor Cyan 'Updating Windows Drivers in a minimized window'
    if (!(Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore)) {
        try {
            Install-Module PSWindowsUpdate -Force -Scope CurrentUser -SkipPublisherCheck
            Import-Module PSWindowsUpdate -Force -Scope Global
        }
        catch {
            Write-Warning 'Unable to install PSWindowsUpdate Driver Updates'
        }
    }
    if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
        Start-Process -WindowStyle Minimized PowerShell.exe -ArgumentList "-Command Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot" -Wait
    }
}
New-Alias -Name 'UpdateDrivers' -Value 'osdcloud-UpdateDrivers' -Description 'OSDCloud' -Force
function osdcloud-UpdateWindows {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor Cyan 'Updating Windows in a minimized window'
    if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
        try {
            Install-Module PSWindowsUpdate -Force -Scope CurrentUser -SkipPublisherCheck
            Import-Module PSWindowsUpdate -Force -Scope Global
        }
        catch {
            Write-Warning 'Unable to install PSWindowsUpdate Windows Updates'
        }
    }
    if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
        #Write-Host -ForegroundColor DarkGray 'Add-WUServiceManager -MicrosoftUpdate -Confirm:$false'
        Add-WUServiceManager -MicrosoftUpdate -Confirm:$false | Out-Null
        #Write-Host -ForegroundColor DarkGray 'Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot'
        #Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
        #Write-Host -ForegroundColor DarkGray 'Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot'
        Start-Process -WindowStyle Minimized PowerShell.exe -ArgumentList "-Command Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle 'Preview' -NotKBArticleID 'KB890830','KB5005463','KB4481252'" -Wait
    }
}
New-Alias -Name 'UpdateWindows' -Value 'osdcloud-UpdateWindows' -Description 'OSDCloud' -Force
#endregion
#=================================================