<#
.SYNOPSIS
Converts the HP Platform list to a PowerShell Object. Useful to get the computer model name for System Ids

.DESCRIPTION
Converts the HP Platform list to a PowerShell Object. Useful to get the computer model name for System Ids
Requires Internet Access to download platformList.cab

.EXAMPLE
Get-HPPlatformCatalog
Don't do this, you will get a big list.

.EXAMPLE
$Results = Get-HPPlatformCatalog
Yes do this.  Save it in a Variable

.EXAMPLE
Get-HPPlatformCatalog | Out-GridView
Displays all the HP System Ids with the applicable computer model names in GridView

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-HPPlatformCatalog {
    [CmdletBinding()]
    param ()
    #=================================================
    #   Import Catalog
    #=================================================
    $CatalogFile = "$(Get-OSDCatalogsPath)\hp\build-platform.xml"
    Write-Verbose "Importing the Offline Catalog at $CatalogFile"
    $Results = Import-Clixml -Path $CatalogFile
    #=================================================
    #   Complete
    #=================================================
    $Results | Sort-Object -Property SystemId
    #=================================================
}