<#
.SYNOPSIS
Returns the Session.xml Updates that have been applied to an Operating System

.DESCRIPTION
Returns the Session.xml Updates that have been applied to an Operating System

.LINK
https://osd.osdeploy.com/module/functions/general/get-osdsessions

.NOTES
19.11.20    Added Pipeline Support
19.11.20    Path now supports Mounted WIM Path
19.10.14    David Segura @SeguraOSD Initial Release
#>
function Get-SessionsXml {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        #Specifies the full path to the root directory of the offline Windows image that you will service
        #Or Path of the Sessions.xml file
        #If this value is not set, the running OS Sessions.xml will be processed
        [string]$Path = "$env:SystemRoot\Servicing\Sessions\Sessions.xml",

        #Returns the KBNumber
        [string]$KBNumber
    )
    begin {}
    process {
        #===================================================================================================
        #   Set Sessions.xml
        #===================================================================================================
        $SessionsXml = $Path
        #===================================================================================================
        #   Mount Path
        #===================================================================================================
        if ($SessionsXml -notmatch 'Sessions.xml') {$SessionsXml = "$Path\Windows\Servicing\Sessions\Sessions.xml"}
        #===================================================================================================
        #   Test-Path
        #===================================================================================================
        if (!(Test-Path "$SessionsXml")) {Write-Warning "Cannot find Sessions.xml at $Path"; Break}
        Write-Verbose $SessionsXml
        #===================================================================================================
        #   Process Sessions.xml
        #===================================================================================================
        [xml]$XmlDocument = Get-Content -Path "$SessionsXml"
    
        $SessionsXml = $XmlDocument.SelectNodes('Sessions/Session') | ForEach-Object {
            New-Object -Type PSObject -Property @{
                Complete = $_.Complete
                KBNumber = $_.Tasks.Phase.package.name
                TargetState = $_.Tasks.Phase.package.targetState
                Id = $_.Tasks.Phase.package.id
                Client = $_.Client
                Status = $_.Status
            }
        }
    
        $SessionsXml = $SessionsXml | Where-Object {$_.Id -like "Package*"}
        $SessionsXml = $SessionsXml | Select-Object -Property Complete, KBNumber, TargetState, Id, Client, Status | Sort-Object Complete
        #===================================================================================================
        #   KBNumber
        #===================================================================================================
        if ($KBNumber) {$SessionsXml = $SessionsXml | Where-Object {$_.KBNumber -match $KBNumber}}
        #===================================================================================================
        #   Return $SessionsXml
        #===================================================================================================
        #if ($GridView.IsPresent) {$SessionsXml = $SessionsXml | Select-Object -Property * | Out-GridView -PassThru -Title 'Select Updates'}
        Return $SessionsXml
    }
    end {}
}