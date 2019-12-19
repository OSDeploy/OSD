#===================================================================================================
#   Import Functions
#   https://github.com/RamblingCookieMonster/PSStackExchange/blob/master/PSStackExchange/PSStackExchange.psm1
#===================================================================================================
$OSDPublicFunctions  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$OSDPrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

foreach ($Import in @($OSDPublicFunctions + $OSDPrivateFunctions)) {
    Try {. $Import.FullName}
    Catch {Write-Error -Message "Failed to import function $($Import.FullName): $_"}
}

Export-ModuleMember -Function $OSDPublicFunctions.BaseName
#===================================================================================================
#   Get-SessionsXml
#===================================================================================================
try {New-Alias -Name Get-OSDSessions -Value Get-SessionsXml -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Mount-WindowsImageOSD
#===================================================================================================
try {New-Alias -Name Mount-OSDWindowsImage -Value Mount-WindowsImageOSD -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Update-WindowsImageOSD
#===================================================================================================
try {New-Alias -Name Update-OSDWindowsImage -Value Update-WindowsImageOSD -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Export-ModuleMember
#===================================================================================================
Export-ModuleMember -Function * -Alias *
#===================================================================================================