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
function Get-OSDCatalogLenovoBios {
    [CmdletBinding()]
    param (
        [System.String]$DownloadPath,
		[System.Management.Automation.SwitchParameter]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
    $UseCatalog           	= 'Cloud'
    $CloudCatalogUri		= 'https://download.lenovo.com/cdrt/td/catalogv2.xml'
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' 'catalogv2.xml')
    $BuildCatalogFile		= Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogLenovoBios.xml')
	$OfflineCatalogFile     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\OSDCatalog\OSDCatalogLenovoBios.xml"
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
    if ($UseCatalog -eq 'Cloud') {
        try {
            $CatalogCloudRaw = Invoke-RestMethod -Uri $CloudCatalogUri -UseBasicParsing
            Write-Verbose "Cloud Catalog $CloudCatalogUri"
            Write-Verbose "Saving Cloud Catalog to $RawCatalogFile"		
            $CatalogCloudContent = $CatalogCloudRaw.Substring(3)
            $CatalogCloudContent | Out-File -FilePath $RawCatalogFile -Encoding utf8 -Force

            if (Test-Path $RawCatalogFile) {
                Write-Verbose "Catalog saved to $RawCatalogFile"
                $UseCatalog = 'Raw'
            }
            else {
                Write-Verbose "Catalog was NOT downloaded to $RawCatalogFile"
                Write-Verbose "Using Offline Catalog at $OfflineCatalogFile"
                $UseCatalog = 'Offline'
            }
        }
        catch {
            Write-Verbose "Using Offline Catalog at $OfflineCatalogFile"
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Raw
    #=================================================
    if ($UseCatalog -eq 'Raw') {
        Write-Verbose "Reading the Raw Catalog at $RawCatalogFile"	
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
                        Status          = $null
                        Component       = 'BIOS'
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
            @{Label="Status";Expression={$null};},
            @{Label="Component";Expression={'BIOS'};},
			@{Label="SupportedModel";Expression={$_.Group.Name | Select-Object -Unique};},
			@{Label="SupportedProduct";Expression={$_.Group.Product | Select-Object -Unique};},
			@{Label="UEFIVersion";Expression={($_.Group)[0].UEFIVersion};},
			@{Label="ECPVersion";Expression={($_.Group)[0].ECPVersion};},
			@{Label="Image";Expression={($_.Group)[0].Image};},
			@{Label="FileName";Expression={($_.Group)[0].FileName};},
			@{Label="Url";Expression={($_.Group)[0].Url};}
	
		Write-Verbose "Exporting Offline Catalog to $BuildCatalogFile"
        $Results = $Results | Sort-Object SupportedModel
		$Results | Export-Clixml -Path $BuildCatalogFile
	}
    #=================================================
    #   UseCatalog Build
    #=================================================
    if ($UseCatalog -eq 'Build') {
        Write-Verbose "Importing the Build Catalog at $BuildCatalogFile"
        $Results = Import-Clixml -Path $BuildCatalogFile
    }
    #=================================================
    #   UseCatalog Offline
    #=================================================
    if ($UseCatalog -eq 'Offline') {
        Write-Verbose "Importing the Offline Catalog at $OfflineCatalogFile"
        $Results = Import-Clixml -Path $OfflineCatalogFile
    }
    #=================================================
    #   Compatible
    #=================================================
    if ($PSBoundParameters.ContainsKey('Compatible')) {
        $MyComputerProduct = Get-MyComputerProduct
        Write-Verbose "Filtering Catalog for items compatible with Product $MyComputerProduct"
        $Results = $Results | Where-Object {$_.Product -contains $MyComputerProduct}
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
    #   Component
    #=================================================
    $Results | Sort-Object -Property SupportedModel
    #=================================================
}