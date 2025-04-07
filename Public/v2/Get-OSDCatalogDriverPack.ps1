function Get-OSDCatalogDriverPack {
    <#
    .SYNOPSIS
    Gets the OSDCloud DriverPack for the current or specified computer model

    .DESCRIPTION
    Gets the OSDCloud DriverPack for the current or specified computer model

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.String]
        #Product is determined automatically by Get-MyComputerProduct
        $Product = (Get-MyComputerProduct),

        [System.String]
        [ValidateSet('Windows 11','Windows 10')]
        $OSVersion,

        [System.String]
        $OSReleaseID
    )
    $ProductDriverPacks = Get-OSDCatalogDriverPacks | Where-Object {($_.Product -contains $Product)}
    #=================================================
    #   Results
    #=================================================
    if ($ProductDriverPacks) {
        if ($OSVersion) {
            $OSVersionDriverPacks = $ProductDriverPacks | Where-Object { $_.OS -match $OSVersion}
            if (-NOT $OSVersionDriverPacks) {
                $OSVersionDriverPacks = $ProductDriverPacks
            }
        }
        else {
            $OSVersionDriverPacks = $ProductDriverPacks
        }

        if ($OSReleaseID) {
            $OSReleaseIDDriverPacks = $OSVersionDriverPacks | Where-Object { $_.Name -match $OSReleaseID}
            if (-NOT $OSReleaseIDDriverPacks) {
                $OSReleaseIDDriverPacks = $OSVersionDriverPacks
            }
        }
        else {
            $OSReleaseIDDriverPacks = $OSVersionDriverPacks
        }
        $Results = $OSReleaseIDDriverPacks | Sort-Object -Property Name -Descending
        $Results[0]
    }
    else {
        Write-Verbose "Product $Product is not supported"
    }
    #=================================================
}