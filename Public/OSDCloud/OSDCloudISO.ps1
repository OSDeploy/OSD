function New-OSDCloudISO {
    <#
    .SYNOPSIS
    Creates resources by using New-OSDCloudISO.

    .DESCRIPTION
    Provides the implementation for New-OSDCloudISO.

    .PARAMETER WorkspacePath
    Specifies the value for WorkspacePath.

    .EXAMPLE
    New-OSDCloudISO -WorkspacePath <WorkspacePath>
    Runs New-OSDCloudISO with common parameters.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Updated comment-based help

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        #Path to the OSDCloud Workspace containing the Media directory
        #This parameter is not necessary if Get-OSDCloudWorkspace can get a return
        [Parameter(Position=0,ValueFromPipelineByPropertyName)]
        [System.String]$WorkspacePath
    )
    #=================================================
    #	Block
    #=================================================
    Block-NoCurl
    Block-PowerShellVersionLt5
    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
        return
    }
    Block-WindowsVersionNe10
    Block-WinPE
    #=================================================
    #	Initialize
    #=================================================
    $isoFileName = 'OSDCloud.iso'
    $isoLabel = 'OSDCloud'
    $ErrorActionPreference = 'Stop'
    #=================================================
    #	WorkspacePath
    #=================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    $WorkspacePath = Get-OSDCloudWorkspace -ErrorAction Stop

    if (-NOT ($WorkspacePath)) {
        Write-Warning "[$(Get-Date -format s)] Unable to find an OSDCloud Workspace at $WorkspacePath"
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        Write-Warning "[$(Get-Date -format s)] Unable to find an OSDCloud Workspace at $WorkspacePath"
        Break
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "[$(Get-Date -format s)] Unable to find an OSDCloud WinPE at $WorkspacePath\Media\sources\boot.wim"
        Break
    }

    #region OSDeploy Compatibility
    if (Test-Path "$WorkspacePath\OSDeploy.iso") {
        $isoFileName = 'OSDeploy.iso'
        $isoLabel = 'OSDeploy'
    }
    #endregion
    #=================================================
    #   Create ISO
    #=================================================
    $NewADKiso = New-WindowsAdkISO -MediaPath "$WorkspacePath\Media" -isoFileName $isoFileName -isoLabel $isoLabel
    #=================================================
    #   Complete
    #=================================================
    #Write-Host -ForegroundColor Cyan "[$(Get-Date -format s)] New-OSDCloudISO is complete"
    #=================================================
}
