<#
.SYNOPSIS
Displays information about the OSD Module

.DESCRIPTION
Displays information about the OSD Module

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
#>
function Get-OSD {
<#
.SYNOPSIS
Gets OSD information.

.DESCRIPTION
Returns OSD data for the current system or OSD session context.

.EXAMPLE
Get-OSD
Demonstrates a common way to run Get-OSD.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param ()
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Module and Command Information
    #=================================================
    $GetCommandName = $MyInvocation.MyCommand | Select-Object -ExpandProperty Name
    $GetModuleBase = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty ModuleBase
    $GetModulePath = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty Path
    $GetModuleVersion = $MyInvocation.MyCommand.Module | Select-Object -ExpandProperty Version
    $GetCommandHelpUri = Get-Command -Name $GetCommandName | Select-Object -ExpandProperty HelpUri

    Write-Host "$GetCommandName" -ForegroundColor Cyan -NoNewline
    Write-Host " $GetModuleVersion at $GetModuleBase" -ForegroundColor Gray
    Write-Host "http://osd.osdeploy.com" -ForegroundColor Gray
    Write-Host -ForegroundColor DarkCyan    "======================================================================="
    Write-Host -ForegroundColor Cyan        'Update the OSD Module: ' -NoNewline
    Write-Host -ForegroundColor Yellow      'Update-Module OSD -Force'
    Write-Host -ForegroundColor DarkCyan    "======================================================================="
    Write-Host -ForegroundColor Cyan        'OSD Module Functions:'
    Write-Host -ForegroundColor DarkCyan    "======================================================================="
    #=================================================
    #	Function Information
    #=================================================
    Get-Command -Module OSD | Where-Object {$_.CommandType -eq 'Function'} | Sort-Object Name | Select-Object Name
    #=================================================
}
