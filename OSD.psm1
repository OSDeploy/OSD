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
#   Start-OSDWinPE
#===================================================================================================
try {New-Alias -Name WinPE -Value Start-OSDWinPE -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Export-ModuleMember
#===================================================================================================
Export-ModuleMember -Function * -Alias *