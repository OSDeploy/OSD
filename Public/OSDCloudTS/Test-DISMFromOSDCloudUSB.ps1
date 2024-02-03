Function Test-DISMFromOSDCloudUSB {
    [CmdletBinding()]
    param (

        [Parameter()]
        [System.String]
        $PackageID
    )
    $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Select-Object -First 1
    if ($OSDCloudUSB){
        $ComputerProduct = (Get-MyComputerProduct)
        if (!($PackageID)){
            $PackageID = $DriverPack.PackageID
            $DriverPack = Get-OSDCloudDriverPack -Product $ComputerProduct
        }
        $ComputerManufacturer = (Get-MyComputerManufacturer -Brief)
        if ($ComputerManufacturer -match "Samsung"){$ComputerManufacturer = "Samsung"}
        $DriverPathProduct = "$($OSDCloudUSB.DriveLetter):\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$ComputerProduct"
        $DriverPathPackageID = "$($OSDCloudUSB.DriveLetter):\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$PackageID"
        if ($PackageID){  
            Write-Host "Testing Paths:"
            Write-Host "  $DriverPathProduct"
            Write-Host "  $DriverPathPackageID"
        }
        else {
            Write-Host "Testing Path:"
            Write-Host "  $DriverPathProduct"
        }
        if (Test-Path $DriverPathProduct){Return $true}
        elseif (Test-Path $DriverPathPackageID){Return $true}
        else { Return $false}
    }
    else{
        Write-Host "NO OSDCloud USB Found"
        return $false
    }
}
