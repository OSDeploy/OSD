<#
.SYNOPSIS
Returns the Lenovo BIOS downloads

.DESCRIPTION
Returns the Lenovo BIOS downloads

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-LenovoBiosCatalog {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
	$UseCatalog           = 'Cloud'
	$CloudCatalogUri      		= 'https://download.lenovo.com/cdrt/td/catalogv2.xml'
	$RawCatalogFile       	= Join-Path $env:TEMP 'catalogv2.xml'
	$CatalogFileDownload	= Join-Path $env:TEMP 'CatalogLenovoBios.xml'
	$CatalogFileOffline     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\Lenovo\catalogv2.xml"
    #=================================================
    #   Create Paths
    #=================================================
	if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
		$null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
	}
    #=================================================
    #   Test Local UseCatalog
    #=================================================
    if (Test-Path $CatalogFileDownload) {
		Write-Verbose "Catalog already downloaded to $CatalogFileDownload"

        $GetItemCatalogFileDownload = Get-Item $CatalogFileDownload

		#If the local is older than 12 hours, delete it
        if (((Get-Date) - $GetItemCatalogFileDownload.LastWriteTime).TotalHours -gt 12) {
            Write-Verbose "Removing previous Offline Catalog"
		}
		else {
            $UseCatalog = 'Local'
        }
    }
    #=================================================
    #   Test UseCatalog Cloud
    #=================================================
	if ($UseCatalog -eq 'Cloud') {
		try {
			$CatalogCloudRaw = Invoke-RestMethod -Uri $CloudCatalogUri -UseBasicParsing
			Write-Verbose "Catalog is Cloud at $CloudCatalogUri"
			Write-Verbose "Saving Cloud Catalog to $RawCatalogFile"		
			$CatalogCloudContent = $CatalogCloudRaw.Substring(3)
			$CatalogCloudContent | Out-File -FilePath $RawCatalogFile -Encoding utf8 -Force

			if (Test-Path $RawCatalogFile) {
				Write-Verbose "Catalog saved to $RawCatalogFile"
				$UseCatalog = 'Build'
			}
			else {
				Write-Verbose "Catalog was NOT downloaded to $RawCatalogFile"
				Write-Verbose "Using Offline Catalog at $CatalogFileOffline"
				$RawCatalogFile = $CatalogFileOffline
				$UseCatalog = 'Build'
			}
		}
		catch {
			Write-Verbose "Using Offline Catalog at $CatalogFileOffline"
			$RawCatalogFile = $CatalogFileOffline
			$UseCatalog = 'Build'
		}
	}
    #=================================================
    #   UseCatalog Build
    #=================================================
	if ($UseCatalog -eq 'Build') {
		Write-Verbose "Reading the System Catalog at $RawCatalogFile"		
		[xml]$XmlCatalogContent = Get-Content -Path $RawCatalogFile -Raw

		$ModelList = $XmlCatalogContent.ModelList.Model
		#=================================================
		#   Create Object 
		#=================================================
		$Results = foreach ($Model in $ModelList) {
			foreach ($Item in $Model.BIOS) {
				If($Item.'#text'){#Some models do not have BIOS updates
					$Version = $Item.version
					$UEFIVersion = $null
					$ECPVersion = $null
		
					If($Version -notmatch "^[a-z,A-Z]"){#Do not try to parse BIOS versions that starts with a letter. Ex: M1AKT4FA
						If($Version -match "-"){
							$UEFIVersion = ($Version.split("-")[0]).Trim()
							$ECPVersion = ($Version.split("-")[1]).Trim()
						}ElseIf($Version -match "/"){
							$UEFIVersion = ($Version.split("/")[0]).Trim()
							$ECPVersion = ($Version.split("/")[1]).Trim()
						}
		
						
						If($ECPVersion -match "^[\d|.]+"){#Make sure we filter out anything added after the ECP version. Ex: 1.28(JDET69WW
							$ECPVersion = $matches[0]
						}
					}
		
					If(-not $UEFIVersion){
						$UEFIVersion = $Version
					}
					If(-not $ECPVersion){
						$ECPVersion = "(none)"
					}
		
					$ObjectProperties = [Ordered]@{
						CatalogVersion 	= Get-Date -Format yy.MM.dd
						Name           	= $Model.name
						Product         = $Model.Types.Type.split(',').Trim()
						UEFIVersion     = $UEFIVersion
						ECPVersion      = $ECPVersion #Embedded Controller Program
						Image           = $Item.image
						FileName        = $Item.'#text' | Split-Path -Leaf
						Url             = $Item.'#text'
					}
					New-Object -TypeName PSObject -Property $ObjectProperties
				}			
			}
		}
		
		#Some BIOS packages are applicable to multiple models, grouping results...
		$Results = $Results | Group-Object -Property Image | Select-Object -Property `
			@{Label="CatalogVersion";Expression={($_.Group)[0].CatalogVersion};},
			@{Label="SupportedModel";Expression={$_.Group.Name | Select-Object -Unique};},
			@{Label="SupportedProduct";Expression={$_.Group.Product | Select-Object -Unique};},
			@{Label="UEFIVersion";Expression={($_.Group)[0].UEFIVersion};},
			@{Label="ECPVersion";Expression={($_.Group)[0].ECPVersion};},
			@{Label="Image";Expression={($_.Group)[0].Image};},
			@{Label="FileName";Expression={($_.Group)[0].FileName};},
			@{Label="Url";Expression={($_.Group)[0].Url};}
	
		Write-Verbose "Exporting Offline Catalog to $CatalogFileDownload"
		$Results | Export-Clixml -Path $CatalogFileDownload
	}
    #=================================================
    #   UseCatalog Local
    #=================================================
	if ($UseCatalog -eq 'Local') {
		Write-Verbose "Reading the Local System Catalog at $CatalogFileDownload"
		$Results = Import-Clixml -Path $CatalogFileDownload
	}
    #=================================================
    #   Compatible
    #=================================================
	if ($PSBoundParameters.ContainsKey('Compatible')) {
		$MyComputerProduct = Get-MyComputerProduct
		Write-Verbose "Filtering XML for items compatible with Product $MyComputerProduct"
		$Results = $Results | Where-Object {$_.SupportedProduct -contains $MyComputerProduct}
	}
    #=================================================
    #   Component
    #=================================================
    $Results | Sort-Object -Property Image
    #=================================================
}