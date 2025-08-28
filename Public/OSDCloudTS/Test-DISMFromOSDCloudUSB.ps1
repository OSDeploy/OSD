Function Test-DISMFromOSDCloudUSB {
    [CmdletBinding()]
    param (

        [Parameter()]
        [System.String]
        $PackageID
    )
    $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Select-Object -First 1
    if ($OSDCloudUSB){
        $OSDCloudDriveLetter = $OSDCloudUSB.DriveLetter
    }
    $MappedDrives = (Get-CimInstance -ClassName Win32_MappedLogicalDisk).DeviceID | Select-Object -Unique
    if ($MappedDrives){
        ForEach ($MappedDrive in $MappedDrives){
            if (Test-Path -Path "$MappedDrive\OSDCloud"){
                $OSDCloudDriveLetter = $MappedDrive.replace(":","")
            }
        }
    }
    if ($OSDCloudDriveLetter){
        $ComputerProduct = (Get-MyComputerProduct)
        $ComputerModel = (Get-MyComputerModel)
        if (!($PackageID)){
            $DriverPack = Get-OSDCloudDriverPack -Product $ComputerProduct
            $PackageID = $DriverPack.PackageID
        }
        $ComputerManufacturer = (Get-MyComputerManufacturer -Brief)
        # Remove trailing dots and extra spaces (e.g. ASUSTeK Computer INC.)
        $ComputerManufacturer = $ComputerManufacturer.Trim().TrimEnd('.')
        if ($ComputerManufacturer -match "Samsung"){$ComputerManufacturer = "Samsung"}
        $DriverPathProduct = "$($OSDCloudDriveLetter):\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$ComputerProduct"
        $DriverPathModel = "$($OSDCloudDriveLetter):\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$ComputerModel"
        Write-Host "Testing Paths:"
        Write-Host "  $DriverPathProduct"
        Write-Host "  $DriverPathModel"
        if ($PackageID){
            $DriverPathPackageID = "$($OSDCloudDriveLetter):\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$PackageID"
            Write-Host "  $DriverPathPackageID"
            if (Test-Path $DriverPathPackageID){Return $true}
        }
        if (Test-Path $DriverPathProduct){Return $true}
        elseif (Test-Path $DriverPathModel){Return $true}
        else { Return $false}
    }
    else{
        Write-Host "NO OSDCloud USB Found"
        return $false
    }
}

