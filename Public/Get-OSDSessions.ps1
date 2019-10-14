<#
.SYNOPSIS
Returns the Session.xml Updates that have been applied to an Operating System

.DESCRIPTION
Returns the Session.xml Updates that have been applied to an Operating System

.LINK
https://osd.osdeploy.com/module/functions/get-osdsessions

.NOTES
19.10.14     David Segura @SeguraOSD Initial Release
#>
function Get-OSDSessions {
    [CmdletBinding()]
    Param (
        #Path of the Sessions.xml file
        [string]$Path = "$env:SystemRoot\Servicing\Sessions\Sessions.xml"
    )
    if (!(Test-Path "$Path")) {
        Write-Warning "Cannot find Sessions.xml at $Path"
        Break
    }

	[xml]$XmlDocument = Get-Content -Path "$Path"

    $OSDSessions = $XmlDocument.SelectNodes('Sessions/Session') | ForEach-Object {
        New-Object -Type PSObject -Property @{
            Complete = $_.Complete
            KBNumber = $_.Tasks.Phase.package.name
            TargetState = $_.Tasks.Phase.package.targetState
            Id = $_.Tasks.Phase.package.id
            Client = $_.Client
            Status = $_.Status
        }
    }

    $OSDSessions = $OSDSessions | Where-Object {$_.Id -like "Package*"}
    $OSDSessions = $OSDSessions | Select-Object -Property Complete, KBNumber, TargetState, Id, Client, Status | Sort-Object Complete

    #if ($GridView.IsPresent) {$OSDSessions = $OSDSessions | Select-Object -Property * | Out-GridView -PassThru -Title 'Select Updates'}
    Return $OSDSessions
}