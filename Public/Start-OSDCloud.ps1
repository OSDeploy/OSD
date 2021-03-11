<#
.SYNOPSIS
Executes a PowerShell Script in a GitHub Repository

.DESCRIPTION
Executes a PowerShell Script in a GitHub Repository
Parameters build the Url that will be Invoked
https://raw.githubusercontent.com/$User/$Repository/$Branch/$Script

.PARAMETER User
Default = OSDeploy

.PARAMETER Repository
Default = OSDCloud

.PARAMETER Branch
Default = main

.PARAMETER Script
Default = Start-OSDCloud.ps1

.PARAMETER Token
Default = ''
Used to access a GitHub Private Repository

.LINK
https://osdcloud.osdeploy.com/functions/start-osdcloud

.NOTES
21.3.10 Added additional parameters
21.3.9  Initial Release
#>
function Start-OSDCloud {
    [CmdletBinding()]
    param (
        [Alias('U','GitHubUser')]
        [string]$User = 'OSDeploy',

        [Alias('R','GitHubRepository')]
        [string]$Repository = 'OSDCloud',

        [Alias('B','GitHubBranch')]
        [string]$Branch = 'main',

        [Alias('S','GitHubScript')]
        [string]$Script = 'Start-OSDCloud.ps1',

        [Alias('T','GitHubToken')]
        [string]$Token = ''
    )
    #======================================================================================================
    #	Set Global Variables
    #======================================================================================================
    $Global:GitHubBase = 'https://raw.githubusercontent.com'

    if ($PSBoundParameters['Token']) {
        $Global:GitHubUrl = "$Global:GitHubBase/$User/$Repository/$Branch/$Script`?token=$Token"
    } else {
        $Global:GitHubUrl = "$Global:GitHubBase/$User/$Repository/$Branch/$Script"
    }

    $Global:GitHubUser = $User
    $Global:GitHubRepository = $Repository
    $Global:GitHubBranch = $Branch
    $Global:GitHubScript = $Script
    $Global:GitHubToken = $Token

    Write-Verbose "Url: $Global:GitHubUrl"
    
    Try {
        Invoke-UrlExpression -Url $Global:GitHubUrl -ErrorAction Stop
    }
    Catch {
        Write-Warning "Could not connect to OSDCloud"
        Write-Warning $Global:GitHubUrl
    }
}