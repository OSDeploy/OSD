# Require Elevation
$whoiam = [system.security.principal.windowsidentity]::getcurrent().name
$isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if ($isElevated) {
    Write-Output "Running as $whoiam and IS Elevated"
}
else {
    Write-Warning "Running as $whoiam and is NOT Elevated"
    Break
}
