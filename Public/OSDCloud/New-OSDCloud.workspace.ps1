<#
.SYNOPSIS
Creates an OSDCloud Workspace

.Description
Creates an OSDCloud Workspace

.PARAMETER WorkspacePath
Directory for the Workspace to contain the Media directory and the .iso file

.LINK
https://osdcloud.osdeploy.com

.NOTES
21.3.17     Initial Release
#>
function New-OSDCloud.workspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$WorkspacePath
    )
    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $WorkspaceStartTime = Get-Date
    #=======================================================================
    #	Blocks
    #=======================================================================
    Block-WinPE
    Block-StandardUser
	  Block-NoCurl
    #=======================================================================
    #	Get-OSDCloud.template
    #=======================================================================
    if (!(Get-OSDCloud.template)) {
        Write-Warning "Setting up a new OSDCloud.template"
        New-OSDCloud.template -Verbose
    }

    $OSDCloudTemplate = Get-OSDCloud.template
    if (!($OSDCloudTemplate)) {
        Write-Warning "Something bad happened.  I have to go"
        Break
    }
    #=======================================================================
    #	Set WorkspacePath
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloud.workspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    #=======================================================================
    #	Setup Workspace
    #=======================================================================
    if (!(Test-Path $WorkspacePath)) {
        New-Item -Path $WorkspacePath -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    robocopy "$OSDCloudTemplate" "$WorkspacePath" *.* /e /xj /np /ndl /nfl /njh /njs /r:0 /w:0 /xf workspace.json
    robocopy "$OSDCloudTemplate\Media" "$WorkspacePath\Media" *.* /mir /xj /np /ndl /nfl /njh /njs /r:0 /w:0
    #=======================================================================
    #	Complete
    #=======================================================================
    $WorkspaceEndTime = Get-Date
    $WorkspaceTimeSpan = New-TimeSpan -Start $WorkspaceStartTime -End $WorkspaceEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($WorkspaceTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=======================================================================
    #	Return
    #=======================================================================
    Write-Host -ForegroundColor Cyan        "OSDCloud Workspace created at $WorkspacePath"
    Write-Host -ForegroundColor Cyan        "Get-OSDCloud.workspace will return your last used WorkspacePath"
    #=======================================================================
}