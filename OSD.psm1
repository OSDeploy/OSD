#===================================================================================================
#   Import Functions
#   https://github.com/RamblingCookieMonster/PSStackExchange/blob/master/PSStackExchange/PSStackExchange.psm1
#===================================================================================================
if ($env:SystemDrive -eq 'X:') {
    $OSDPublicFunctions  = @( Get-ChildItem -Path ("$PSScriptRoot\Public\*.ps1","$PSScriptRoot\PublicPE\*.ps1") -Recurse -ErrorAction SilentlyContinue )
} else {
    $OSDPublicFunctions  = @( Get-ChildItem -Path ("$PSScriptRoot\Public\*.ps1","$PSScriptRoot\PublicOS\*.ps1") -Recurse -ErrorAction SilentlyContinue )
}
$OSDPrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

foreach ($Import in @($OSDPublicFunctions + $OSDPrivateFunctions)) {
    Try {. $Import.FullName}
    Catch {Write-Error -Message "Failed to import function $($Import.FullName): $_"}
}

Export-ModuleMember -Function $OSDPublicFunctions.BaseName
#===================================================================================================
#   Copy-ModuleToFolder
#===================================================================================================
try {New-Alias -Name Copy-ModuleToFolder -Value Copy-PSModuleToFolder -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Dismount-WindowsImageOSD
#===================================================================================================
try {New-Alias -Name Dismount-WindowsImageOSD -Value Dismount-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Edit-WindowsImageOSD
#===================================================================================================
try {New-Alias -Name Edit-WindowsImageOSD -Value Edit-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Get-SessionsXml
#===================================================================================================
try {New-Alias -Name Get-OSDSessions -Value Get-SessionsXml -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Mount-OSDWindowsImage
#===================================================================================================
try {New-Alias -Name Mount-OSDWindowsImage -Value Mount-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Mount-WindowsImageOSD
#===================================================================================================
try {New-Alias -Name Mount-WindowsImageOSD -Value Mount-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Update-OSDWindowsImage
#===================================================================================================
try {New-Alias -Name Update-OSDWindowsImage -Value Update-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Update-WindowsImageOSD
#===================================================================================================
try {New-Alias -Name Update-WindowsImageOSD -Value Update-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Export-ModuleMember
#===================================================================================================
Export-ModuleMember -Function * -Alias *
#===================================================================================================