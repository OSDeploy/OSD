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
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$WorkspacePath
    )

    #===============================================================================================
    #	Start the Clock
    #===============================================================================================
    $WorkspaceStartTime = Get-Date
    #==================================================================================================
    #	Require WinOS
    #==================================================================================================
    if ((Get-OSDGather -Property IsWinPE)) {
        Write-Warning "$($MyInvocation.MyCommand) cannot be run from WinPE"
        Break
    }
    #===============================================================================================
    #   Require Admin Rights
    #===============================================================================================
    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
        Break
    }
    #===============================================================================================
    #   Require cURL
    #===============================================================================================
    if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
        Write-Warning "$($MyInvocation.MyCommand) could not find $env:SystemRoot\System32\curl.exe"
        Write-Warning "Get a newer Windows version!"
        Break
    }
    #===============================================================================================
    #	Set VerbosePreference
    #===============================================================================================
    #$CurrentVerbosePreference = $VerbosePreference
    #$VerbosePreference = 'Continue'
    #===============================================================================================
    #	Get-OSDCloud.template
    #===============================================================================================
    if (-NOT (Get-OSDCloud.template)) {
        Write-Warning "Setting up a new OSDCloud.template"
        New-OSDCloud.template -Verbose
    }

    $OSDCloudTemplate = Get-OSDCloud.template
    if (-NOT ($OSDCloudTemplate)) {
        Write-Warning "Something bad happened.  I have to go"
        Break
    }
    #===============================================================================================
    #	Set WorkspacePath
    #===============================================================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloud.workspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    #===============================================================================================
    #	Setup Workspace
    #===============================================================================================
    if (-NOT (Test-Path $WorkspacePath)) {
        New-Item -Path $WorkspacePath -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    robocopy "$OSDCloudTemplate" "$WorkspacePath" *.* /e /ndl /xj /ndl /np /nfl /njh /njs /xf workspace.json
    #===============================================================================================
    #   Restore VerbosePreference
    #===============================================================================================
    #$VerbosePreference = $CurrentVerbosePreference
    #===============================================================================================
    #	Complete
    #===============================================================================================
    $WorkspaceEndTime = Get-Date
    $WorkspaceTimeSpan = New-TimeSpan -Start $WorkspaceStartTime -End $WorkspaceEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($WorkspaceTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #===============================================================================================
    #	Return
    #===============================================================================================
    Write-Host -ForegroundColor Cyan        "OSDCloud Workspace created at $WorkspacePath"
    Write-Host -ForegroundColor Cyan        "Get-OSDCloud.workspace will return your last used WorkspacePath"

    #explorer $WorkspacePath
    #Return $WorkspacePath
    #===============================================================================================
}