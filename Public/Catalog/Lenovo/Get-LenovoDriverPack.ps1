function Get-LenovoDriverPack {
    [CmdletBinding()]
    param (
		[switch]$Compatible,
        [System.String]$DownloadPath
    )
    $Results = Get-CatalogLenovoDriverPack
	if ($Compatible) {
		$MyComputerProduct = Get-MyComputerProduct
		Write-Verbose "Filtering results for items compatible with Product $MyComputerProduct"
		$Results = $Results | Where-Object {$_.Product -contains $MyComputerProduct}
        if ($DownloadPath) {
            foreach ($Item in $Results) {
                Save-MyDriverPack -Manufacturer Lenovo -Product $Item.Product[0] -DownloadPath $DownloadPath
            }
        }
        else {
            $Results
        }
	}
    elseif ($DownloadPath) {
        $Results = $Results | Out-GridView -Title 'Select one or more files to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            Save-MyDriverPack -Manufacturer Lenovo -Product $Item.Product[0] -DownloadPath $DownloadPath
        }
    }
    else {
        $Results
    }
}