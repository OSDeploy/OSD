<#
.SYNOPSIS
Builds the Lenovo Bios Catalog

.DESCRIPTION
Builds the Lenovo Bios Catalog

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-LenovoBiosCatalog {
    [CmdletBinding()]
    param (
        #Specifies a download path for matching results displayed in Out-GridView
        [System.String]
        $DownloadPath,

        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible,

        #Checks for the latest Online version
        [System.Management.Automation.SwitchParameter]
        $Online,

        #Updates the local catalog in the OSD Module
        [System.Management.Automation.SwitchParameter]
        $UpdateModuleCatalog
    )
    #=================================================
    #   Defaults
    #=================================================
    $UseCatalog = 'Offline'
    $OfflineCatalogName = 'LenovoBiosCatalog.xml'
    $OnlineCatalogUri = 'https://download.lenovo.com/cdrt/td/catalogv2.xml'
    $OnlineCatalogName = 'catalogv2.xml'
    #=================================================
    #   Initialize
    #=================================================
    $IsOnline = $false

    if ($UpdateModuleCatalog) {
        $Online = $true
    }
    if ($Online) {
        $UseCatalog = 'Cloud'
    }
    if ($Online) {
        $IsOnline = Test-WebConnection $OnlineCatalogUri
    }

    if ($IsOnline -eq $false) {
        $Online = $false
        $UpdateModuleCatalog = $false
        $UseCatalog = 'Offline'
    }
    Write-Verbose "$UseCatalog Catalog"
    #=================================================
    #   Additional Paths
    #=================================================
    $CatalogBuildFolder = Join-Path $env:TEMP 'OSD'
    if (-not(Test-Path $CatalogBuildFolder)) {
        $null = New-Item -Path $CatalogBuildFolder -ItemType Directory -Force
    }
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' $OnlineCatalogName)
    $RawCatalogCabName  	= [string]($OnlineCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 		= Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)
    $TempCatalogFile        = Join-Path $env:TEMP (Join-Path 'OSD' $OfflineCatalogName)
    $ModuleCatalogFile      = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\$OfflineCatalogName"
    #=================================================
    #   Test Cloud Catalog
    #=================================================
    if ($UseCatalog -eq 'Cloud') {
        try {
            $CatalogCloudRaw = Invoke-RestMethod -Uri $OnlineCatalogUri -UseBasicParsing
            Write-Verbose "Cloud Catalog $OnlineCatalogUri"
            Write-Verbose "Saving Cloud Catalog to $RawCatalogFile"		
            $CatalogCloudContent = $CatalogCloudRaw.Substring(3)
            $CatalogCloudContent | Out-File -FilePath $RawCatalogFile -Encoding utf8 -Force

            if (Test-Path $RawCatalogFile) {
                Write-Verbose "Catalog saved to $RawCatalogFile"
                $UseCatalog = 'Raw'
            }
            else {
                Write-Verbose "Catalog was NOT downloaded to $RawCatalogFile"
                Write-Verbose "Using Offline Catalog at $ModuleCatalogFile"
                $UseCatalog = 'Offline'
            }
        }
        catch {
            Write-Verbose "Using Offline Catalog at $ModuleCatalogFile"
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
	
		Write-Verbose "Exporting Offline Catalog to $TempCatalogFile"
        $Results = $Results | Sort-Object SupportedModel
		$Results | Export-Clixml -Path $TempCatalogFile
	}
    #=================================================
    #   UseCatalog Build
    #=================================================
    if ($UseCatalog -eq 'Build') {
        Write-Verbose "Importing the Build Catalog at $TempCatalogFile"
        $Results = Import-Clixml -Path $TempCatalogFile
    }
    #=================================================
    #   UseCatalog Offline
    #=================================================
    if ($UseCatalog -eq 'Offline') {
        Write-Verbose "Importing the Offline Catalog at $ModuleCatalogFile"
        $Results = Import-Clixml -Path $ModuleCatalogFile
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