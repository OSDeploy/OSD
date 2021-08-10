<#
.SYNOPSIS
Creates an .iso file in the OSDCloud Workspace.  ADK is required

.Description
Creates an .iso file in the OSDCloud Workspace.  ADK is required

.PARAMETER WorkspacePath
Path of the OSDCloud Workspace. This is optional

.LINK
https://osdcloud.osdeploy.com
#>
function New-OSDCloud.iso {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$WorkspacePath
    )
    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $IsoStartTime = Get-Date
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)"
    #=======================================================================
    #	Block
    #=======================================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=======================================================================
    #	Set Variables
    #=======================================================================
    $isoFileName = 'OSDCloud.iso'
    $isoLabel = 'OSDCloud'
    #=======================================================================
    #	Get-OSDCloud.template
    #=======================================================================
    if (-NOT (Get-OSDCloud.template)) {
        Write-Warning "Setting up a new OSDCloud.template"
        New-OSDCloud.template -Verbose
    }

    $OSDCloudTemplate = Get-OSDCloud.template
    if (-NOT ($OSDCloudTemplate)) {
        Write-Warning "Something bad happened.  I have to go"
        Break
    }
    #=======================================================================
    #	Get-OSDCloud.workspace
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloud.workspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    $WorkspacePath = Get-OSDCloud.workspace -ErrorAction Stop
    #=======================================================================
    #	Setup Workspace
    #=======================================================================
    if (-NOT ($WorkspacePath)) {
        Write-Warning "You need to provide a path to your Workspace with one of the following examples"
        Write-Warning "New-OSDCloud.workspace -WorkspacePath C:\OSDCloud"
        Write-Warning "New-OSDCloud.iso -WorkspacePath C:\OSDCloud"
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        New-OSDCloud.workspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media")) {
        New-OSDCloud.workspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "Nothing is going well for you today my friend"
        Break
    }
    #=======================================================================
    #   Create ISO
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating ISO"
    Write-Host -ForegroundColor Yellow "OSD Function: New-ADK.iso"
    $NewADKiso = New-ADK.iso -MediaPath "$WorkspacePath\Media" -isoFileName $isoFileName -isoLabel $isoLabel
    #=======================================================================
    #	Complete
    #=======================================================================
    $IsoEndTime = Get-Date
    $IsoTimeSpan = New-TimeSpan -Start $IsoStartTime -End $IsoEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($IsoTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    Write-Host -ForegroundColor Cyan        "OSDCloud ISO created at $($NewADKiso.FullName)"
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    #=======================================================================
}