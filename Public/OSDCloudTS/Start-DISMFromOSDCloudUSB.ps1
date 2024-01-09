Function Start-DISMFromOSDCloudUSB {
    #region Initialize
    if ($env:SystemDrive -eq 'X:') {
        $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Select-Object -First 1
        $ComputerProduct = (Get-MyComputerProduct)
        $DriverPack = Get-OSDCloudDriverPack -Product $ComputerProduct
        $PackageID = $DriverPack.PackageID
        $ComputerManufacturer = (Get-MyComputerManufacturer -Brief)
        $DriverPathProduct = "$($OSDCloudUSB.DriveLetter):\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$ComputerProduct"
        $DriverPathPackageID = "$($OSDCloudUSB.DriveLetter):\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$PackageID"
        
        Write-Host "Checking locations for Drivers" -ForegroundColor Green
        if (Test-Path $DriverPathProduct){$DriverPath = $DriverPathProduct}
        if (Test-Path $DriverPathPackageID){$DriverPath = $DriverPathPackageID}
        if (Test-Path $DriverPath){
            Write-Host "Found Drivers: $DriverPath" -ForegroundColor Green
            Write-Host "Starting DISM of drivers while Offline" -ForegroundColor Green
            $DismPath = "$env:windir\System32\Dism.exe"
            $DismProcess = Start-Process -FilePath $DismPath -ArgumentList "/image:c:\ /Add-Driver /driver:$($DriverPath) /recurse" -Wait -PassThru
            Write-Host "Finished Process with Exit Code: $($DismProcess.ExitCode)"
        }
    }
    else {
        Write-Output "Skipping Run-DISMFromOSDCloudUSB Function, not running in WinPE"
    }
}
