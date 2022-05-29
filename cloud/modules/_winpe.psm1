<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    Version 22.5.28.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpe.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpe.psm1')
#>
#=================================================
#region Functions
function osdcloud-WinpeInstallCurl {
    [CmdletBinding()]
    param ()
    if (-not (Get-Command 'curl.exe' -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor DarkGray 'Install Curl'
        $Uri = 'https://curl.se/windows/dl-7.81.0/curl-7.81.0-win64-mingw.zip'
        Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile "$env:TEMP\curl.zip"

        $null = New-Item -Path "$env:TEMP\Curl" -ItemType Directory -Force
        Expand-Archive -Path "$env:TEMP\curl.zip" -DestinationPath "$env:TEMP\curl"

        Get-ChildItem "$env:TEMP\curl" -Include 'curl.exe' -Recurse | foreach {Copy-Item $_ -Destination "$env:SystemRoot\System32\curl.exe"}
    }
}
function osdcloud-WinpeInstallNuget {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray 'Install Nuget'
    $NuGetClientSourceURL = 'https://nuget.org/nuget.exe'
    $NuGetExeName = 'NuGet.exe'

    $PSGetProgramDataPath = Join-Path -Path $env:ProgramData -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
    $nugetExeBasePath = $PSGetProgramDataPath
    if (-not (Test-Path -Path $nugetExeBasePath))
    {
        $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
    $null = Invoke-WebRequest -UseBasicParsing -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath

    $PSGetAppLocalPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
    $nugetExeBasePath = $PSGetAppLocalPath

    if (-not (Test-Path -Path $nugetExeBasePath))
    {
        $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
    $null = Invoke-WebRequest -UseBasicParsing -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath
}
function osdcloud-WinpeInstallPowerShellGet {
    [CmdletBinding()]
    param ()
    $InstalledModule = Import-Module PowerShellGet -PassThru -ErrorAction Ignore
    if (-not (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'})) {
        Write-Host -ForegroundColor DarkGray 'Install PowerShellGet'
        $PowerShellGetURL = "https://psg-prod-eastus.azureedge.net/packages/powershellget.2.2.5.nupkg"
        Invoke-WebRequest -UseBasicParsing -Uri $PowerShellGetURL -OutFile "$env:TEMP\powershellget.2.2.5.zip"
        $null = New-Item -Path "$env:TEMP\2.2.5" -ItemType Directory -Force
        Expand-Archive -Path "$env:TEMP\powershellget.2.2.5.zip" -DestinationPath "$env:TEMP\2.2.5"
        $null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet" -ItemType Directory -ErrorAction SilentlyContinue
        Move-Item -Path "$env:TEMP\2.2.5" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet\2.2.5"
        Import-Module PowerShellGet -Force -Scope Global
    }
}
function osdcloud-WinpeSetEnvironmentVariables {
    [CmdletBinding()]
    param ()
    if (Get-Item env:LocalAppData -ErrorAction Ignore) {
        Write-Verbose 'System Environment Variable LocalAppData is already present in this PowerShell session'
    }
    else {
        Write-Host -ForegroundColor DarkGray 'Set LocalAppData in System Environment'
        Write-Verbose 'WinPE does not have the LocalAppData System Environment Variable'
        Write-Verbose 'This can be enabled for this Power Session, but it will not persist'
        Write-Verbose 'Set System Environment Variable LocalAppData for this PowerShell session'
        #[System.Environment]::SetEnvironmentVariable('LocalAppData',"$env:UserProfile\AppData\Local")
        [System.Environment]::SetEnvironmentVariable('APPDATA',"$Env:UserProfile\AppData\Roaming",[System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('HOMEDRIVE',"$Env:SystemDrive",[System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('HOMEPATH',"$Env:UserProfile",[System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$Env:UserProfile\AppData\Local",[System.EnvironmentVariableTarget]::Process)
    }
}
#endregion
#=================================================
