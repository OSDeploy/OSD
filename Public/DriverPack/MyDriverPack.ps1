#https://pc-dl.panasonic.co.jp/itn/drivers/driver_packages.html
#https://pc-dl.panasonic.co.jp/dl/search?dc%5B%5D=002017

function Get-MyDriverPack {
    [CmdletBinding()]
    param (
        [ValidateSet('Dell','HP','Lenovo')]
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )
    #=======================================================================
    #   Set ErrorActionPreference
    #=======================================================================
    $ErrorActionPreference = 'SilentlyContinue'
    #=======================================================================
    #   Action
    #=======================================================================
    if ($Manufacturer -eq 'Dell') {
        $Result = Get-DellDriverPack | Where-Object {($_.Product -contains $Product)}
        $Result[0]
    }
    elseif ($Manufacturer -eq 'HP') {
        $Result = Get-HpDriverPack -Product $Product
        $Result[0]
    }
    elseif ($Manufacturer -eq 'Lenovo') {
        $Result = Get-LenovoDriverPack | Where-Object {($_.Product -contains $Product)}
        $Result[0]
    }
    else {
        Write-Warning "$Manufacturer is not supported yet"
    }
    #=======================================================================
}
function Save-MyDriverPack {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$DownloadPath = 'C:\Drivers',
        [switch]$Expand,
        [ValidateSet('Dell','HP','Lenovo')]
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )
    #=======================================================================
    #   Block
    #=======================================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    #=======================================================================
    #   Get-MyDriverPack
    #=======================================================================
    $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Manufacturer -Product $Product

    if ($GetMyDriverPack) {
        $GetMyDriverPack

        $DriverPackModel = $GetMyDriverPack.Model
        $DriverPackUrl = $GetMyDriverPack.DriverPackUrl
        $DriverPackFile = $DriverPackUrl | Split-Path -Leaf

        $Source = $DriverPackUrl
        $Destination = $DownloadPath
        $OutFile = Join-Path $Destination $DriverPackFile
        #=======================================================================
        #   Save-WebFile
        #=======================================================================
        if (-NOT (Test-Path "$Destination")) {
            New-Item $Destination -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        Write-Verbose -Verbose "Source: $Source"
        Write-Verbose -Verbose "Destination: $Destination"
        Write-Verbose -Verbose "OutFile: $OutFile"
        
        Save-WebFile -SourceUrl $DriverPackUrl -DestinationDirectory $DownloadPath -DestinationName $DriverPackFile
        #=======================================================================
        #   Expand
        #=======================================================================
        if ($PSBoundParameters.ContainsKey('Expand')) {
            $Item = Get-Item $OutFile

            $ExpandFile = $Item.FullName
            Write-Verbose -Verbose "DriverPack: $ExpandFile"
            #=======================================================================
            #   Cab
            #=======================================================================
            if ($Item.Extension -eq '.cab') {
                $DestinationPath = Join-Path $Item.Directory $Item.BaseName
    
                if (-NOT (Test-Path "$DestinationPath")) {
                    New-Item $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null

                    Write-Verbose -Verbose "Expanding CAB Driver Pack to $DestinationPath"
                    Expand -R "$ExpandFile" -F:* "$DestinationPath" | Out-Null
                }
            }
            #=======================================================================
            #   HP
            #=======================================================================
            if (($Item.Extension -eq '.exe') -and ($env:SystemDrive -ne 'X:')) {
                if (($Item.VersionInfo.InternalName -match 'hpsoftpaqwrapper') -or ($Item.VersionInfo.OriginalFilename -match 'hpsoftpaqwrapper.exe') -or ($Item.VersionInfo.FileDescription -like "HP *")) {
                    Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                    Write-Verbose -Verbose "InternalName: $($Item.VersionInfo.InternalName)"
                    Write-Verbose -Verbose "OriginalFilename: $($Item.VersionInfo.OriginalFilename)"
                    Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"
                    
                    $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                    if (-NOT (Test-Path "$DestinationPath")) {
                        Write-Verbose -Verbose "Expanding HP Driver Pack to $DestinationPath"
                        Start-Process -FilePath $ExpandFile -ArgumentList "/s /e /f `"$DestinationPath`"" -Wait
                    }
                }
            }
            #=======================================================================
            #   Lenovo
            #=======================================================================
            if (($Item.Extension -eq '.exe') -and ($env:SystemDrive -ne 'X:')) {
                if ($Item.VersionInfo.FileDescription -match 'Lenovo') {
                    Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                    Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"

                    $DestinationPath = Join-Path $Item.Directory 'SCCM'

                    if (-NOT (Test-Path "$DestinationPath")) {
                        Write-Verbose -Verbose "Expanding Lenovo Driver Pack to $DestinationPath"
                        Start-Process -FilePath $ExpandFile -ArgumentList "/SILENT /SUPPRESSMSGBOXES" -Wait
                    }
                }
            }
            #=======================================================================
            #   Zip
            #=======================================================================
            if ($Item.Extension -eq '.zip') {
                $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                if (-NOT (Test-Path "$DestinationPath")) {
                    Write-Verbose -Verbose "Expanding ZIP Driver Pack to $DestinationPath"
                    Expand-Archive -Path $ExpandFile -DestinationPath $DestinationPath -Force
                }
            }
            #=======================================================================
            #   Everything Else
            #=======================================================================
            if ($env:SystemDrive -eq 'X:') {
                Write-Warning "Unable to expand in WinPE $ExpandFile"
            }
            else {
                Write-Warning "Unable to expand $ExpandFile"
            }
        }
        #=======================================================================
        #   Add-StagedDriverPack.specialize
        #=======================================================================
<#         if ($env:SystemDrive -eq 'X:') {
            Add-StagedDriverPack.specialize
        } #>
        #=======================================================================
    }
}