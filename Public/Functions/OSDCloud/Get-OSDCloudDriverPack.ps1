function Get-OSDCloudDriverPack {
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
        [System.String]$Product = (Get-MyComputerProduct)
    )
    $Results = Get-OSDCloudDriverPackList | Where-Object {($_.Product -contains $Product)}
    #=================================================
    #   Results
    #=================================================
    if ($Results) {
        $Results = $Results | Sort-Object -Property OS -Descending
        $Results[0]
    }
    else {
        Write-Warning "Product $Product is not supported"
    }
    #=================================================
}