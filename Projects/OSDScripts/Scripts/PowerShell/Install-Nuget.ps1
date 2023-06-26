[CmdletBinding()]
param ()
$Url = 'https://nuget.org/nuget.exe'
$FileName = 'NuGet.exe'

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if ($isAdmin) {
    $installPath = Join-Path -Path $env:ProgramData -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
}
else {
    $installPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
}

if (-not (Test-Path -Path $installPath)) {
    $null = New-Item -Path $installPath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}

$installFile = Join-Path -Path $installPath -ChildPath $FileName
$null = Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $installFile