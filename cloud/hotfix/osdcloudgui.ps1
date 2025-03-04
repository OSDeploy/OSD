#=================================================
Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDCloud Hotfix Start"
#=================================================
$SurfaceDriverPack = @'
{
    {
        "CatalogVersion":  "25.03.01",
        "Status":  null,
        "ReleaseDate":  "25.02.19",
        "Manufacturer":  "Microsoft",
        "Model":  "Surface Laptop 7",
        "Product":  "Surface_Laptop_7th_Edition_With_Intel_For_Business_2107",
        "Name":  "Microsoft Surface Laptop 7 13.8 Intel Win11 24H2",
        "PackageID":  "108014",
        "FileName":  "SurfaceLaptopforBusiness7thEditionwithIntel_Win11_26100_25.013.32214.0.msi",
        "Url":  "https://driverpack.blob.core.windows.net/public/SurfaceLaptopforBusiness7thEditionwithIntel_Win11_26100_25.013.32214.0.cab",
        "OS":  "Windows 11 x64",
        "OSReleaseId":  "24H2",
        "OSBuild":  "26100",
        "OSArchitecture":  "amd64",
        "HashMD5":  "",
        "Guid":  "854ec8ea-2164-429f-b3b6-92d55fee23ca"
    },
    {
        "CatalogVersion":  "25.03.01",
        "Status":  null,
        "ReleaseDate":  "25.02.19",
        "Manufacturer":  "Microsoft",
        "Model":  "Surface Laptop 7",
        "Product":  "Surface_Laptop_7th_Edition_With_Intel_For_Business_2108",
        "Name":  "Microsoft Surface Laptop 7 15 Intel Win11 24H2",
        "PackageID":  "108014",
        "FileName":  "SurfaceLaptopforBusiness7thEditionwithIntel_Win11_26100_25.013.32214.0.msi",
        "Url":  "https://driverpack.blob.core.windows.net/public/SurfaceLaptopforBusiness7thEditionwithIntel_Win11_26100_25.013.32214.0.cab",
        "OS":  "Windows 11 x64",
        "OSReleaseId":  "24H2",
        "OSBuild":  "26100",
        "OSArchitecture":  "amd64",
        "HashMD5":  "",
        "Guid":  "ece1276a-0c93-4c72-a1fd-9232e43b722c"
    }
}
'@

if ($OSDCloudGui.ComputerProduct -match 'Surface_Laptop_7th_Edition_With_Intel_For_Business') {
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Updating DriverPack Catalog in OSD Module at $GetModuleBase"
    if ($env:SystemRoot -eq 'X:') {
        $ModuleBase = Get-Module -Name OSD -ListAvailable | Select-Object -ExpandProperty ModuleBase -First 1
        $FilePath = "$ModuleBase\Catalogs\CloudDriverPacks.json"
        $FileContent = Get-Content -Path $FilePath -Raw
        $FileContent.Replace('SurfaceLaptopforBusiness7thEditionwithIntel_Win11_26100_25.013.32214.0.msi', 'SurfaceLaptopforBusiness7thEditionwithIntel_Win11_26100_25.013.32214.0.cab') | Set-Content -Path $FilePath -Force
        $FileContent.Replace('https://download.microsoft.com/download/1543bd80-9cae-498d-8b0f-9841e4d7b2a8', 'https://driverpack.blob.core.windows.net/public') | Set-Content -Path $FilePath -Force
        $FileContent | Set-Content $FilePath
    }
}
if ($OSDCloudGui.ComputerProduct -match 'XXXXXXXXXXXXXXXXXXXXXX') {
    <#
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Replacing OSDCloudGUI.DriverPack.Url"
    $Url = 'https://driverpack.blob.core.windows.net/public/SurfaceLaptopforBusiness7thEditionwithIntel_Win11_26100_25.013.32214.0.cab'
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] $Url"
    $OSDCloudGui.DriverPack.Url = $Url
    #>

    $GetModuleBase = Get-Module -Name OSD | Select-Object -ExpandProperty ModuleBase -First 1

    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Replacing DriverPack Catalog in OSD Module at $GetModuleBase"
    if ($env:SystemRoot -eq 'X:') {
        $SurfaceDriverPack | Out-File -FilePath "$GetModuleBase\Catalogs\CloudDriverPacks.json" -Encoding utf8 -Force
    }
}
#=================================================
Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDCloud Hotfix End"
#=================================================