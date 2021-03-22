<#
.SYNOPSIS
Creates an .iso file in the OSDCloud Workspace.  ADK is required

.Description
Creates an .iso file in the OSDCloud Workspace.  ADK is required

.LINK
https://osdcloud.osdeploy.com

.NOTES
21.3.22     Function changed to creating ISO only, no editing of the WIM
21.3.16     Initial Release
#>
function New-OSDCloud.iso {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$WorkspacePath
    )
    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $IsoStartTime = Get-Date
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
        Write-Warning "New-OSDCloud.iso -WorkspacePath C:\OSDCloud"
        Write-Warning "New-OSDCloud.workspace -WorkspacePath C:\OSDCloud"
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
    $NewADKiso = New-ADK.iso -MediaPath "$WorkspacePath\Media" -isoFileName $isoFileName -isoLabel $isoLabel
    #=======================================================================
    #   Restore VerbosePreference
    #=======================================================================
    $VerbosePreference = $CurrentVerbosePreference
    #=======================================================================
    #	Complete
    #=======================================================================
    $IsoEndTime = Get-Date
    $IsoTimeSpan = New-TimeSpan -Start $IsoStartTime -End $IsoEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($IsoTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=======================================================================
    #	Return
    #=======================================================================
    Write-Host -ForegroundColor Cyan        "OSDCloud ISO created at $($NewADKiso.FullName)"
    #Write-Host -ForegroundColor Cyan        "OSDCloud ISO Get-Item is saved in the Global Variable OSDCloudISO"

    #explorer $WorkspacePath
    #Return (Get-Item -Path $NewADKiso.FullName | Select-Object -Property *)
    #Return $NewADKiso.FullName
    #=======================================================================


}