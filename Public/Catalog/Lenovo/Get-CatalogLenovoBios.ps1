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
function Get-CatalogLenovoBios {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
	$CatalogState           = 'Online'
	$CatalogUri      		= 'https://download.lenovo.com/cdrt/td/catalogv2.xml'
	$CatalogFileRaw       	= Join-Path $env:TEMP 'catalogv2.xml'
	$CatalogFileDownload	= Join-Path $env:TEMP 'CatalogLenovoBios.xml'
	$CatalogFileOffline     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\Lenovo\catalogv2.xml"
    #=================================================
    #   Test Local CatalogState
    #=================================================
    if (Test-Path $CatalogFileDownload) {
		Write-Verbose "Catalog already downloaded to $CatalogFileDownload"

        $GetItemCatalogFileDownload = Get-Item $CatalogFileDownload

		#If the local is older than 12 hours, delete it
        if (((Get-Date) - $GetItemCatalogFileDownload.LastWriteTime).TotalHours -gt 12) {
            Write-Verbose "Removing previous Offline Catalog"
		}
		else {
            $CatalogState = 'Local'
        }
    }
    #=================================================
    #   Test CatalogState Online
    #=================================================
	if ($CatalogState -eq 'Online') {
		try {
			$CatalogOnlineRaw = Invoke-RestMethod -Uri $CatalogUri -UseBasicParsing
			Write-Verbose "Catalog is Online at $CatalogUri"
			Write-Verbose "Saving Online Catalog to $CatalogFileRaw"		
			$CatalogOnlineContent = $CatalogOnlineRaw.Substring(3)
			$CatalogOnlineContent | Out-File -FilePath $CatalogFileRaw -Encoding utf8 -Force

			if (Test-Path $CatalogFileRaw) {
				Write-Verbose "Catalog saved to $CatalogFileRaw"
				$CatalogState = 'Build'
			}
			else {
				Write-Verbose "Catalog was NOT downloaded to $CatalogFileRaw"
				Write-Verbose "Using Offline Catalog at $CatalogFileOffline"
				$CatalogFileRaw = $CatalogFileOffline
				$CatalogState = 'Build'
			}
		}
		catch {
			Write-Verbose "Using Offline Catalog at $CatalogFileOffline"
			$CatalogFileRaw = $CatalogFileOffline
			$CatalogState = 'Build'
		}
	}
    #=================================================
    #   CatalogState Build
    #=================================================
	if ($CatalogState -eq 'Build') {
		Write-Verbose "Reading the System Catalog at $CatalogFileRaw"		
		[xml]$XmlCatalogContent = Get-Content -Path $CatalogFileRaw -Raw

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
    #   CatalogState Local
    #=================================================
	if ($CatalogState -eq 'Local') {
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