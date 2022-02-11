<#
.SYNOPSIS
Returns the Microsoft Surface DriverPacks

.DESCRIPTION
Returns the Microsoft Surface DriverPacks

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogMicrosoftDriverPack {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
#=================================================
#	BaseCatalog
#=================================================
$BaseCatalog = @'
[
    {
        "CatalogVersion":  "",
        "Name":  "Surface 3 WiFI",
        "Model":  "Surface 3",
        "Product":  "Surface_3",
        "PackageID": "49040",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface 3 LTE ATT",
        "Model":  "Surface 3",
        "Product":  "Surface_3_US1",
        "PackageID": "49039",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface 3 LTE Verizon",
        "Model":  "Surface 3",
        "Product":  "Surface_3_US2",
        "PackageID": "49037",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface 3 LTE North America",
        "Model":  "Surface 3",
        "Product":  "Surface_3_NAG",
        "PackageID": "49037",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface 3 LTE Rest of World",
        "Model":  "Surface 3",
        "Product":  "Surface_3_ROW",
        "PackageID": "49041",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Book",
        "Model":  "Surface Book",
        "Product":  "Surface_Book",
        "PackageID": "49497",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Book 2 15",
        "Model":  "Surface Book 2",
        "Product":  "Surface_Book_1793",
        "PackageID": "56261",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Book 2 13",
        "Model":  "Surface Book 2",
        "Product":  "Surface_Book_1832",
        "PackageID": "56261",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Book 3 15",
        "Model":  "Surface Book 3",
        "Product":  "Surface_Book_3_1899",
        "PackageID": "101315",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Book 3 13",
        "Model":  "Surface Book 3",
        "Product":  "Surface_Book_3_1900",
        "PackageID": "101315",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Go Commercial",
        "Model":  "Surface Go",
        "Product":  "Surface_Go_1824_Commercial",
        "PackageID": "57439",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Go Consumer",
        "Model":  "Surface Go",
        "Product":  "Surface_Go_1824_Consumer",
        "PackageID": "57439",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Go LTE Commercial",
        "Model":  "Surface Go",
        "Product":  "Surface_Go_1825_Commercial",
        "PackageID": "57601",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Go 2",
        "Model":  "Surface Go 2",
        "Product":  "Surface_Go_2_1927",
        "PackageID": "101304",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Go 3",
        "Model":  "Surface Go 3",
        "Product":  "Surface_Go_3",
        "PackageID": "103504",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Hub 2",
        "Model":  "Surface Hub 2",
        "Product":  "Surface_Hub_2",
        "PackageID": "101974",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Laptop",
        "Model":  "Surface Laptop",
        "Product":  "Surface_Laptop",
        "PackageID": "55489",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Laptop 2",
        "Model":  "Surface Laptop 2 Commercial",
        "Product":  "Surface_Laptop_2_1769_Commercial",
        "PackageID": "57515",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Laptop 2",
        "Model":  "Surface Laptop 2 Consumer",
        "Product":  "Surface_Laptop_2_1769_Consumer",
        "PackageID": "57515",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Laptop 3",
        "Model":  "Surface Laptop 3 13 Intel",
        "Product":  "Surface_Laptop_3_1867:1868",
        "PackageID": "100429",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Laptop 3",
        "Model":  "Surface Laptop 3 15 Intel",
        "Product":  "Surface_Laptop_3_1872",
        "PackageID": "100429",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Laptop 3",
        "Model":  "Surface Laptop 3 13 AMD",
        "Product":  "Surface_Laptop_3_1873",
        "PackageID": "100428",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Laptop 4",
        "Model":  "Surface Laptop 4 13 Intel",
        "Product":  "Surface_Laptop_4",
        "PackageID": "102924",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Laptop 4",
        "Model":  "Surface Laptop 4 13 AMD",
        "Product":  "Surface_Laptop_4",
        "PackageID": "102923",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Laptop Go",
        "Model":  "Surface Laptop Go",
        "Product":  "Surface_Laptop_Go_1943",
        "PackageID": "102261",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Laptop Studio",
        "Model":  "Surface Laptop Studio",
        "Product":  "Surface_Laptop_Studio",
        "PackageID": "103505",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro",
        "Model":  "Surface Pro",
        "Product":  "Surface_Pro",
        "PackageID": "49038",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro 2",
        "Model":  "Surface Pro 2",
        "Product":  "Surface_Pro_2",
        "PackageID": "49042",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro 3",
        "Model":  "Surface Pro 3",
        "Product":  "Surface_Pro_3",
        "PackageID": "38826",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro 4",
        "Model":  "Surface Pro 4",
        "Product":  "Surface_Pro_4",
        "PackageID": "49498",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro (5th Gen)",
        "Model":  "Surface Pro",
        "Product":  "Surface_Pro_1796",
        "PackageID": "55484",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro with LTE Advanced",
        "Model":  "Surface Pro",
        "Product":  "Surface_Pro_1807",
        "PackageID": "56278",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro 6",
        "Model":  "Surface Pro 6",
        "Product":  "Surface_Pro_6_1796_Commercial",
        "PackageID": "57514",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro 6",
        "Model":  "Surface Pro 6",
        "Product":  "Surface_Pro_6_1796_Consumer",
        "PackageID": "57514",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro 7",
        "Model":  "Surface Pro 7",
        "Product":  "Surface_Pro_7_1866",
        "PackageID": "100419",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro 7+",
        "Model":  "Surface Pro 7+",
        "Product":  "Surface_Pro_7+_1960",
        "PackageID": "102633",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro 7+",
        "Model":  "Surface Pro 7+",
        "Product":  "Surface_Pro_7+_with_LTE_Advanced_1961",
        "PackageID": "102633",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Pro 8",
        "Model":  "Surface Pro 8",
        "Product":  "Surface_Pro_8",
        "PackageID": "103503",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Studio",
        "Model":  "Surface Studio",
        "Product":  "Surface_Studio",
        "PackageID": "54311",
        "DriverPackUrl": "",
        "FileName":  ""
    },
    {
        "CatalogVersion":  "",
        "Name":  "Surface Studio 2",
        "Model":  "Surface Studio 2",
        "Product":  "Surface_Studio_2",
        "PackageID": "57593",
        "DriverPackUrl": "",
        "FileName":  ""
    }
]
'@
	#=================================================
	#	Reference
	#=================================================
	#https://docs.microsoft.com/en-us/surface/surface-system-sku-reference
	#=================================================
	#   Paths
	#=================================================
	$UseCatalog           = 'Offline' #Cloud, Build, Local, Offline
	$DownloadsBaseUrl 		= 'https://www.microsoft.com/en-us/download/confirmation.aspx?id='
	$CloudCatalogUri      = 'https://support.microsoft.com/en-us/surface/download-drivers-and-firmware-for-surface-09bb2e09-2a4b-cb69-0951-078a7739e120'
	#$RawCatalogFile       = Join-Path $env:TEMP 'CatalogPC.xml'
	$BuildCatalogFile  		= Join-Path $env:TEMP 'CatalogMicrosoftDriverPack.json'
	$OfflineCatalogFile     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\CatalogMicrosoftDriverPack.json"
	#$RawCatalogCabName  	= [string]($CloudCatalogUri | Split-Path -Leaf)
	#$RawCatalogCabPath 	= Join-Path $env:TEMP $RawCatalogCabName
    #=================================================
    #   Test UseCatalog Local
    #=================================================
	if ($UseCatalog -ne 'Offline') {
        if (Test-Path $BuildCatalogFile) {
            Write-Verbose "Testing $BuildCatalogFile"

            #Get-Item to determine the age
            $GetItemBuildCatalogFile = Get-Item $BuildCatalogFile

            #If the local is older than 12 hours, delete it
            if (((Get-Date) - $GetItemBuildCatalogFile.LastWriteTime).TotalHours -gt 12) {
                Write-Verbose "Removing previous Offline Catalog"
            }
            else {
                $UseCatalog = 'Local'
                Write-Verbose "UseCatalog: $UseCatalog"
            }
        }
    }
    #=================================================
    #   Test Cloud Catalog
    #=================================================
	if ($UseCatalog -eq 'Cloud') {
		if (Test-WebConnection -Uri $CloudCatalogUri) {
			#Catalog is Cloud and can be downloaded
		}
		else {
			$UseCatalog = 'Offline'
		}
	}
    #=================================================
    #   UseCatalog Cloud
    #=================================================
	if ($UseCatalog -eq 'Cloud') {
		$Results = $BaseCatalog | ConvertFrom-Json
	
		foreach ($Item in $Results) {
			Write-Verbose "Processing $($Item.Name)"
			$Item.CatalogVersion = Get-Date -Format yy.MM.dd
	
			$DriverPage = $DownloadsBaseUrl + $Item.PackageID
			$Downloads = (Invoke-WebRequest -Uri $DriverPage -UseBasicParsing).Links
			$Downloads = $Downloads | Where-Object {$_.href -match 'download.microsoft.com'}
			$Downloads = $Downloads | Where-Object {($_.href -match 'Win11') -or ($_.href -match 'Win10')}
			$Downloads = $Downloads | Sort-Object href | Select-Object href -Unique
			$Downloads = $Downloads | Select-Object -Last 1
	
			$Item.DriverPackUrl = ($Downloads).href
	
			$Item.FileName = Split-Path $Item.DriverPackUrl -Leaf
			$Results | ConvertTo-Json | Out-File $BuildCatalogFile -Encoding ascii -Width 2000 -Force
		}

		if (Test-Path $BuildCatalogFile) {
			$UseCatalog = 'Local'
		}
		else {
			Write-Verbose "Could not locate $BuildCatalogFile"
			$UseCatalog = 'Offline'
		}
	}
    #=================================================
    #   UseCatalog Local
    #=================================================
	if ($UseCatalog -eq 'Local') {
		Write-Verbose "Reading the Local System Catalog at $BuildCatalogFile"
		$Results = Get-Content -Path $BuildCatalogFile | ConvertFrom-Json
	}
    #=================================================
    #   UseCatalog Offline
    #=================================================
	if ($UseCatalog -eq 'Offline') {
		Write-Verbose "Reading the Offline System Catalog at $OfflineCatalogFile"
		$Results = Get-Content -Path $OfflineCatalogFile | ConvertFrom-Json
	}
    #=================================================
    #   Compatible
    #=================================================
	if ($PSBoundParameters.ContainsKey('Compatible')) {
		$MyComputerProduct = Get-MyComputerProduct
		Write-Verbose "Filtering XML for items compatible with Product $MyComputerProduct"
		$Results = $Results | Where-Object {$_.Product -contains $MyComputerProduct}
	}
    #=================================================
    #   Results
    #=================================================
    $Results | Sort-Object -Property Product
    #=================================================
}