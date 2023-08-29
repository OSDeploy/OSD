#Requires -RunAsAdministrator

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

# Cloud Drivers
Get-IntelEthernetDriverPack -UpdateModuleCatalog
Get-IntelGraphicsDriverPack -UpdateModuleCatalog
Get-IntelRadeonDriverPack -UpdateModuleCatalog
Get-IntelWirelessDriverPack -UpdateModuleCatalog

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

# Cloud Catalogs
Get-DellSystemCatalog -UpdateModuleCatalog
Get-HPPlatformCatalog -UpdateModuleCatalog
Get-HPSystemCatalog -UpdateModuleCatalog
Get-LenovoBiosCatalog -UpdateModuleCatalog

# Import OSD Module
Import-Module OSD -Force -ErrorAction Stop

# DriverPack Catalogs
Update-DellDriverPackCatalog -UpdateModuleCatalog -Verify
Update-HPDriverPackCatalog -UpdateModuleCatalog -Verify
Update-LenovoDriverPackCatalog -UpdateModuleCatalog -Verify
Update-MicrosoftDriverPackCatalog -UpdateModuleCatalog -Verify