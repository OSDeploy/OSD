<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module is designed to work in WinPE or Full
    This module is for HP Devices and leveraged HP Tools
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')
#>
#=================================================
#region Functions

#Some Dependancies on these Functions
Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')

function osdcloud-addserviceui {
    [CmdletBinding()]
    param ()
    $EXEName = "ServiceUI.exe"
    $EXEURL = "https://github.com/gwblok/garytown/raw/master/OSD/CloudOSD/$EXEName"
    Invoke-WebRequest -UseBasicParsing -Uri $EXEURL -OutFile "$env:TEMP\$EXEName"
}
function osdcloud-TestHPIASupport {
    $CabPath = "$env:TEMP\platformList.cab"
    $XMLPath = "$env:TEMP\platformList.xml"
    $PlatformListCabURL = "https://hpia.hpcloud.hp.com/ref/platformList.cab"
    Invoke-WebRequest -Uri $PlatformListCabURL -OutFile $CabPath -UseBasicParsing
    $Expand = expand $CabPath $XMLPath
    [xml]$XML = Get-Content $XMLPath
    $Platforms = $XML.ImagePal.Platform.SystemID
    $MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
    if ($MachinePlatform -in $Platforms){$HPIASupport = $true}
    else {$HPIASupport = $false}

    return $HPIASupport
    }

function osdcloud-InstallModuleHPCMSL {
    [CmdletBinding()]
    param ()
    osdcloud-SetExecutionPolicy
    $InstallModule = $false
    $PSModuleName = 'HPCMSL'
    if (-not (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'})) {
        Write-Host -ForegroundColor DarkGray 'Install-Package PackageManagement,PowerShellGet [AllUsers]'
        Install-Package -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Confirm:$false -Source PSGallery | Out-Null

        Write-Host -ForegroundColor DarkGray 'Import-Module PackageManagement,PowerShellGet [Global]'
        Import-Module PackageManagement,PowerShellGet -Force -Scope Global -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        }
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            $InstallModule = $true
        }
    }
    else {
        $InstallModule = $true
    }

    if ($InstallModule) {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -SkipPublisherCheck -Scope AllUsers -Force -AcceptLicense -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -SkipPublisherCheck -AcceptLicense -Scope AllUsers -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
    }
    Import-Module -Name $PSModuleName -Force -Global -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}
function osdcloud-HPTPMDetermine{
    $SP87753 = Get-CimInstance  -Namespace "root\cimv2\security\MicrosoftTPM" -query "select * from win32_tpm where IsEnabled_InitialValue = 'True' and ((ManufacturerVersion like '7.%' and ManufacturerVersion < '7.63.3353') or (ManufacturerVersion like '5.1%') or (ManufacturerVersion like '5.60%') or (ManufacturerVersion like '5.61%') or (ManufacturerVersion like '4.4%') or (ManufacturerVersion like '6.40%') or (ManufacturerVersion like '6.41%') or (ManufacturerVersion like '6.43.243.0') or (ManufacturerVersion like '6.43.244.0'))"
    $SP94937 = Get-CimInstance  -Namespace "root\cimv2\security\MicrosoftTPM" -query "select * from win32_tpm where IsEnabled_InitialValue = 'True' and ((ManufacturerVersion like '7.62%') or (ManufacturerVersion like '7.63%') or (ManufacturerVersion like '7.83%') or (ManufacturerVersion like '6.43%') )"
    if ($SP87753){Return "SP87753"}
    elseif ($SP94937){Return "SP94937"}
    else{Return $false}
}
function osdcloud-HPTPMDowngrade{
    [String]$TPMVer = (Get-CimInstance  -Namespace "root\cimv2\security\MicrosoftTPM" -ClassName win32_tpm).ManufacturerVersion
    if ($TPMVer -eq "7.85.4555.0"){$SPNumber = "SP94937"}
    if ($TPMVer -eq "7.63.3353.0"){$SPNumber = "SP87753"}  Need to confirm test machine to determine 
    if ($SPNumber -ne $null){
        if ((!($WorkingFolder))-or ($null -eq $WorkingFolder)){$WorkingFolder = "$env:TEMP\TPM"}
        if (!(Test-Path -Path $WorkingFolder)){New-Item -Path $WorkingFolder -ItemType Directory -Force |Out-Null}
        $UpdatePath = "$WorkingFolder\$SPNumber.exe"
        $extractPath = "$WorkingFolder\$SPNumber"
        Write-Host "Starting downlaod & Install of TPM Update $SPNumber"
        Get-Softpaq -Number $SPNumber -SaveAs $UpdatePath -Overwrite yes
        Start-Process -FilePath $UpdatePath -ArgumentList "/s /e /f $extractPath" -Wait
        Suspend-BitLocker -MountPoint c: -RebootCount 2 -ErrorAction SilentlyContinue
        if ($TPMVer -eq "7.85.4555.0"){Start-Process -FilePath "$extractPath\TPMConfig64.exe" -ArgumentList "-xVTx"}
        if ($TPMVer -eq "7.63.3353.0"){Start-Process -FilePath "$extractPath\TPMConfig64.exe" -ArgumentList "-xVTx"}
    }
    else
        {
        Write-Host "No Downgrade SP available"
    }
}
function osdcloud-HPTPMBIOSSettings {
    osdcloud-HPBIOSSetSetting -SettingName 'TPM Device' -Value 'Available'
    osdcloud-HPBIOSSetSetting -SettingName 'TPM State' -Value 'Enable'
    osdcloud-HPBIOSSetSetting -SettingName 'TPM Activation Policy' -Value 'No prompts'
}
function osdcloud-HPBIOSDetermine{
    [CmdletBinding()]
    param ([Switch]$Details)
    osdcloud-InstallModuleHPCMSL
    Import-Module -Name HPCMSL -Force
    $BIOSIsCurrent = Get-HPBIOSUpdates -Check
    if ($Details){
        if (!($BIOSIsCurrent)){Return "HP BIOS Update Available: $((Get-HPBIOSUpdates -Latest).ver)"}
        else {Return "HP BIOS Already Current: $(Get-HPBIOSVersion)"}
        }
    else
        {
        if ($BIOSIsCurrent){Return $false}
        else {Return $true}
        }
}
function osdcloud-HPTPMDownload {
    [CmdletBinding()]
    param ($WorkingFolder)
    osdcloud-InstallModuleHPCMSL
    Import-Module -Name HPCMSL -Force
    $TPMUpdate = osdcloud-HPTPMDetermine    
    if ($TPMUpdate -ne $false)
        {
        if ((!($WorkingFolder))-or ($null -eq $WorkingFolder)){$WorkingFolder = "$env:TEMP\TPM"}
        if (!(Test-Path -Path $WorkingFolder)){New-Item -Path $WorkingFolder -ItemType Directory -Force |Out-Null}
        $UpdatePath = "$WorkingFolder\$TPMUpdate.exe"
        $extractPath = "$WorkingFolder\$TPMUpdate"
        Write-Host "Starting downlaod & Install of TPM Update $TPMUpdate"
        Get-Softpaq -Number $TPMUpdate -SaveAs $UpdatePath -Overwrite yes
        if (!(Test-Path -Path $UpdatePath)){Throw "Failed to Download TPM Update"}
        Start-Process -FilePath $UpdatePath -ArgumentList "/s /e /f $extractPath" -Wait
        if (!(Test-Path -Path $UpdatePath)){Throw "Failed to Extract TPM Update"}
        else {
            Return $extractPath
            }
        }    
}
function osdcloud-HPTPMEXEDownload {
    osdcloud-InstallModuleHPCMSL
    osdcloud-HPBIOSSetSetting -SettingName 'Virtualization Technology (VTx)' -Value 'Disable'
    Import-Module -Name HPCMSL -Force
    $TPMUpdate = osdcloud-HPTPMDetermine
    if ($TPMUpdate -ne $false)
        {
        $DownloadFolder = "C:\OSDCloud\HP\TPM"
        if (!(Test-Path -Path $DownloadFolder)){New-Item -Path $DownloadFolder -ItemType Directory -Force |Out-Null}
        $UpdatePath = "$DownloadFolder\$TPMUpdate.exe"
        Write-Host "Starting download of TPM Update $TPMUpdate"
        Get-Softpaq -Number $TPMUpdate -SaveAs $UpdatePath -Overwrite yes
        if (!(Test-Path -Path $UpdatePath)){Throw "Failed to Download TPM Update"}
    }    
}
function osdcloud-HPTPMEXEInstall {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        $path,
        [Parameter(Mandatory=$false)]
        $filename,
        [Parameter(Mandatory=$false)]
        $spec,
        [Parameter(Mandatory=$false)]
        $logsuffix,
        [Parameter(Mandatory=$false)]
        $WorkingFolder
        )
    $DownloadFolder = "C:\OSDCloud\HP\TPM"
    $TPMUpdate = (Get-ChildItem -Path $DownloadFolder -Filter *.exe).FullName
    if (Test-Path $TPMUpdate){
        Start-Process -FilePath $TPMUpdate -ArgumentList "/s /e /f $DownloadFolder" -Wait
        if (!(Test-Path -Path "$DownloadFolder\TPMConfig64.exe")){Throw "Failed to Extract TPM Update"}
        $Process = "$DownloadFolder\TPMConfig64.exe"
        #Create Argument List
        if ($filename -and $spec){$TPMArg = "-s -f$filename -a$spec -l$($env:temp)\TPMConfig.log"}
        elseif ($filename -and !($spec)) { $TPMArg = "-s -f$filename -l$($env:temp)\TPMConfig.log"}
        elseif (!($filename) -and $spec) { $TPMArg = "-s -a$spec -l$($env:temp)\TPMConfig.log"}
        elseif (!($filename) -and !($spec)) { $TPMArg = "-s -l$($env:temp)\TPMConfig.log"}
        
        Write-Output "Running Command: Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait"
        $TPMUpdate = Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait
        write-output "TPMUpdate Exit Code: $($TPMUpdate.exitcode)"
    }
    else {Throw "Failed to Locate Update Path"}
}
#does not work in pe
function osdcloud-HPBIOSEXEDownload {
    osdcloud-InstallModuleHPCMSL
    Import-Module -Name HPCMSL -Force
    $SoftpaqNumber = (Get-SoftpaqList -Category BIOS | Select-Object -Last 1).id
    $DownloadFolder = "C:\OSDCloud\HP\BIOS"
            if (!(Test-Path -Path $DownloadFolder)){New-Item -Path $DownloadFolder -ItemType Directory -Force |Out-Null}
            $UpdatePath = "$DownloadFolder\$BIOSUpdate.exe"
            Write-Host "Starting download of System Firmware Update $BIOSUpdate"
            Get-Softpaq -Number $SoftpaqNumber -SaveAs $UpdatePath -Overwrite yes
            if (!(Test-Path -Path $UpdatePath)){Throw "Failed to Download System Firmware Update"}
}
function osdcloud-HPTPMUpdate {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        $path,
        [Parameter(Mandatory=$false)]
        $filename,
        [Parameter(Mandatory=$false)]
        $spec,
        [Parameter(Mandatory=$false)]
        $logsuffix,
        [Parameter(Mandatory=$false)]
        $WorkingFolder
        )
    $logsuffix = osdcloud-HPTPMDetermine
    if ($logsuffix -ne $false){
        write-output "Determined TPM Update $logsuffix required"
        if ((Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue).ProtectionStatus -eq "ON"){
            Suspend-BitLocker -MountPoint $env:SystemDrive -RebootCount 2 | Out-Null}
        osdcloud-HPBIOSSetSetting -SettingName 'Virtualization Technology (VTx)' -Value 'Disable'
        $extractPath = osdcloud-HPTPMDownload -WorkingFolder $WorkingFolder
        if (!(Test-Path -Path $extractPath)){Throw "Failed to Locate Update Path"}
        $Process = "$extractPath\TPMConfig64.exe"
        #Create Argument List
        if ($filename -and $spec){$TPMArg = "-s -f$filename -a$spec -l$($env:temp)\TPMConfig_$($logsuffix).log"}
        elseif ($filename -and !($spec)) { $TPMArg = "-s -f$filename -l$($env:temp)\TPMConfig_$($logsuffix).log"}
        elseif (!($filename) -and $spec) { $TPMArg = "-s -a$spec -l$($env:temp)\TPMConfig_$($logsuffix).log"}
        elseif (!($filename) -and !($spec)) { $TPMArg = "-s -l$($env:temp)\TPMConfig_$($logsuffix).log"}
        
        Write-Output "Running Command: Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait"
        $TPMUpdate = Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait
        write-output "TPMUpdate Exit Code: $($TPMUpdate.exitcode)"
    }
    else {
        osdcloud-HPBIOSSetSetting -SettingName 'Virtualization Technology (VTx)' -Value 'Enable'
        return "No TPM Update Available"
    }
    }
Function osdcloud-HPIAOfflineSync {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("All", "BIOS", "Driver", "Software", "Firmware", "UWPPack")]
        $Category = "Driver",
        [Parameter(Mandatory=$false)]
        $OS = "win10",
        [Parameter(Mandatory=$false)]
        $Release = "21H2"
        )
    
    #Create HPIA Repo & Sync for this Platform (EXE / Online)
    $LogFolder = "C:\OSDCloud\Logs"
    $HPIARepoFolder = "C:\OSDCloud\HPIA\Repo"
    $PlatformCode = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
    New-Item -Path $HPIARepoFolder -ItemType Directory -Force | Out-Null
    $CurrentLocation = Get-Location
    Set-Location -Path $HPIARepoFolder
    Initialize-Repository | out-null
    Set-RepositoryConfiguration -Setting OfflineCacheMode -CacheValue Enable | out-null
    Add-RepositoryFilter -Os $OS -OsVer $Release -Category $Category -Platform $PlatformCode | out-null
    Write-Host "Starting HPCMSL to create HPIA Repo for $($PlatformCode) with Drivers" -ForegroundColor Green
    write-host " This process can take several minutes to download all drivers" -ForegroundColor Gray
    write-host " Writing Progress Log to $LogFolder" -ForegroundColor Gray
    write-host " Downloading to $HPIARepoFolder" -ForegroundColor Gray
    Invoke-RepositorySync -Verbose 4> "$LogFolder\HPIAOfflineSync.log"
    Set-Location $CurrentLocation
    Write-Host "Completed Driver Download for HP Device to be applied in OOBE" -ForegroundColor Green
}
Function osdcloud-HPIAExecute {
<#
    Update HP Drivers via HPIA - Gary Blok - @gwblok
    Several Code Snips taken from: https://smsagent.blog/2021/03/30/deploying-hp-bios-updates-a-real-world-example/
    
    
    HPIA User Guide: https://ftp.ext.hp.com/pub/caps-softpaq/cmit/whitepapers/HPIAUserGuide.pdf
    
    Notes about Severity:
    Routine – For new hardware support and feature enhancements.
    Recommended – For minor bug fixes. HP recommends this SoftPaq be installed.
    Critical – For major bug fixes, specific problem resolutions, to enable new OS or Service Pack. Essentially the SoftPaq is required to receive support from HP.
    
    
    #>
    [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$false)]
            [ValidateSet("Analyze", "DownloadSoftPaqs")]
            $Operation = "Analyze",
            [Parameter(Mandatory=$false)]
            [ValidateSet("All", "BIOS", "Drivers", "Software", "Firmware", "Accessories")]
            $Category = "Drivers",
            [Parameter(Mandatory=$false)]
            [ValidateSet("All", "Critical", "Recommended", "Routine")]
            $Selection = "All",
            [Parameter(Mandatory=$false)]
            [ValidateSet("List", "Download", "Extract", "Install", "UpdateCVA")]
            $Action = "Install",
            [Parameter(Mandatory=$false)]
            $LogFolder = "$env:systemdrive\OSDCloud\Logs",
            [Parameter(Mandatory=$false)]
            $ReportsFolder = "$env:systemdrive\OSDCloud\HPIA",
            [Parameter(Mandatory=$false)]
            $OfflineFolder = "$env:systemdrive\OSDCloud\HPIA\Repo",
            [Parameter(Mandatory=$false)]
            [ValidateSet($true, $false)]
            $OfflineMode = $false
            )
        # Params
        $HPIAWebUrl = "https://ftp.hp.com/pub/caps-softpaq/cmit/HPIA.html" # Static web page of the HP Image Assistant
        $script:FolderPath = "HP_Updates" # the subfolder to put logs into in the storage container
        $ProgressPreference = 'SilentlyContinue' # to speed up web requests
        
        #Record currently running Processes:
        #Get-Process | Select-Object -Property Name, Description | Out-File C:\osdcloud\Logs\HPIA-RunningProcesses.txt
        
        ################################
        ## Create Directory Structure ##
        ################################
        $DateTime = Get-Date –Format "yyyyMMdd-HHmmss"
        $ReportsFolder = "$ReportsFolder\$DateTime"
        $HPIALogFile = "$LogFolder\Run-HPIA.log"
        $script:TempWorkFolder = "C:\Windows\Temp\HPIA"
        try 
        {
            [void][System.IO.Directory]::CreateDirectory($LogFolder)
            [void][System.IO.Directory]::CreateDirectory($TempWorkFolder)
            [void][System.IO.Directory]::CreateDirectory($ReportsFolder)
        }
        catch 
        {
            throw
        }
        # Function write to a log file in ccmtrace format
        function CMTraceLog {
                [CmdletBinding()]
        Param (
                [Parameter(Mandatory=$false)]
                $Message,
                [Parameter(Mandatory=$false)]
                $ErrorMessage,
                [Parameter(Mandatory=$false)]
                $Component = "Script",
                [Parameter(Mandatory=$false)]
                [int]$Type,
                [Parameter(Mandatory=$false)]
                $LogFile = $HPIALogFile
            )
        <#
        Type: 1 = Normal, 2 = Warning (yellow), 3 = Error (red)
        #>
            $Time = Get-Date -Format "HH:mm:ss.ffffff"
            $Date = Get-Date -Format "MM-dd-yyyy"
            if ($ErrorMessage -ne $null) {$Type = 3}
            if ($Component -eq $null) {$Component = " "}
            if ($Type -eq $null) {$Type = 1}
            $LogMessage = "<![LOG[$Message $ErrorMessage" + "]LOG]!><time=`"$Time`" date=`"$Date`" component=`"$Component`" context=`"`" type=`"$Type`" thread=`"`" file=`"`">"
            $LogMessage.Replace("`0","") | Out-File -Append -Encoding UTF8 -FilePath $LogFile
        }
        CMTraceLog –Message "#######################" –Component "Preparation"
        CMTraceLog –Message "## Starting HPIA  ##" –Component "Preparation"
        CMTraceLog –Message "#######################" –Component "Preparation"
        Write-Host "Starting HPIA to Update HP Drivers" -ForegroundColor Magenta
        #################################
        ## Disable IE First Run Wizard ##
        #################################
        # This prevents an error running Invoke-WebRequest when IE has not yet been run in the current context
        CMTraceLog –Message "Disabling IE first run wizard" –Component "Preparation"
        $null = New-Item –Path "HKLM:\SOFTWARE\Policies\Microsoft" –Name "Internet Explorer" –Force
        $null = New-Item –Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" –Name "Main" –Force
        $null = New-ItemProperty –Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" –Name "DisableFirstRunCustomize" –PropertyType DWORD –Value 1 –Force
        ##########################
        ## Get latest HPIA Info ##
        ##########################
        CMTraceLog –Message "Finding info for latest version of HP Image Assistant (HPIA)" –Component "Download"
        try
        {
            $HTML = Invoke-WebRequest –Uri $HPIAWebUrl –ErrorAction Stop -UseBasicParsing
        }
        catch 
        {
            CMTraceLog –Message "Failed to download the HPIA web page. $($_.Exception.Message)" –Component "Download" -Type 3
            throw
        }
        $HPIASoftPaqNumber = ($HTML.Links | Where {$_.href -match "hp-hpia-"}).outerText
        $HPIADownloadURL = ($HTML.Links | Where {$_.href -match "hp-hpia-"}).href
        $HPIAFileName = $HPIADownloadURL.Split('/')[-1]
        CMTraceLog –Message "SoftPaq number is $HPIASoftPaqNumber" –Component "Download"
        CMTraceLog –Message "Download URL is $HPIADownloadURL" –Component "Download"
        Write-Host "Download URL is $HPIADownloadURL" -ForegroundColor Green
        ###################
        ## Download HPIA ##
        ###################
        CMTraceLog –Message "Downloading HPIA" –Component "DownloadHPIA"
        Write-Host "Downloading HPIA" -ForegroundColor Green
        if (!(Test-Path -Path "$TempWorkFolder\$HPIAFileName")){
            try 
            {
                $ExistingBitsJob = Get-BitsTransfer –Name "$HPIAFileName" –AllUsers –ErrorAction SilentlyContinue
                If ($ExistingBitsJob)
                {
                    CMTraceLog –Message "An existing BITS tranfer was found. Cleaning it up." –Component "Download" –Type 2
                    Remove-BitsTransfer –BitsJob $ExistingBitsJob
                }
                $BitsJob = Start-BitsTransfer –Source $HPIADownloadURL –Destination $TempWorkFolder\$HPIAFileName –Asynchronous –DisplayName "$HPIAFileName" –Description "HPIA download" –RetryInterval 60 –ErrorAction Stop 
                do {
                    Start-Sleep –Seconds 5
                    $Progress = [Math]::Round((100 * ($BitsJob.BytesTransferred / $BitsJob.BytesTotal)),2)
                    CMTraceLog –Message "Downloaded $Progress`%" –Component "Download"
                } until ($BitsJob.JobState -in ("Transferred","Error"))
                If ($BitsJob.JobState -eq "Error")
                {
                    CMTraceLog –Message "BITS tranfer failed: $($BitsJob.ErrorDescription)" –Component "Download" –Type 3
                }
                CMTraceLog –Message "Download is finished" –Component "Download"
                Complete-BitsTransfer –BitsJob $BitsJob
                CMTraceLog –Message "BITS transfer is complete" –Component "Download"
                Write-Host "BITS transfer is complete" -ForegroundColor Green
            }
            catch 
            {
                CMTraceLog –Message "Failed to start a BITS transfer for the HPIA: $($_.Exception.Message)" –Component "Download" –Type 3
                Write-Host "Failed to start a BITS transfer for the HPIA: $($_.Exception.Message)" -ForegroundColor Red
            }
            if (!(Test-Path -Path $TempWorkFolder\$HPIAFileName)){
                write-host "Failed to download HPIA using BITS, trying WebRequest"  -ForegroundColor yellow
                Invoke-WebRequest -UseBasicParsing -uri $HPIADownloadURL -OutFile $TempWorkFolder\$HPIAFileName -ErrorAction Stop
            }
        }
        else
            {
            CMTraceLog –Message "$HPIAFileName already downloaded, skipping step" –Component "Download"
            Write-Host "$HPIAFileName already downloaded, skipping step" -ForegroundColor Green
            }
        ##################
        ## Extract HPIA ##
        ##################
        CMTraceLog –Message "Extracting HPIA" –Component "Extract"
        Write-Host "Extracting HPIA" -ForegroundColor Green
        try 
        {
            $Process = Start-Process –FilePath $TempWorkFolder\$HPIAFileName –WorkingDirectory $TempWorkFolder –ArgumentList "/s /f .\HPIA\ /e" –NoNewWindow –PassThru –Wait –ErrorAction Stop
            Start-Sleep –Seconds 5
            If (Test-Path $TempWorkFolder\HPIA\HPImageAssistant.exe)
            {
                CMTraceLog –Message "Extraction complete" –Component "Extract"
            }
            Else  
            {
                CMTraceLog –Message "HPImageAssistant not found!" –Component "Extract" –Type 3
                Write-Host "HPImageAssistant not found!" -ForegroundColor Red
                throw
            }
        }
        catch 
        {
            CMTraceLog –Message "Failed to extract the HPIA: $($_.Exception.Message)" –Component "Extract" –Type 3
            Write-Host "Failed to extract the HPIA: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }
        ##############################################
        ## Install Updates with HPIA ##
        ##############################################
        #CMTraceLog –Message "/Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action  /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" –Component "Update"
        #Write-Host "Running HPIA With Args: /Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action  /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" -ForegroundColor Green
        #osdcloud-addserviceui -ErrorAction SilentlyContinue
        try 
        {
            if ($OfflineMode -eq $false){
                if (Test-Path -path $env:temp\ServiceUI.exe)
                    {
                        CMTraceLog –Message "Running HPIA With Args: $env:temp\ServiceUI.exe -process:WinLogon.exe $TempWorkFolder\HPIA\HPImageAssistant.exe –WorkingDirectory $TempWorkFolder /Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action  /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" –Component "Update"
                        Write-Host "Running HPIA With Args: $env:temp\ServiceUI.exe -process:WinLogon.exe $TempWorkFolder\HPIA\HPImageAssistant.exe –WorkingDirectory $TempWorkFolder /Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action  /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" -ForegroundColor Green                   
                    $Process = Start-Process –FilePath $env:temp\ServiceUI.exe –ArgumentList "-process:WinLogon.exe $TempWorkFolder\HPIA\HPImageAssistant.exe –WorkingDirectory $TempWorkFolder /Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" –NoNewWindow –PassThru –ErrorAction Stop
                }
                else {                
                    CMTraceLog –Message "Running HPIA With Args: /Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action  /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" –Component "Update"
                    Write-Host "Running HPIA With Args: /Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action  /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" -ForegroundColor Green                   
                    $Process = Start-Process –FilePath $TempWorkFolder\HPIA\HPImageAssistant.exe –WorkingDirectory $TempWorkFolder –ArgumentList "/Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" –NoNewWindow –PassThru –ErrorAction Stop
                }
                #CMTraceLog –Message "/Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action  /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" –Component "Update"
                #Write-Host "Running HPIA With Args: /Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action  /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" -ForegroundColor Green
                #$Process = Start-Process –FilePath $TempWorkFolder\HPIA\HPImageAssistant.exe –WorkingDirectory $TempWorkFolder –ArgumentList "/Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" –NoNewWindow –PassThru –Wait –ErrorAction Stop
                }
            if ($OfflineMode -eq $true){
                CMTraceLog –Message "/Offlinemode:$Offlinefolder /Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action  /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" –Component "Update"
                Write-Host "Running HPIA With Args: /Offlinemode:$Offlinefolder /Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action  /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" -ForegroundColor Green 
                $Process = Start-Process –FilePath $TempWorkFolder\HPIA\HPImageAssistant.exe –WorkingDirectory $TempWorkFolder –ArgumentList "/Offlinemode:$Offlinefolder /Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action /Noninteractive /Debug /ReportFolder:$ReportsFolder /LogFolder:$ReportsFolder" –NoNewWindow –PassThru –ErrorAction Stop
                }
            
            #Bring Progress Bar to Front
            start-sleep -Seconds 10
            write-host "Attempting to bring HPIA Progress bar to top"
            (New-Object -ComObject WScript.Shell).AppActivate((get-process HPImageAssistant.dll).Description)
            
            #Wait for Process to Finish
            $Process = Get-Process -name "HPImageAssistant" -ErrorAction SilentlyContinue
            if ($Process -ne $null){
                write-host "Waiting for HPIA Process to Finish"
                $Process.WaitForExit()
            }
            $ExitCode = $process.GetType().GetField('exitCode', 'NonPublic, Instance').GetValue($process)
            #$Process = Start-Process –FilePath $TempWorkFolder\HPIA\HPImageAssistant.exe –WorkingDirectory $TempWorkFolder –ArgumentList "/Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action /Noninteractive /Debug /LogFolder:$ReportsFolder" –NoNewWindow –PassThru –Wait –ErrorAction Stop

            If ($ExitCode -eq 0)
            {
                CMTraceLog –Message "Analysis complete" –Component "Update"
                Write-Host "Analysis complete" -ForegroundColor Green
            }
            elseif ($ExitCode -eq 256) 
            {
                CMTraceLog –Message "Exit $($ExitCode) - The analysis returned no recommendation." –Component "Update" –Type 2
                Write-Host "Exit $($ExitCode) - The analysis returned no recommendation." -ForegroundColor Green
                Exit 0
            }
                elseif ($ExitCode -eq 257) 
            {
                CMTraceLog –Message "Exit $($ExitCode) - There were no recommendations selected for the analysis." –Component "Update" –Type 2
                Write-Host "Exit $($ExitCode) - There were no recommendations selected for the analysis." -ForegroundColor Green
                Exit 0
            }
            elseif ($ExitCode -eq 3010) 
            {
                CMTraceLog –Message "Exit $($ExitCode) - HPIA Complete, requires Restart" –Component "Update" –Type 2
                Write-Host "Exit $($ExitCode) - HPIA Complete, requires Restart" -ForegroundColor Yellow
            }
            elseif ($ExitCode -eq 3020) 
            {
                CMTraceLog –Message "Exit $($ExitCode) - Install failed — One or more SoftPaq installations failed." –Component "Update" –Type 2
                Write-Host "Exit $($ExitCode) - Install failed — One or more SoftPaq installations failed." -ForegroundColor Yellow
            }
            elseif ($ExitCode -eq 4096) 
            {
                CMTraceLog –Message "Exit $($ExitCode) - This platform is not supported!" –Component "Update" –Type 2
                Write-Host "Exit $($ExitCode) - This platform is not supported!" -ForegroundColor Yellow
                throw
            }
            Else
            {
                CMTraceLog –Message "Process exited with code $($ExitCode). Expecting 0." –Component "Update" –Type 3
                Write-Host "Process exited with code $($ExitCode). Expecting 0." -ForegroundColor Yellow
                throw
            }
        }
        catch 
        {
            CMTraceLog –Message "Failed to start the HPImageAssistant.exe: $($_.Exception.Message)" –Component "Update" –Type 3
            Write-Host "Failed to start the HPImageAssistant.exe: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }
        ##############################################
        ## Gathering Addtional Information ##
        ##############################################
    
        CMTraceLog –Message "Reading xml report" –Component "Report"
        try 
        {
            $XMLFile = Get-ChildItem –Path $ReportsFolder –Recurse –Include *.xml –ErrorAction Stop
            If ($XMLFile)
            {
                CMTraceLog –Message "Report located at $($XMLFile.FullName)" –Component "Report"
                try 
                {
                    [xml]$XML = Get-Content –Path $XMLFile.FullName –ErrorAction Stop
                    if ($Category -eq "BIOS" -or $Category -eq "All"){
                        CMTraceLog –Message "Checking BIOS Recommendations" –Component "Report"
                        Write-Host "Checking BIOS Recommendations" -ForegroundColor Green 
                        $null = $Recommendation
                        $Recommendation = $xml.HPIA.Recommendations.BIOS.Recommendation
                        If ($Recommendation)
                        {
                            $ItemName = $Recommendation.TargetComponent
                            $CurrentBIOSVersion = $Recommendation.TargetVersion
                            $ReferenceBIOSVersion = $Recommendation.ReferenceVersion
                            $DownloadURL = "https://" + $Recommendation.Solution.Softpaq.Url
                            $SoftpaqFileName = $DownloadURL.Split('/')[-1]
                            CMTraceLog –Message "Component: $ItemName" –Component "Report"
                            Write-Host "Component: $ItemName" -ForegroundColor Gray                           
                            CMTraceLog –Message " Current version is $CurrentBIOSVersion" –Component "Report"
                            Write-Host " Current version is $CurrentBIOSVersion" -ForegroundColor Gray
                            CMTraceLog –Message " Recommended version is $ReferenceBIOSVersion" –Component "Report"
                            Write-Host " Recommended version is $ReferenceBIOSVersion" -ForegroundColor Gray
                            CMTraceLog –Message " Softpaq download URL is $DownloadURL" –Component "Report"
                            Write-Host " Softpaq download URL is $DownloadURL" -ForegroundColor Gray
                        }
                        Else  
                        {
                            CMTraceLog –Message "No BIOS recommendation in the XML report" –Component "Report" –Type 2
                            Write-Host "No BIOS recommendation in XML" -ForegroundColor Gray
                        }
                    }
                    if ($Category -eq "drivers" -or $Category -eq "All"){
                        CMTraceLog –Message "Checking Driver Recommendations" –Component "Report"
                        Write-Host "Checking Driver Recommendations" -ForegroundColor Green                
                        $null = $Recommendation
                        $Recommendation = $xml.HPIA.Recommendations.drivers.Recommendation
                        If ($Recommendation){
                            Foreach ($item in $Recommendation){
                                $ItemName = $item.TargetComponent
                                $CurrentBIOSVersion = $item.TargetVersion
                                $ReferenceBIOSVersion = $item.ReferenceVersion
                                $DownloadURL = "https://" + $item.Solution.Softpaq.Url
                                $SoftpaqFileName = $DownloadURL.Split('/')[-1]
                                CMTraceLog –Message "Component: $ItemName" –Component "Report"
                                Write-Host "Component: $ItemName" -ForegroundColor Gray                           
                                CMTraceLog –Message " Current version is $CurrentBIOSVersion" –Component "Report"
                                Write-Host " Current version is $CurrentBIOSVersion" -ForegroundColor Gray
                                CMTraceLog –Message " Recommended version is $ReferenceBIOSVersion" –Component "Report"
                                Write-Host " Recommended version is $ReferenceBIOSVersion" -ForegroundColor Gray
                                CMTraceLog –Message " Softpaq download URL is $DownloadURL" –Component "Report"
                                Write-Host " Softpaq download URL is $DownloadURL" -ForegroundColor Gray
                                }
                            }
                        Else  
                            {
                            CMTraceLog –Message "No Driver recommendation in the XML report" –Component "Report" –Type 2
                            Write-Host "No Driver recommendation in XML" -ForegroundColor Gray
                            }
                        }
                        if ($Category -eq "Software" -or $Category -eq "All"){
                        CMTraceLog –Message "Checking Software Recommendations" –Component "Report"
                        Write-Host "Checking Software Recommendations" -ForegroundColor Green 
                        $null = $Recommendation
                        $Recommendation = $xml.HPIA.Recommendations.software.Recommendation
                        If ($Recommendation){
                            Foreach ($item in $Recommendation){
                                $ItemName = $item.TargetComponent
                                $CurrentBIOSVersion = $item.TargetVersion
                                $ReferenceBIOSVersion = $item.ReferenceVersion
                                $DownloadURL = "https://" + $item.Solution.Softpaq.Url
                                $SoftpaqFileName = $DownloadURL.Split('/')[-1]
                                CMTraceLog –Message "Component: $ItemName" –Component "Report"
                                Write-Host "Component: $ItemName" -ForegroundColor Gray                           
                                CMTraceLog –Message "Current version is $CurrentBIOSVersion" –Component "Report"
                                Write-Host " Current version is $CurrentBIOSVersion" -ForegroundColor Gray
                                CMTraceLog –Message "Recommended version is $ReferenceBIOSVersion" –Component "Report"
                                Write-Host " Recommended version is $ReferenceBIOSVersion" -ForegroundColor Gray
                                CMTraceLog –Message "Softpaq download URL is $DownloadURL" –Component "Report"
                                Write-Host " Softpaq download URL is $DownloadURL" -ForegroundColor Gray
                            }
                        }
                        Else  
                            {
                            CMTraceLog –Message "No Software recommendation in the XML report" –Component "Report" –Type 2
                            Write-Host "No Software recommendation in XML" -ForegroundColor Gray
                            }
                    }
                }
                catch 
                {
                    CMTraceLog –Message "Failed to parse the XML file: $($_.Exception.Message)" –Component "Report" –Type 3
                }
            }
            Else  
            {
                CMTraceLog –Message "Failed to find an XML report." –Component "Report" –Type 3
                }
        }
        catch 
        {
            CMTraceLog –Message "Failed to find an XML report: $($_.Exception.Message)" –Component "Report" –Type 3
        }
        ## Overview History of HPIA
        try 
        {
            $JSONFile = Get-ChildItem –Path $ReportsFolder –Recurse –Include *.JSON –ErrorAction Stop
            If ($JSONFile)
            {
                Write-Host "Reporting Full HPIA Results" -ForegroundColor Green
                CMTraceLog –Message "JSON located at $($JSONFile.FullName)" –Component "Report"
                try 
                {
                $JSON = Get-Content –Path $JSONFile.FullName  –ErrorAction Stop | ConvertFrom-Json
                CMTraceLog –Message "HPIAOpertaion: $($JSON.HPIA.HPIAOperation)" –Component "Report"
                Write-Host " HPIAOpertaion: $($JSON.HPIA.HPIAOperation)" -ForegroundColor Gray
                CMTraceLog –Message "ExitCode: $($JSON.HPIA.ExitCode)" –Component "Report"
                Write-Host " ExitCode: $($JSON.HPIA.ExitCode)" -ForegroundColor Gray
                CMTraceLog –Message "LastOperation: $($JSON.HPIA.LastOperation)" –Component "Report"
                Write-Host " LastOperation: $($JSON.HPIA.LastOperation)" -ForegroundColor Gray
                CMTraceLog –Message "LastOperationStatus: $($JSON.HPIA.LastOperationStatus)" –Component "Report"
                Write-Host " LastOperationStatus: $($JSON.HPIA.LastOperationStatus)" -ForegroundColor Gray
                $Recommendations = $JSON.HPIA.Recommendations
                if ($Recommendations) {
                    Write-Host "HPIA Item Results" -ForegroundColor Green
                    foreach ($item in $Recommendations){
                        $ItemName = $Item.Name
                        $ItemRecommendationValue = $Item.RecommendationValue
                        $ItemSoftPaqID = $Item.SoftPaqID
                        CMTraceLog –Message " $ItemName $ItemRecommendationValue | $ItemSoftPaqID" –Component "Report"
                        Write-Host " $ItemName $ItemRecommendationValue | $ItemSoftPaqID" -ForegroundColor Gray
                        CMTraceLog –Message "  URL: $($Item.ReleaseNotesUrl)" –Component "Report"
                        write-host "  URL: $($Item.ReleaseNotesUrl)" -ForegroundColor Gray
                        CMTraceLog –Message "  Status: $($item.Remediation.Status)" –Component "Report"
                        Write-Host "  Status: $($item.Remediation.Status)" -ForegroundColor Gray
                        CMTraceLog –Message "  ReturnCode: $($item.Remediation.ReturnCode)" –Component "Report"
                        Write-Host "  ReturnCode: $($item.Remediation.ReturnCode)" -ForegroundColor Gray
                        CMTraceLog –Message "  ReturnDescription: $($item.Remediation.ReturnDescription)" –Component "Report"
                        Write-Host "  ReturnDescription: $($item.Remediation.ReturnDescription)" -ForegroundColor Gray
                        }
                    }
                }
                catch {
                CMTraceLog –Message "Failed to parse the JSON file: $($_.Exception.Message)" –Component "Report" –Type 3
                }
            }
        }
        catch
        {
        CMTraceLog –Message "NO JSON report." –Component "Report" –Type 1
        }
    }

function osdcloud-HPIADownload {
    Write-Host "Pre-Caching HPIA to Device"  -ForegroundColor DarkGray
    $null = New-Item –Path "HKLM:\SOFTWARE\Policies\Microsoft" –Name "Internet Explorer" –Force
    $null = New-Item –Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" –Name "Main" –Force
    $null = New-ItemProperty –Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" –Name "DisableFirstRunCustomize" –PropertyType DWORD –Value 1 –Force
    $HPIAWebUrl = "https://ftp.hp.com/pub/caps-softpaq/cmit/HPIA.html"
    $script:TempWorkFolder = "c:\windows\temp\HPIA"
    [void][System.IO.Directory]::CreateDirectory($TempWorkFolder)
    $HTML = Invoke-WebRequest –Uri $HPIAWebUrl –ErrorAction Stop -UseBasicParsing
            
    $HPIASoftPaqNumber = ($HTML.Links | Where {$_.href -match "hp-hpia-"}).outerText
    $HPIADownloadURL = ($HTML.Links | Where {$_.href -match "hp-hpia-"}).href
    $HPIAFileName = $HPIADownloadURL.Split('/')[-1]
    Write-Host " Download URL is $HPIADownloadURL" -ForegroundColor DarkGray
    
    Write-Host " Downloading HPIA" -ForegroundColor Green
    if (!(Test-Path -Path "$TempWorkFolder\$HPIAFileName")){
        try 
        {
            $ExistingBitsJob = Get-BitsTransfer –Name "$HPIAFileName" –AllUsers –ErrorAction SilentlyContinue
            If ($ExistingBitsJob)
            {
                Remove-BitsTransfer –BitsJob $ExistingBitsJob
            }
            $BitsJob = Start-BitsTransfer –Source $HPIADownloadURL –Destination $TempWorkFolder\$HPIAFileName –Asynchronous –DisplayName "$HPIAFileName" –Description "HPIA download" –RetryInterval 60 –ErrorAction Stop 
            do {
                Start-Sleep –Seconds 5
                $Progress = [Math]::Round((100 * ($BitsJob.BytesTransferred / $BitsJob.BytesTotal)),2)
            } until ($BitsJob.JobState -in ("Transferred","Error"))
            Complete-BitsTransfer –BitsJob $BitsJob
            Write-Host " BITS transfer is complete" -ForegroundColor DarkGray
        }
        catch 
        {
        }
        if (!(Test-Path -Path $TempWorkFolder\$HPIAFileName)){
            Invoke-WebRequest -UseBasicParsing -uri $HPIADownloadURL -OutFile $TempWorkFolder\$HPIAFileName -ErrorAction Stop
        }
        if (Test-Path -Path "$TempWorkFolder\$HPIAFileName"){
            Write-Host " HPIA download is complete" -ForegroundColor DarkGray
        }
        else {Write-Host " HPIA download failed" -ForegroundColor red}
    }
    else
        {
        Write-Host " $HPIAFileName already downloaded, skipping step" -ForegroundColor DarkGray
        }
    }    

function osdcloud-HPBIOSUpdate {
    #Stage Firmware Update for Next Reboot
    Write-Host -ForegroundColor DarkGray "========================================================================="
    osdcloud-InstallModuleHPCMSL
    Write-Host -ForegroundColor Cyan "Updating HP System Firmware"
    if (Get-HPBIOSSetupPasswordIsSet){Write-Host -ForegroundColor Red "Device currently has BIOS Setup Password, Please Update BIOS via different method"}
    else{
        Write-Host -ForegroundColor DarkGray "Current Firmware: $(Get-HPBIOSVersion)"
        Write-Host -ForegroundColor DarkGray "Staging Update: $((Get-HPBIOSUpdates -Latest).ver) "
        #Details: https://developers.hp.com/hp-client-management/doc/Get-HPBiosUpdates
        Get-HPBIOSUpdates -Flash -Yes -Offline -BitLocker Ignore
    }
}

function osdcloud-HPBIOSSetSetting {
    [CmdletBinding()]
Param (
	[Parameter(Mandatory=$true)]
	$SettingName,
	[Parameter(Mandatory=$true)]
	$Value,
	[Parameter(Mandatory=$false)]
	$BIOSPW
	)

<# Testing
$SettingName = "SVM CPU Virtualization"
$Value = "Enable"
$BIOSPW = 'P@ssw0rd'
#>

$BIOS= Get-WmiObject -class hp_biossettinginterface -Namespace "root\hp\instrumentedbios"
$BIOSSetting = Get-CimInstance -class hp_biossetting -Namespace "root\hp\instrumentedbios"
$CurrentValue = ($BIOSSetting | ?{ $_.Name -eq $SettingName }).CurrentValue

if ($CurrentValue -ne $Null)
    {
    if ($CurrentValue -eq $Value)
        {
        Write-Output "BIOS Setting: $SettingName already configured to Requested Value: $Value"
        }
    else
        {
        If (($BIOSSetting | ?{ $_.Name -eq 'Setup Password' }).IsSet -eq 0){
            $Result = $BIOS.SetBIOSSetting($SettingName,$Value)
            }
        else{
            $PW = "<utf-16/>$BIOSPW"
            $Result = $BIOS.SetBIOSSetting($SettingName,$Value,$PW)
            }
        if ($Result.Return -eq 0){
            Write-Output "Successfully Updated: $SettingName to: $Value"
            }
        else{
            $BIOSSetting = Get-CimInstance -class hp_biossetting -Namespace "root\hp\instrumentedbios"
            $CurrentValue = ($BIOSSetting | ?{ $_.Name -eq $SettingName }).CurrentValue
            Write-Output "Failed to Update BIOS Setting: $SettingName to: $Value"
            Write-Output "Current Value: $CurrentValue"
            }
        }
    }
else
    {
    Write-Output "BIOS Setting: $SettingName is NOT Available on this Hardware"
    }
}

function osdcloud-HPSetupCompleteAppend {

    $ScriptsPath = "C:\Windows\Setup\scripts"
    if (!(Test-Path -Path $ScriptsPath)){New-Item -Path $ScriptsPath} 

    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (Test-Path -Path $PSFilePath){
        Add-Content -Path $PSFilePath "Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')"
        Add-Content -Path $PSFilePath "Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/eq-winpe.psm1')"
        Add-Content -Path $PSFilePath "Invoke-Expression (Invoke-RestMethod -Uri 'functions.osdcloud.com' -ErrorAction SilentlyContinue)"
        Add-Content -Path $PSFilePath "osdcloud-WinpeSetEnvironmentVariables"
        Add-Content -Path $PSFilePath "osdcloud-InstallModuleHPCMSL -ErrorAction SilentlyContinue"
        Add-Content -Path $PSFilePath 'Write-Host "Running HP Tools in SetupComplete" -ForegroundColor Green'
        Add-Content -Path $PSFilePath "osdcloud-HPBIOSSetSetting -SettingName 'Virtualization Technology (VTx)' -Value 'Enable'"
        if ($Global:OSDCloud.HPIADrivers -eq $true){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Drivers" -ForegroundColor Magenta'
            if (Test-Path -path "C:\OSDCloud\HPIA\Repo"){Add-Content -Path $PSFilePath "osdcloud-RunHPIA -OfflineMode True -Category Drivers"}
            else {Add-Content -Path $PSFilePath "osdcloud-HPIAExecute -Category Drivers"}
        }
        if (($Global:OSDCloud.HPIAFirmware -eq $true) -and ($Global:OSDCloud.HPIAAll  -ne $true)){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Firmware" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "osdcloud-HPIAExecute -Category Firmware"
        } 
        if (($Global:OSDCloud.HPIASoftware -eq $true) -and ($Global:OSDCloud.HPIAAll  -ne $true)){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Software" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "osdcloud-HPIAExecute -Category Software"
        } 
        if ($Global:OSDCloud.HPIAAll -eq $true){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Software" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "osdcloud-HPIAExecute -Category All"
        }            
        if ($Global:OSDCloud.HPTPMUpdate -eq $true){
            #Add-Content -Path $PSFilePath 'Write-Host "Updating TPM Firmware" -ForegroundColor Magenta'
            #Add-Content -Path $PSFilePath "osdcloud-TPMEXEInstall"
        } 
        if ($Global:OSDCloud.HPBIOSUpdate -eq $true){
            Add-Content -Path $PSFilePath 'Write-Host "Running HP System Firmware" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "osdcloud-HPBIOSUpdate"
        }
    }
    else {
    Write-Output "$PSFilePath - Not Found"
    }

}
#endregion
#=================================================