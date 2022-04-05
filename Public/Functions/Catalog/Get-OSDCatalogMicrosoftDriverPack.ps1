<#
.SYNOPSIS
Returns the Microsoft Surface DriverPacks

.DESCRIPTION
Returns the Microsoft Surface DriverPacks

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-OSDCatalogMicrosoftDriverPack {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Compatible,
        [System.String]$DownloadPath,
        [System.Management.Automation.SwitchParameter]$Force
    )
#=================================================
#	OSDCatalog
#   https://docs.microsoft.com/en-us/surface/manage-surface-driver-and-firmware-updates
#   https://docs.microsoft.com/en-us/surface/surface-system-sku-reference
#   https://www.reddit.com/r/Surface/comments/mlhqw5/all_direct_download_links_for_surface/
#=================================================
$OSDCatalog = @'
[
    {
        "Name":  "Surface 3 WiFi",
        "Model":  "Surface 3",
        "Product":  "Surface_3",
        "PackageID": "49040"
    },
    {
        "Name":  "Surface 3 LTE ATT",
        "Model":  "Surface 3",
        "Product":  "Surface_3_US1",
        "PackageID": "49039"
    },
    {
        "Name":  "Surface 3 LTE Verizon",
        "Model":  "Surface 3",
        "Product":  "Surface_3_US2",
        "PackageID": "49037"
    },
    {
        "Name":  "Surface 3 LTE North America",
        "Model":  "Surface 3",
        "Product":  "Surface_3_NAG",
        "PackageID": "49037"
    },
    {
        "Name":  "Surface 3 LTE Rest of World",
        "Model":  "Surface 3",
        "Product":  "Surface_3_ROW",
        "PackageID": "49041"
    },
    {
        "Name":  "Surface Book",
        "Model":  "Surface Book",
        "Product":  "Surface_Book",
        "PackageID": "49497"
    },
    {
        "Name":  "Surface Book 2 13",
        "Model":  "Surface Book 2",
        "Product":  "Surface_Book_1832",
        "PackageID": "56261"
    },
    {
        "Name":  "Surface Book 2 15",
        "Model":  "Surface Book 2",
        "Product":  "Surface_Book_1793",
        "PackageID": "56261"
    },
    {
        "Name":  "Surface Book 3 13",
        "Model":  "Surface Book 3",
        "Product":  "Surface_Book_3_1900",
        "PackageID": "101315"
    },
    {
        "Name":  "Surface Book 3 15",
        "Model":  "Surface Book 3",
        "Product":  "Surface_Book_3_1899",
        "PackageID": "101315"
    },
    {
        "Name":  "Surface Go Commercial",
        "Model":  "Surface Go",
        "Product":  "Surface_Go_1824_Commercial",
        "PackageID": "57439"
    },
    {
        "Name":  "Surface Go Consumer",
        "Model":  "Surface Go",
        "Product":  "Surface_Go_1824_Consumer",
        "PackageID": "57439"
    },
    {
        "Name":  "Surface Go LTE Commercial",
        "Model":  "Surface Go",
        "Product":  "Surface_Go_1825_Commercial",
        "PackageID": "57601"
    },
    {
        "Name":  "Surface Go 2 Commercial",
        "Model":  "Surface Go 2",
        "Product":  "Surface_Go_2_1926",
        "PackageID": "101304"
    },
    {
        "Name":  "Surface Go 2 Consumer",
        "Model":  "Surface Go 2",
        "Product":  "Surface_Go_2_1901",
        "PackageID": "101304"
    },
    {
        "Name":  "Surface Go 2 LTE",
        "Model":  "Surface Go 2",
        "Product":  "Surface_Go_2_1927",
        "PackageID": "101304"
    },
    {
        "Name":  "Surface Go 3 Commercial",
        "Model":  "Surface Go 3",
        "Product":  "Surface_Go_3_1926",
        "PackageID": "103504"
    },
    {
        "Name":  "Surface Go 3 Consumer",
        "Model":  "Surface Go 3",
        "Product":  "Surface_Go_3_1901",
        "PackageID": "103504"
    },
    {
        "Name":  "Surface Go 3 LTE",
        "Model":  "Surface Go 3",
        "Product":  "Surface_Go_3_2022",
        "PackageID": "103504"
    },
    {
        "Name":  "Surface Hub 2",
        "Model":  "Surface Hub 2",
        "Product":  "Surface_Hub_2",
        "PackageID": "101974"
    },
    {
        "Name":  "Surface Hub 2S 50",
        "Model":  "Surface Hub 2S",
        "Product":  "Surface Hub 2S",
        "PackageID": "101974"
    },
    {
        "Name":  "Surface Hub 2S 85",
        "Model":  "Surface Hub 2S",
        "Product":  "Surface Hub 2S 85",
        "PackageID": "101974"
    },
    {
        "Name":  "Surface Laptop",
        "Model":  "Surface Laptop",
        "Product":  "Surface_Laptop",
        "PackageID": "55489"
    },
    {
        "Name":  "Surface Laptop 2 Commercial",
        "Model":  "Surface Laptop 2",
        "Product":  "Surface_Laptop_2_1769_Commercial",
        "PackageID": "57515"
    },
    {
        "Name":  "Surface Laptop 2 Consumer",
        "Model":  "Surface Laptop 2",
        "Product":  "Surface_Laptop_2_1769_Consumer",
        "PackageID": "57515"
    },
    {
        "Name":  "Surface Laptop 3 13 Intel",
        "Model":  "Surface Laptop 3",
        "Product":  "Surface_Laptop_3_1867:1868",
        "PackageID": "100429"
    },
    {
        "Name":  "Surface Laptop 3 13 AMD",
        "Model":  "Surface Laptop 3",
        "Product":  "Surface_Laptop_3_1873",
        "PackageID": "100428"
    },
    {
        "Name":  "Surface Laptop 3 15 Intel",
        "Model":  "Surface Laptop 3",
        "Product":  "Surface_Laptop_3_1872",
        "PackageID": "100429"
    },
    {
        "Name":  "Surface Laptop 4 13 AMD",
        "Model":  "Surface Laptop 4",
        "Product":  "Surface_Laptop_4_1958:1959",
        "PackageID": "102923"
    },
    {
        "Name":  "Surface Laptop 4 13 Intel",
        "Model":  "Surface Laptop 4",
        "Product":  "Surface_Laptop_4_1950:1951",
        "PackageID": "102924"
    },
    {
        "Name":  "Surface Laptop 4 15 AMD",
        "Model":  "Surface Laptop 4",
        "Product":  "Surface_Laptop_4_1952:1953",
        "PackageID": "102923"
    },
    {
        "Name":  "Surface Laptop 4 15 Intel",
        "Model":  "Surface Laptop 4",
        "Product":  "Surface_Laptop_4_1978:1979",
        "PackageID": "102924"
    },
    {
        "Name":  "Surface Laptop Go",
        "Model":  "Surface Laptop Go",
        "Product":  "Surface_Laptop_Go_1943",
        "PackageID": "102261"
    },
    {
        "Name":  "Surface Laptop Studio",
        "Model":  "Surface Laptop Studio",
        "Product":  "Surface_Laptop_Studio_1964",
        "PackageID": "103505"
    },
    {
        "Name":  "Surface Pro",
        "Model":  "Surface Pro",
        "Product":  "Surface_Pro",
        "PackageID": "49038"
    },
    {
        "Name":  "Surface Pro 2",
        "Model":  "Surface Pro 2",
        "Product":  "Surface_Pro_2",
        "PackageID": "49042"
    },
    {
        "Name":  "Surface Pro 3",
        "Model":  "Surface Pro 3",
        "Product":  "Surface_Pro_3",
        "PackageID": "38826"
    },
    {
        "Name":  "Surface Pro 4",
        "Model":  "Surface Pro 4",
        "Product":  "Surface_Pro_4",
        "PackageID": "49498"
    },
    {
        "Name":  "Surface Pro (5th Gen)",
        "Model":  "Surface Pro",
        "Product":  "Surface_Pro_1796",
        "PackageID": "55484"
    },
    {
        "Name":  "Surface Pro with LTE Advanced",
        "Model":  "Surface Pro",
        "Product":  "Surface_Pro_1807",
        "PackageID": "56278"
    },
    {
        "Name":  "Surface Pro 6 Commercial",
        "Model":  "Surface Pro 6",
        "Product":  "Surface_Pro_6_1796_Commercial",
        "PackageID": "57514"
    },
    {
        "Name":  "Surface Pro 6 Consumer",
        "Model":  "Surface Pro 6",
        "Product":  "Surface_Pro_6_1796_Consumer",
        "PackageID": "57514"
    },
    {
        "Name":  "Surface Pro 7",
        "Model":  "Surface Pro 7",
        "Product":  "Surface_Pro_7_1866",
        "PackageID": "100419"
    },
    {
        "Name":  "Surface Pro 7+",
        "Model":  "Surface Pro 7+",
        "Product":  "Surface_Pro_7+_1960",
        "PackageID": "102633"
    },
    {
        "Name":  "Surface Pro 7+ LTE",
        "Model":  "Surface Pro 7+",
        "Product":  "Surface_Pro_7+_with_LTE_Advanced_1961",
        "PackageID": "102633"
    },
    {
        "Name":  "Surface Pro 8",
        "Model":  "Surface Pro 8",
        "Product":  "Surface_Pro_8_for_Business_1983",
        "PackageID": "103503"
    },
    {
        "Name":  "Surface Pro 8 Consumer",
        "Model":  "Surface Pro 8",
        "Product":  "Surface_Pro_8_1983",
        "PackageID": "103503"
    },
    {
        "Name":  "Surface Pro 8 LTE",
        "Model":  "Surface Pro 8",
        "Product":  "Surface_Pro_8_for_Business_with_LTE_Advanced_1982",
        "PackageID": "103503"
    },
    {
        "Name":  "Surface Studio",
        "Model":  "Surface Studio",
        "Product":  "Surface_Studio",
        "PackageID": "54311"
    },
    {
        "Name":  "Surface Studio 2",
        "Model":  "Surface Studio 2",
        "Product":  "Surface_Studio_2_1707_Commercial",
        "PackageID": "57593"
    }
]
'@
    #=================================================
    #	Reference
    #=================================================
    #https://docs.microsoft.com/en-us/surface/surface-system-sku-reference
    #https://docs.microsoft.com/en-us/surface/manage-surface-driver-and-firmware-updates
    #https://support.microsoft.com/en-us/surface/download-drivers-and-firmware-for-surface-09bb2e09-2a4b-cb69-0951-078a7739e120

    #Supported Operating Systems
    #https://support.microsoft.com/en-us/surface/surface-supported-operating-systems-9559cc3c-7a38-31b6-d9fb-571435e84cd1
    #=================================================
    #   Paths
    #=================================================
    $UseCatalog             = 'Offline'
    $CloudCatalogUri        = 'https://support.microsoft.com/en-us/surface/download-drivers-and-firmware-for-surface-09bb2e09-2a4b-cb69-0951-078a7739e120'
    $BuildCatalogFile		= Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogMicrosoftDriverPack.json')
    $OfflineCatalogFile     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\OSDCatalog\OSDCatalogMicrosoftDriverPack.json"
    $DownloadsBaseUrl 		= 'https://www.microsoft.com/en-us/download/confirmation.aspx?id='
    #=================================================
    #   Create Paths
    #=================================================
    if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
        $null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
    }
    #=================================================
    #   Test Build Catalog
    #=================================================
    if (Test-Path $BuildCatalogFile) {
        Write-Verbose "Build Catalog already created at $BuildCatalogFile"	

        $GetItemBuildCatalogFile = Get-Item $BuildCatalogFile

        #If the Build Catalog is older than 12 hours, delete it
        if (((Get-Date) - $GetItemBuildCatalogFile.LastWriteTime).TotalHours -gt 12) {
            Write-Verbose "Removing previous Build Catalog"
            $null = Remove-Item $GetItemBuildCatalogFile.FullName -Force
        }
        else {
            $UseCatalog = 'Build'
        }
    }
    #=================================================
    #   Test Cloud Catalog
    #=================================================
    if ($Force) {
        $UseCatalog = 'Cloud'
    }
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
        $Results = $OSDCatalog | ConvertFrom-Json
        $MasterResults = @()
    
        $MasterResults = foreach ($Item in $Results) {
            Write-Verbose "Processing $($Item.Name)"
            $DriverPage = $DownloadsBaseUrl + $Item.PackageID
            $Downloads = (Invoke-WebRequest -Uri $DriverPage -UseBasicParsing).Links
            $Downloads = $Downloads | Where-Object {$_.href -match 'download.microsoft.com'}
            $Downloads = $Downloads | Where-Object {($_.href -match 'Win11') -or ($_.href -match 'Win10')}
            $Downloads = $Downloads | Sort-Object href | Select-Object href -Unique
            #$Downloads = $Downloads | Select-Object -Last 1
            #$Item.Url = ($Downloads).href
            #$Item.FileName = Split-Path $Item.Url -Leaf

            #=================================================
            #   Create Object
            #=================================================
            foreach ($Download in $Downloads) {
                $DownloadUrl = $Download.href
                Write-Verbose "Testing Download File at $DownloadUrl"

                $DownloadHeaders = (Invoke-WebRequest -Method Head -Uri $DownloadUrl -UseBasicParsing).Headers

                $ReleaseDate = Get-Date ($DownloadHeaders['Last-Modified']) -Format "yy.MM.dd"
                $FileName = Split-Path $DownloadUrl -Leaf

                if ($FileName -match 'Win11') {
                    $OSVersion = 'Windows 11 x64'
                }
                else {
                    $OSVersion = 'Windows 10 x64'
                }
                
                $ByteArray = [System.Convert]::FromBase64String($DownloadHeaders['Content-MD5'])
                $HexObject = $ByteArray | Format-Hex
                $HashMD5 = ($HexObject.Bytes | ForEach-Object {"{0:X}" -f $_}) -join ''

                $ObjectProperties = [ordered] @{
                    CatalogVersion          = Get-Date -Format yy.MM.dd
                    Status                  = $null
                    Component               = 'DriverPack'
                    ReleaseDate             = $ReleaseDate
                    Manufacturer            = 'Microsoft'
                    Model                   = $Item.Model
                    Product                 = $Item.Product
                    Name                    = $Item.Name
                    PackageID               = $Item.PackageID
                    FileName                = $FileName
                    Url                     = $DownloadUrl
                    OSVersion               = $OSVersion
                    HashMD5                 = $HashMD5
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
        }
        $MasterResults | ConvertTo-Json | Out-File $BuildCatalogFile -Encoding ascii -Width 2000 -Force

        if (Test-Path $BuildCatalogFile) {
            $UseCatalog = 'Build'
        }
        else {
            Write-Verbose "Could not locate $BuildCatalogFile"
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Build
    #=================================================
    if ($UseCatalog -eq 'Build') {
        Write-Verbose "Importing the Build Catalog at $BuildCatalogFile"
        $MasterResults = Get-Content -Path $BuildCatalogFile | ConvertFrom-Json
    }
    #=================================================
    #   UseCatalog Offline
    #=================================================
    if ($UseCatalog -eq 'Offline') {
        Write-Verbose "Importing the Offline Catalog at $OfflineCatalogFile"
        $MasterResults = Get-Content -Path $OfflineCatalogFile | ConvertFrom-Json
    }
    #=================================================
    #   Compatible
    #=================================================
    if ($PSBoundParameters.ContainsKey('Compatible')) {
        $MyComputerProduct = Get-MyComputerProduct
        Write-Verbose "Filtering Catalog for items compatible with Product $MyComputerProduct"
        $MasterResults = $MasterResults | Where-Object {$_.Product -contains $MyComputerProduct}
    }
    #=================================================
    #   DownloadPath
    #=================================================
    if ($PSBoundParameters.ContainsKey('DownloadPath')) {
        $MasterResults = $MasterResults | Out-GridView -Title 'Select one or more files to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $MasterResults) {
            $OutFile = Save-WebFile -SourceUrl $Item.Url -DestinationDirectory $DownloadPath -DestinationName $Item.FileName -Verbose
            $Item | ConvertTo-Json | Out-File "$($OutFile.FullName).json" -Encoding ascii -Width 2000 -Force
        }
    }
    #=================================================
    #   Results
    #=================================================
    $MasterResults | Sort-Object -Property Name
    #=================================================
}