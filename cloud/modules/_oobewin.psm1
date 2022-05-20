<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module should be loaded in OOBE and Windows
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobewin.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobewin.psm1')
#>
#=================================================
#region Functions
function osdcloud-InstallScriptAutopilot {
    [CmdletBinding()]
    param ()
    $InstalledScript = Get-InstalledScript -Name Get-WindowsAutoPilotInfo -ErrorAction SilentlyContinue
    if (-not $InstalledScript) {
        Write-Host -ForegroundColor DarkGray 'Install-Script Get-WindowsAutoPilotInfo [AllUsers]'
        Install-Script -Name Get-WindowsAutoPilotInfo -Force -Scope AllUsers
    }
}
#endregion
#=================================================