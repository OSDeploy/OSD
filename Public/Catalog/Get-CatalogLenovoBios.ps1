<#
.SYNOPSIS
Returns the Lenovo BIOS packages

.DESCRIPTION
Returns the Lenovo BIOS packages

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogLenovoBios {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
    #=======================================================================
    #   Paths
    #=======================================================================
	$CatalogState           = 'Online' #Online, Build, Local, Offline
    #$DownloadsBaseUrl       = 'http://downloads.Lenovo.com/'
	$CatalogOnlinePath      = 'https://download.lenovo.com/cdrt/td/catalogv2.xml'
	$CatalogBuildPath       = Join-Path $env:TEMP 'catalogv2.xml'
	$CatalogLocalPath  		= Join-Path $env:TEMP 'CatalogLenovoBios.xml'
	$CatalogOfflinePath     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\CatalogLenovoBios.xml"
	#$CatalogLocalCabName  	= [string]($CatalogOnlinePath | Split-Path -Leaf)
    #$CatalogLocalCabPath 	= Join-Path $env:TEMP $CatalogLocalCabName
    #=======================================================================
    #   Test CatalogState Local
    #=======================================================================
    if (Test-Path $CatalogLocalPath) {

		#Get-Item to determine the age
        $GetItemCatalogLocalPath = Get-Item $CatalogLocalPath

		#If the local is older than 12 hours, delete it
        if (((Get-Date) - $GetItemCatalogLocalPath.LastWriteTime).TotalHours -gt 12) {
            Write-Verbose "Removing previous Offline Catalog"
		}
		else {
            $CatalogState = 'Local'
        }
    }
    #=======================================================================
    #   Test CatalogState Online
    #=======================================================================
	if ($CatalogState -eq 'Online') {
		if (Test-WebConnection -Uri $CatalogOnlinePath) {
			#Catalog is online and can be downloaded
		}
		else {
			$CatalogState = 'Offline'
		}
	}
    #=======================================================================
    #   CatalogState Online
	#	Need to get the Online Catalog to Local
    #=======================================================================
	if ($CatalogState -eq 'Online') {
		Write-Verbose "Source: $CatalogOnlinePath"
		Write-Verbose "Destination: $CatalogBuildPath"
        Save-WebFile -SourceUrl $CatalogOnlinePath -DestinationDirectory $env:Temp -DestinationName catalogv2.xml -Overwrite | Out-Null

		#Make sure the file downloaded
		if (Test-Path $CatalogBuildPath) {
			$CatalogState = 'Build'
		}
		else {
			$CatalogState = 'Offline'
		}
	}
    #=======================================================================
    #   CatalogState Build
    #=======================================================================
	if ($CatalogState -eq 'Build') {
		Write-Verbose "Reading the System Catalog at $CatalogBuildPath"
		[xml]$XmlCatalogContent = Get-Content -Path "$env:Temp\catalogv2.xml" -Raw

		$ModelList = $XmlCatalogContent.ModelList.Model
		#=======================================================================
		#   Create Object 
		#=======================================================================
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
						Name            = $Model.name
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
	
		Write-Verbose "Exporting Offline Catalog to $CatalogLocalPath"
		$Results | Export-Clixml -Path $CatalogLocalPath
	}
    #=======================================================================
    #   CatalogState Local
    #=======================================================================
	if ($CatalogState -eq 'Local') {
		Write-Verbose "Reading the Local System Catalog at $CatalogLocalPath"
		$Results = Import-Clixml -Path $CatalogLocalPath
	}
    #=======================================================================
    #   CatalogState Offline
    #=======================================================================
	if ($CatalogState -eq 'Offline') {
		Write-Verbose "Reading the Offline System Catalog at $CatalogOfflinePath"
		$Results = Import-Clixml -Path $CatalogOfflinePath
	}
    #=======================================================================
    #   Compatible
    #=======================================================================
	if ($PSBoundParameters.ContainsKey('Compatible')) {
		$MyComputerProduct = Get-MyComputerProduct
		Write-Verbose "Filtering XML for items compatible with Product $MyComputerProduct"
		$Results = $Results | Where-Object {$_.SupportedProduct -contains $MyComputerProduct}
	}
    #=======================================================================
    #   Component
    #=======================================================================
    $Results | Sort-Object -Property Image
    #=======================================================================
}