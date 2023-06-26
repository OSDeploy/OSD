#Requires -Modules @{ ModuleName="OSD"; ModuleVersion="23.5.26.1" }
#Requires -RunAsAdministrator

#How To: Set the Product Key for Enterprise Volume

$EnterpriseProductKey = 'NPPR9-FWDCX-D2C8J-H872K-2YT43'
Get-WindowsEdition -Online
Invoke-Exe changepk.exe /ProductKey $EnterpriseProductKey
Get-WindowsEdition -Online