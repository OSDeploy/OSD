<#
.LINK
	https://www.osdeploy.com/
.SYNOPSIS
	Displays registry entries from all RegistryXML files in the Source Directory
.DESCRIPTION
	Displays registry entries from all RegistryXML files in the Source Directory
.PARAMETER SourceDirectory
	Directory to search for XML files
.EXAMPLE
	Show-RegistryXML -SourceDirectory C:\DeploymentShare\OSDeploy\OSConfig\LocalPolicy\ImportGPO
	Displays all RegistryXML entries found in Source Directory
.NOTES
	NAME:	Show-RegistryXML.ps1
	AUTHOR:	David Segura, david@segura.org
	BLOG:	http://www.osdeploy.com
	VERSION:	18.9.4
#>
function Show-RegistryXML {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
		[string]$SourceDirectory
	)
    BEGIN {}
    PROCESS {
		$ErrorActionPreference = 'SilentlyContinue'
		$RegistryPreferences = Get-ChildItem "$SourceDirectory" *.xml -Recurse

		if (!($RegistryPreferences)) {
			Write-Host "Could not find any compatible Registry XML files"
		} else {
			#=================================================
			# 	Process Registry XML
			#=================================================
			foreach ($RegistryXml in $RegistryPreferences) {
				$RegistrySettings = @()
				$RegistrySettings
				Write-Host "Processing $($RegistryXml.FullName)" -ForegroundColor Yellow
				Write-Host ""

				[xml]$XmlDocument = Get-Content -Path $RegistryXml.FullName
				$nodes = $XmlDocument.SelectNodes("//*[@action]")

				foreach ($node in $nodes) {
					$NodeAction = $node.attributes['action'].value
					$NodeDefault = $node.attributes['default'].value
					$NodeHive = $node.attributes['hive'].value
					$NodeKey = $node.attributes['key'].value
					$NodeName = $node.attributes['name'].value
					$NodeType = $node.attributes['type'].value
					$NodeValue = $node.attributes['value'].value

					$obj = new-object psobject -prop @{Action=$NodeAction;Default=$NodeDefault;Hive=$NodeHive;Key=$NodeKey;Name=$NodeName;Type=$NodeType;Value=$NodeValue}
					$RegistrySettings += $obj
				}

				foreach ($RegEntry in $RegistrySettings) {
					$RegAction = $RegEntry.Action
					$RegDefault = $RegEntry.Default
					$RegHive = $RegEntry.Hive
					$RegKey = $RegEntry.Key
					$RegName = $RegEntry.Name
					$RegType = $RegEntry.Type
					$RegType = $RegType -replace 'REG_SZ','String'
					$RegType = $RegType -replace 'REG_DWORD','DWord'
					$RegType = $RegType -replace 'REG_QWORD','QWord'
					$RegType = $RegType -replace 'REG_MULTI_SZ','MultiString'
					$RegType = $RegType -replace 'REG_EXPAND_SZ','ExpandString'
					$RegType = $RegType -replace 'REG_BINARY','Binary'
					$RegValue = $RegEntry.Value

					if ($RegType -eq 'Binary') {
						$RegValue = $RegValue -replace '(..(?!$))','$1,'
						$RegValue = $RegValue.Split(',') | ForEach-Object {"0x$_"}
					}

					$RegPath = "Registry::$RegHive\$RegKey"
					$RegPathAdmin = "Registry::HKEY_LOCAL_MACHINE\MountedAdministrator\$RegKey"
					$RegPathDUser = "Registry::HKEY_LOCAL_MACHINE\MountedDefaultUser\$RegKey"

					if ($RegAction -eq "D") {
						if ($RegDefault -eq '0' -and $RegName -eq '' -and $RegValue -eq '') {
							Write-Host "Remove-Item -LiteralPath $RegPath" -ForegroundColor Red
							#Remove-Item -LiteralPath $RegPath -Force
						} elseif ($RegDefault -eq '1') {
							Write-Host "Remove-ItemProperty -LiteralPath $RegPath" -ForegroundColor Red
							Write-Host "-Name '(Default)'"
							#Remove-ItemProperty -LiteralPath $RegPath -Name '(Default)' -Force
						} else {
							Write-Host "Remove-ItemProperty -LiteralPath $RegPath" -ForegroundColor Red
							Write-Host "-Name $RegName"
							#Remove-ItemProperty -LiteralPath $RegPath -Name $RegName -Force
						}
						
						if ($RegHive -eq 'HKEY_CURRENT_USER'){
							if (Test-Path -Path "HKLM:\MountedAdministrator") {
								Write-Host "Remove-ItemProperty -LiteralPath $RegPathAdmin" -ForegroundColor Red
								if ($RegDefault -eq '0' -and $RegName -eq '' -and $RegValue -eq '') {
									#Remove-ItemProperty -LiteralPath $RegPathAdmin -Force
								} elseif ($RegDefault -eq '1') {
									Write-Host "-Name '(Default)'"
									#Remove-ItemProperty -LiteralPath $RegPathAdmin -Name '(Default)' -Force
								} else {
									Write-Host "-Name $RegName"
									#Remove-ItemProperty -LiteralPath $RegPathAdmin -Name $RegName -Force
								}
							}
							if (Test-Path -Path "HKLM:\MountedDefaultUser") {
								Write-Host "Remove-ItemProperty -LiteralPath $RegPathDUser" -ForegroundColor Red
								if ($RegDefault -eq '0' -and $RegName -eq '' -and $RegValue -eq '') {
									#Remove-ItemProperty -LiteralPath $RegPathDUser -Force
								} elseif ($RegDefault -eq '1') {
									Write-Host "-Name '(Default)'"
									#Remove-ItemProperty -LiteralPath $RegPathDUser -Name '(Default)' -Force
								} else {
									Write-Host "-Name $RegName"
									#Remove-ItemProperty -LiteralPath $RegPathDUser -Name $RegName -Force
								}
							}
						}
					} else {
						if ($RegDefault -eq '1') {$RegName = '(Default)'}
						if (!($RegType -eq '')) {
							if (!(Test-Path -LiteralPath $RegPath)) {
								Write-Host "New-Item -Path $RegPath" -ForegroundColor Green
								#New-Item -Path $RegPath -Force | Out-Null
							}
							if ($RegHive -eq 'HKEY_CURRENT_USER'){
								if (Test-Path -Path "HKLM:\MountedAdministrator") {
									if (!(Test-Path -LiteralPath $RegPathAdmin)) {
										Write-Host "New-Item -Path $RegPathAdmin" -ForegroundColor Green
										#New-Item -Path $RegPathAdmin -Force | Out-Null
									}
								}
								if (Test-Path -Path "HKLM:\MountedDefaultUser") {
									if (!(Test-Path -LiteralPath $RegPathDUser)) {
										Write-Host "New-Item -Path $RegPathDUser" -ForegroundColor Green
										#New-Item -Path $RegPathDUser -Force | Out-Null
									}
								}
							}
							Write-Host "New-ItemProperty -LiteralPath $RegPath" -ForegroundColor Green
							Write-Host "-Name $RegName -PropertyType $RegType -Value $RegValue"
							#New-ItemProperty -LiteralPath $RegPath -Name $RegName -PropertyType $RegType -Value $RegValue -Force | Out-Null
							if ($RegHive -eq 'HKEY_CURRENT_USER'){
								if (Test-Path -Path "HKLM:\MountedAdministrator") {
									Write-Host "New-ItemProperty -LiteralPath $RegPathAdmin" -ForegroundColor Green
									Write-Host "-Name $RegName -PropertyType $RegType -Value $RegValue"
									#New-ItemProperty -LiteralPath $RegPathAdmin -Name $RegName -PropertyType $RegType -Value $RegValue -Force | Out-Null
								}
								if (Test-Path -Path "HKLM:\MountedDefaultUser") {
									Write-Host "New-ItemProperty -LiteralPath $RegPathDUser" -ForegroundColor Green
									Write-Host "-Name $RegName -PropertyType $RegType -Value $RegValue"
									#New-ItemProperty -LiteralPath $RegPathDUser -Name $RegName -PropertyType $RegType -Value $RegValue -Force | Out-Null
								}
							}
						}
					}
					Write-Host ""
				}
			}
			Remove-Item Variable:RegistrySettings
		}
	}
	END {}
}