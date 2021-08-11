function Get-MyDriverPack {
    [CmdletBinding()]
    param (
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
        $Result = Get-HpDriverPack | Where-Object {($_.Product -contains $Product)}
        $Result[0]
    }
    elseif ($Manufacturer -eq 'Lenovo') {
        $Result = Get-LenovoDriverPack | Where-Object {($_.Product -contains $Product)}
        $Result[0]
    }
    elseif ($Manufacturer -eq 'Microsoft') {
        $Result = Get-MicrosoftDriverPack | Where-Object {($_.Product -contains $Product)}
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
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )
    Write-Verbose "Manufacturer: $Manufacturer"
    Write-Verbose "Product: $Product"
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

        $GetItemOutFile = Get-Item $OutFile
        $GetMyDriverPack | ConvertTo-Json | Out-File "$OutFile.json" -Encoding ascii -Width 2000 -Force
        #=======================================================================
        #   Expand
        #=======================================================================
        if ($PSBoundParameters.ContainsKey('Expand')) {

            $ExpandFile = $GetItemOutFile.FullName
            Write-Verbose -Verbose "DriverPack: $ExpandFile"
            #=======================================================================
            #   Cab
            #=======================================================================
            if ($GetItemOutFile.Extension -eq '.cab') {
                $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
    
                if (-NOT (Test-Path "$DestinationPath")) {
                    New-Item $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null

                    Write-Verbose -Verbose "Expanding CAB Driver Pack to $DestinationPath"
                    Expand -R "$ExpandFile" -F:* "$DestinationPath" | Out-Null
                }
            }
            #=======================================================================
            #   HP
            #=======================================================================
            if (($GetItemOutFile.Extension -eq '.exe') -and ($env:SystemDrive -ne 'X:')) {
                if (($GetItemOutFile.VersionInfo.InternalName -match 'hpsoftpaqwrapper') -or ($GetItemOutFile.VersionInfo.OriginalFilename -match 'hpsoftpaqwrapper.exe') -or ($GetItemOutFile.VersionInfo.FileDescription -like "HP *")) {
                    Write-Verbose -Verbose "FileDescription: $($GetItemOutFile.VersionInfo.FileDescription)"
                    Write-Verbose -Verbose "InternalName: $($GetItemOutFile.VersionInfo.InternalName)"
                    Write-Verbose -Verbose "OriginalFilename: $($GetItemOutFile.VersionInfo.OriginalFilename)"
                    Write-Verbose -Verbose "ProductVersion: $($GetItemOutFile.VersionInfo.ProductVersion)"
                    
                    $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName

                    if (-NOT (Test-Path "$DestinationPath")) {
                        Write-Verbose -Verbose "Expanding HP Driver Pack to $DestinationPath"
                        Start-Process -FilePath $ExpandFile -ArgumentList "/s /e /f `"$DestinationPath`"" -Wait
                    }
                }
            }
            #=======================================================================
            #   Lenovo
            #=======================================================================
            if (($GetItemOutFile.Extension -eq '.exe') -and ($env:SystemDrive -ne 'X:')) {
                if ($GetItemOutFile.VersionInfo.FileDescription -match 'Lenovo') {
                    Write-Verbose -Verbose "FileDescription: $($GetItemOutFile.VersionInfo.FileDescription)"
                    Write-Verbose -Verbose "ProductVersion: $($GetItemOutFile.VersionInfo.ProductVersion)"

                    $DestinationPath = Join-Path $GetItemOutFile.Directory 'SCCM'

                    if (-NOT (Test-Path "$DestinationPath")) {
                        Write-Verbose -Verbose "Expanding Lenovo Driver Pack to $DestinationPath"
                        Start-Process -FilePath $ExpandFile -ArgumentList "/SILENT /SUPPRESSMSGBOXES" -Wait
                    }
                }
            }
            #=======================================================================
            #   MSI
            #=======================================================================
            if (($GetItemOutFile.Extension -eq '.msi') -and ($env:SystemDrive -ne 'X:')) {
                $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName

                if (-NOT (Test-Path "$DestinationPath")) {
                    #Need to sort out what to do here
                }
            }
            #=======================================================================
            #   Zip
            #=======================================================================
            if ($GetItemOutFile.Extension -eq '.zip') {
                $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName

                if (-NOT (Test-Path "$DestinationPath")) {
                    Write-Verbose -Verbose "Expanding ZIP Driver Pack to $DestinationPath"
                    Expand-Archive -Path $ExpandFile -DestinationPath $DestinationPath -Force
                }
            }
            #=======================================================================
            #   Everything Else
            #=======================================================================
            #Write-Warning "Unable to expand $ExpandFile"
        }
        #=======================================================================
        #   Enable-SpecializeDriverPack
        #=======================================================================
<#         if ($env:SystemDrive -eq 'X:') {
            Enable-SpecializeDriverPack
        } #>
        #=======================================================================
    }
}