#=================================================
Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDCloud Hotfix Start"
#=================================================
if ($OSDCloudGui.ComputerProduct -match 'Surface_Laptop_7th_Edition_With_Intel_For_Business') {
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Replacing OSDCloudGUI.DriverPack.Url"
    $Url = 'https://driverpack.blob.core.windows.net/public/SurfaceLaptopforBusiness7thEditionwithIntel_Win11_26100_25.013.32214.0.cab'
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] $Url"
    $OSDCloudGui.DriverPack.Url = $Url
}
#=================================================
Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDCloud Hotfix End"
#=================================================