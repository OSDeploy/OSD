#===================================================================================================
#   Windows
#===================================================================================================
if ($env:SystemDrive -ne 'X:') {
    $OSDPublicFunctions  = @( Get-ChildItem -Path ("$PSScriptRoot\Public\*.ps1","$PSScriptRoot\WinOS\*.ps1") -Recurse -ErrorAction SilentlyContinue )
}
#===================================================================================================
#   WinPE
#===================================================================================================
if ($env:SystemDrive -eq 'X:') {
    $OSDPublicFunctions  = @( Get-ChildItem -Path ("$PSScriptRoot\Public\*.ps1","$PSScriptRoot\WinPE\*.ps1") -Recurse -ErrorAction SilentlyContinue )

    [System.Environment]::SetEnvironmentVariable('APPDATA', (Join-Path $env:USERPROFILE 'AppData\Roaming'),[System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('HOMEDRIVE', $env:SystemDrive,[System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('HOMEPATH', (($env:USERPROFILE) -split ":")[1],[System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA', (Join-Path $env:USERPROFILE 'AppData\Local'),[System.EnvironmentVariableTarget]::Machine)

    $VolatileEnvironment = "HKCU:\Volatile Environment"
    if (-NOT (Test-Path -Path $VolatileEnvironment)) {
        New-Item -Path $VolatileEnvironment -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "APPDATA" -Value (Join-Path $env:USERPROFILE 'AppData\Roaming') -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "HOMEDRIVE" -Value $env:SystemDrive -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "HOMEPATH" -Value (($env:USERPROFILE) -split ":")[1] -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "LOCALAPPDATA" -Value (Join-Path $env:USERPROFILE 'AppData\Local') -Force
    }
}

$OSDPrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

foreach ($Import in @($OSDPublicFunctions + $OSDPrivateFunctions)) {
    Try {. $Import.FullName}
    Catch {Write-Error -Message "Failed to import function $($Import.FullName): $_"}
}

Export-ModuleMember -Function $OSDPublicFunctions.BaseName

#===================================================================================================
#   Alias
#===================================================================================================
try {New-Alias -Name Copy-ModuleToFolder -Value Copy-PSModuleToFolder -Force -ErrorAction SilentlyContinue}
catch {}
try {New-Alias -Name Dismount-WindowsImageOSD -Value Dismount-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
try {New-Alias -Name Edit-WindowsImageOSD -Value Edit-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
try {New-Alias -Name Get-OSDSessions -Value Get-SessionsXml -Force -ErrorAction SilentlyContinue}
catch {}
try {New-Alias -Name Mount-OSDWindowsImage -Value Mount-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
try {New-Alias -Name Mount-WindowsImageOSD -Value Mount-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
try {New-Alias -Name Update-OSDWindowsImage -Value Update-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
try {New-Alias -Name Update-WindowsImageOSD -Value Update-MyWindowsImage -Force -ErrorAction SilentlyContinue}
catch {}
#===================================================================================================
#   Export-ModuleMember
#===================================================================================================
Export-ModuleMember -Function * -Alias *
#===================================================================================================