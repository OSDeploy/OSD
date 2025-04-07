<#
.SYNOPSIS
Builds the Dell System Catalog

.DESCRIPTION
Builds the Dell System Catalog

.EXAMPLE
Get-DellSystemCatalog
Don't do this, you will get an almost endless list

.EXAMPLE
$Result = Get-DellSystemCatalog
Yes do this.  Save it in a Variable

.EXAMPLE
Get-DellSystemCatalog -Component BIOS | Out-GridView
Displays all the Dell BIOS Updates in GridView

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-DellSystemCatalog {
    [CmdletBinding()]
    param (
        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible,

        #Limits the results to a specified component
        [ValidateSet('Application','BIOS','Driver','Firmware')]
        [System.String]
        $Component,

        #Specifies a download path for matching results displayed in Out-GridView
        [System.String]
        $DownloadPath
    )
    #=================================================
    #   Import Catalog
    #=================================================
    $CatalogFile = "$(Get-OSDCatalogsPath)\dell\build-system.xml"
    Write-Verbose "Importing the Offline Catalog at $CatalogFile"
    $Results = Import-Clixml -Path $CatalogFile
    #=================================================
    #   Compatible
    #=================================================
    if ($PSBoundParameters.ContainsKey('Compatible')) {
        $MyComputerProduct = Get-MyComputerProduct
        Write-Verbose "Filtering Catalog for items compatible with Product $MyComputerProduct"
        $Results = $Results | Where-Object {$_.SupportedSystemID -contains $MyComputerProduct}
    }
    #=================================================
    #   Component
    #=================================================
    if ($PSBoundParameters.ContainsKey('Component')) {
        Write-Verbose "Filtering Catalog for $Component"
        $Results = $Results | Where-Object {$_.Component -eq $Component}
    }
    #=================================================
    #   DownloadPath
    #=================================================
    if ($PSBoundParameters.ContainsKey('DownloadPath')) {
        $Results = $Results | Out-GridView -Title 'Select one or more files to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            $OutFile = Save-WebFile -SourceUrl $Item.Url -DestinationDirectory $DownloadPath -DestinationName $Item.FileName -Verbose
            $Item | ConvertTo-Json | Out-File "$($OutFile.FullName).json" -Encoding ascii -Width 2000 -Force
        }
    }
    #=================================================
    #   Complete
    #=================================================
    $Results
    #=================================================
}