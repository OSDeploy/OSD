<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    Version 22.6.9.1
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



function osdcloud-WinpeUpdateDefender {
    <#
    Downloads the Defender Offline Update Kit, and applies to the OS.  Functions adopted from the PowerShell File embedded in the zip file: DefenderUpdateWinImage.ps1
    Orginal Script designed to work with WIM file, I've adopted it to work with Offline OS
    https://support.microsoft.com/en-us/topic/microsoft-defender-update-for-windows-operating-system-installation-images-1c89630b-61ff-00a1-04e2-2d1f3865450d

    #>
    function Get-PackageDetailsFromXml([string]$XmlPath)
    {
        if (!(Test-Path -Path $XmlPath)) {
            $global:LASTEXITCODE = $E_INVALIDPATH
            throw "Invalid path $XmlPath"
        }

        [xml]$xmlDoc = Get-Content -Path $XmlPath
        $pkgDetails = @{Architecture        = $xmlDoc.packageinfo.arch;
                        PackageVersion      = $xmlDoc.packageinfo.versions.defender;
                        CampVersion         = $xmlDoc.packageinfo.versions.platform;
                        EngineVersion       = $xmlDoc.packageinfo.versions.engine;
                        SignatureVersion    = $xmlDoc.packageinfo.versions.signatures}
        return $pkgDetails
    }
    function ValidateCodeSign([string]$PackageFile)
    {
        $signInfo = Get-AuthenticodeSignature $PackageFile
        if ($signInfo."Status" -ne "Valid") {
            Write-Host ($messages.ERR_INVALID_SIGNATURE -f $PackageFile) -ForegroundColor Red
            $signInfo | Format-List
            $global:LASTEXITCODE = $E_INVALIDPACKAGE
            throw ($messages.ERR_INVALID_SIGNATURE -f $PackageFile)
        }
    }
    function Show-Update {
        # Check if there exists any update already applied.
        $mountPoint = $Image
        $installedPkgXml = Join-Path -Path $mountPoint -ChildPath $WindowsTemp | Join-Path -ChildPath $PackageXml
        if (!(Test-Path -Path $installedPkgXml)) {
            Write-Host ($messages.INFO_NO_UPDATE_IN_IMAGE) -ForegroundColor Yellow
        } else {
            # Get package details to output.
            $pkgDetails = Get-PackageDetailsFromXml -XmlPath $installedPkgXml
            Write-Host ($messages.INFO_PACKAGE_DETAILS -f $pkgDetails.PackageVersion, $pkgDetails.SignatureVersion, $pkgDetails.EngineVersion, $pkgDetails.CampVersion) -ForegroundColor Yellow
        }

    }
    function Add-Update([string]$WorkingDir, [string]$Image, [string]$PkgFile)
    {
        # Validate DISM package Code signing information
        ValidateCodeSign -PackageFile $PkgFile

        # Validate Working Directory
        if (Test-Path -path $WorkingDir) {
            if (!(Get-ChildItem $WorkingDir | Measure-Object).Count -eq 0) {
                $global:LASTEXITCODE = $E_INVALIDINPUT
                throw ($messages.ERR_WORKINGDIR_NOT_EMPTY -f $WorkingDir)
            }
        }


        $mountPoint = $Image

        try {
            # Extract Cab
            $cabContent = Join-Path -Path $WorkingDir -ChildPath "cab"
            New-Item -itemtype directory -path $cabContent -Force | Out-Null
            $Expand = expand $PkgFile -F:* $cabContent | Out-Null
        } catch {
            Write-Host "Failed to Extract Cab" -ForegroundColor Red
            throw
        }

        try {

            # Definition updates
            Write-Host ($messages.INFO_UPDATE_ENGINE_SIGN) -ForegroundColor Yellow
            $defSrc     = Join-Path -Path $cabContent -ChildPath "Definition Updates\Updates"
            $defTarget  = Join-Path -Path $mountPoint -ChildPath $DefinitionsUpdatesLocation
            if (!(Test-Path -Path $defTarget)) { New-Item -itemtype directory -path $defTarget | Out-Null }
            Copy-Item -Path "$defSrc\*" -Destination $defTarget -Recurse -Force

            # Platform updates
            Write-Host ($messages.INFO_UPDATE_CAMP) -ForegroundColor Yellow
            $campSrc    = Join-Path -Path $cabContent -ChildPath "Platform"
            $campTarget = Join-Path -Path $mountPoint -ChildPath $PlatformLocation
            if (!(Test-Path -Path $campTarget)) { New-Item -itemtype directory -path $campTarget | Out-Null }
            Copy-Item -Path "$campSrc\*" -Destination $campTarget -Recurse -Force

            $campVersionFolder = Join-Path -Path $cabContent -ChildPath "Platform"
            $campVersionFolder = Get-ChildItem -Path $campVersionFolder -Directory -Name

            # Add Package Xml to Windows\Temp.
            $temp = Join-Path -Path $mountPoint -ChildPath $WindowsTemp
            $pkgXmlPath = Join-Path -Path $cabContent -ChildPath $PackageXml
            Copy-Item -Path $pkgXmlPath -Destination $temp -Force

            $global:LASTEXITCODE = $S_OK
        } catch {
            Write-Host ($messages.ERR_ADD_UPDATE) -ForegroundColor Red
            Write-Host $_ -ForegroundColor Yellow
            Write-Host $_.ScriptStackTrace -ForegroundColor Yellow
            Write-Host ($messages.INFO_DISCARD_IMAGE_UPDATE)
            Dismount-WindowsImage -Path $mountPoint -Discard | Out-Null
            throw
        } finally {
            Remove-Item -Path "$WorkingDir\*" -Recurse
        }
    }
    $uri                        = "https://go.microsoft.com/fwlink/?linkid=2144531"
    $Intermediate               = "$env:TEMP\DefenderScratchSpace"
    $WorkingDir                 = "$Intermediate\WorkingFolder"
    $ProgramDataDefender        = "ProgramData\Microsoft\Windows Defender"
    $ProgramFilesDefender       = "Program Files\Windows Defender"
    $ProgramFilesX86Defender    = "Program Files (x86)\Windows Defender"
    $DefinitionsUpdatesLocation = Join-Path -Path $ProgramDataDefender -ChildPath "Definition Updates\Updates"
    $PlatformLocation           = Join-Path -Path $ProgramDataDefender -ChildPath "Platform"
    $WindowsTemp                = "Windows\Temp"
    $PackageXml                 = "package-defender.xml"
    $PackageFile                = "$Intermediate\Extract\defender-dism-x64.cab"
    $Image                      = "C:\"
    $messages =
    @{
        #error messages
        ERR_INVALID_SIGNATURE       = "Update package ({0}) does not have a valid signature. Redownload the package.";
        ERR_UNSUPPORTED_OS_VERSION  = "Unsupported Windows OS image (version={0}). Windows 10 {1} or later versions are supported.";
        ERR_UNSUPPORTED_OS_UPDATE   = "Unsupported Windows 10 version. For Windows 10 RS (Redstone) images, apply the September 2018, or later, update and retry.";
        ERR_UNSUPPORTED_ARC_PACKAGE = "Wrong OS architecture for this package. This package supports {0}.";
        ERR_UNSUPPORTED_OS_ARC      = "Unsupported architecture of OS Image to service.";
        ERR_ADD_UPDATE              = "Failed to add the Defender update.";
        ERR_REMOVE_UPDATE           = "Failed to remove the Defender update.";
        ERR_NO_UPDATE_TO_REMOVE     = "There's no Defender update in this image.";
        ERR_SHOW_UPDATE             = "ShowUpdate failed";
        ERR_COMMAND_MISSING         = "Critical command `"{0}`" is missing. Install the required module and try again.";
        ERR_WORKINGDIR_NOT_EMPTY    = "The input working directory ({0}) is not empty. Clear it or select an empty directory and retry.";
        ERR_UPDATE_ALREADY_EXISTS   = "This image already contains another Defender update (version={0}). Run RemoveUpdate to clear it and try again";
        ERR_FAILED_ENABLE_DEFENDER  = "Failed to enable Defender in image ({1}) due to error ({0})."
        #info messages
        INFO_SERVER_ENABLE_DEFENDER = "Enabling Windows-Defender on the server image.";
        INFO_UPDATE_ENGINE_SIGN     = "Updating security intelligence and antimalware engine.";
        INFO_UPDATE_CAMP            = "Updating platform.";
        INFO_HANDLELING_LOCALIZATION = "Handling localization for {0}";
        INFO_PACKAGE_DETAILS        = "Details of Defender update applied to the image are:`n`tDefender package version: {0}`n`tSecurity intelligence version: {1}`n`tEngine version: {2}`n`tPlatform version: {3}";
        INFO_DISCARD_IMAGE_UPDATE   = "Discarding the changes and returning the OS image to its original state.";
        INFO_ADD_UPDATE_SUCCESS     = "Successfully updated Defender.";
        INFO_REMOVE_UPDATE_SUCCESS  = "Successfully removed the Defender update.";
        INFO_NO_UPDATE_IN_IMAGE     = "This image doesn't have a Defender update applied.";
        INFO_IMAGE_UPDATE_DETAILS   = "Details of the Defender update package in this image:"
        #warnings
    }
    
    if(!(Test-Path -Path "$Intermediate")) {
        $Null = New-Item -Path "$env:TEMP" -Name "DefenderScratchSpace" -ItemType Directory -Force
    }
    if(!(Test-Path -Path "$WorkingDir")) {
        $Null = New-Item -Path "$Intermediate" -Name "WorkingFolder" -ItemType Directory -Force
    }

    #Download Defender Kit File
    Write-Output "Starting Defender Kit Download"

    $Dest = "$Intermediate\" + 'defender-update-kit-x64.zip'
    $DefenderDef = Save-WebFile -SourceUrl $uri -DestinationDirectory $Intermediate -DestinationName 'defender-update-kit-x64.zip'
    
    if(Test-Path -Path $Dest) {
        Expand-Archive -Path $Dest -DestinationPath "$Intermediate\Extract" -Force
        Add-Update -WorkingDir $WorkingDir -Image $Image -PkgFile $PackageFile
        Show-Update
    }
    else {Write-Output "Failed Defender Kit Download"}
}
#endregion
#=================================================
