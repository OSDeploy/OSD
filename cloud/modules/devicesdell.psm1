<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module is designed to work in WinPE or Full
    This module is for Dell Devices and leveraged HP Tools
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1')
#>
#=================================================
#region Functions


#Function to Install DCU from Dell's website.
Function osdcloud-InstallDCU {
$SystemSKUNumber = (Get-CimInstance -ClassName Win32_ComputerSystem).SystemSKUNumber
$Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
$CabPath = "$env:temp\DellCabDownloads\DellSDPCatalogPC.cab"
$CabPathIndex = "$env:temp\DellCabDownloads\CatalogIndexPC.cab"
$CabPathIndexModel = "$env:temp\DellCabDownloads\CatalogIndexModel.cab"
$DellCabExtractPath = "$env:temp\DellCabDownloads\DellCabExtract"
$Compliance = $true
$Remediate = $false
$ComponentText = "DCU Apps"


# Pull down Dell XML CAB used in Dell Command Update ,extract and Load
if (!(Test-Path $DellCabExtractPath)){$newfolder = New-Item -Path $DellCabExtractPath -ItemType Directory -Force}
Write-Host "Downloading Dell Cab" -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://downloads.dell.com/catalog/CatalogIndexPC.cab" -OutFile $CabPathIndex -UseBasicParsing -Verbose -Proxy $ProxyServer
If(Test-Path "$DellCabExtractPath\DellSDPCatalogPC.xml"){Remove-Item -Path "$DellCabExtractPath\DellSDPCatalogPC.xml" -Force}
Start-Sleep -Seconds 1
if (test-path $DellCabExtractPath){Remove-Item -Path $DellCabExtractPath -Force -Recurse}
$NewFolder = New-Item -Path $DellCabExtractPath -ItemType Directory
Write-Host "Expanding the Cab File..... takes FOREVER...." -ForegroundColor Yellow
$Expand = expand $CabPathIndex $DellCabExtractPath\CatalogIndexPC.xml

write-host "Loading Dell Catalog XML.... can take awhile" -ForegroundColor Yellow
[xml]$XMLIndex = Get-Content "$DellCabExtractPath\CatalogIndexPC.xml" -Verbose


#Dig Through Dell XML to find Model of THIS Computer (Based on System SKU)
$XMLModel = $XMLIndex.ManifestIndex.GroupManifest | Where-Object {$_.SupportedSystems.Brand.Model.systemID -match $SystemSKUNumber}
if ($XMLModel)
    {
    CMTraceLog -Message  "Downloaded Dell DCU XML, now looking for Model Updates" -Type 1 -LogFile $LogFile
    Invoke-WebRequest -Uri "http://downloads.dell.com/$($XMLModel.ManifestInformation.path)" -OutFile $CabPathIndexModel -UseBasicParsing -Verbose -Proxy $ProxyServer
    if (Test-Path $CabPathIndexModel)
        {
        $Expand = expand $CabPathIndexModel $DellCabExtractPath\CatalogIndexPCModel.xml
        [xml]$XMLIndexCAB = Get-Content "$DellCabExtractPath\CatalogIndexPCModel.xml" -Verbose
        $DCUAvailable = $XMLIndexCAB.Manifest.SoftwareComponent | Where-Object {$_.ComponentType.value -eq ""}
        $DCUAppsAvailable = $XMLIndexCAB.Manifest.SoftwareComponent | Where-Object {$_.ComponentType.value -eq "APAC"}
        $AppNames = $DCUAppsAvailable.name.display.'#cdata-section' | Select-Object -Unique
        #This is using the x86 Windows version, not the UWP app.  You can change this if you like
        $AppDCUVersion = ([Version[]]$Version = ($DCUAppsAvailable | Where-Object {$_.path -match 'command-update' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64" -and $_.Description.Display.'#cdata-section' -notmatch "UWP"}).vendorVersion) | Sort-Object | Select-Object -Last 1
        $AppDCU = $DCUAppsAvailable | Where-Object {$_.path -match 'command-update' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64" -and $_.Description.Display.'#cdata-section' -notmatch "UWP" -and $_.Description.Display.'#cdata-section' -notmatch "Universal" -and $_.vendorVersion -eq $AppDCUVersion}
        $AppDCMVersion = ([Version[]]$Version = ($DCUAppsAvailable | Where-Object {$_.path -match 'Command-Monitor' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64"} | Select-Object -Property vendorVersion).vendorVersion) | Sort-Object | Select-Object -last 1
        $AppDCM = $DCUAppsAvailable | Where-Object {$_.path -match 'Command-Monitor' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64" -and $_.vendorVersion -eq $AppDCMVersion }
        
        $DCUDRIVERSAvailable = $XMLIndexCAB.Manifest.SoftwareComponent | Where-Object {$_.ComponentType.value -eq "DRVR"}
        $DCUFIRMWAREAvailable = $XMLIndexCAB.Manifest.SoftwareComponent | Where-Object {$_.ComponentType.value -eq "FRMW"}

        #Lets CHeck DCU First
        $DellItem = $AppDCU

        [Version]$DCUVersion = $DellItem.vendorVersion
        $DCUReleaseDate = $(Get-Date $DellItem.releaseDate -Format 'yyyy-MM-dd')               
        $TargetLink = "http://downloads.dell.com/$($DellItem.path)"
        $TargetFileName = ($DellItem.path).Split("/") | Select-Object -Last 1

        CMTraceLog -Message  "New Update available: Installed = $CurrentVersion DCU = $DCUVersion" -Type 1 -LogFile $LogFile
        Write-Host " New Update available: Installed = $CurrentVersion DCU = $DCUVersion" -ForegroundColor Yellow 
        CMTraceLog -Message  "  Title: $($DellItem.Name.Display.'#cdata-section')" -Type 1 -LogFile $LogFile
        Write-Output "  Title: $($DellItem.Name.Display.'#cdata-section')"
        CMTraceLog -Message  "  ----------------------------" -Type 1 -LogFile $LogFile
        Write-Host "  ----------------------------" -ForegroundColor Cyan
        CMTraceLog -Message  "   Severity: $($DellItem.Criticality.Display.'#cdata-section')" -Type 1 -LogFile $LogFile
        Write-Output "   Severity: $($DellItem.Criticality.Display.'#cdata-section')"
        CMTraceLog -Message  "   FileName: $TargetFileName" -Type 1 -LogFile $LogFile
        Write-Output "   FileName: $TargetFileName"
        CMTraceLog -Message  "    Release Date: $DCUReleaseDate" -Type 1 -LogFile $LogFile
        Write-Output "    Release Date: $DCUReleaseDate"
        CMTraceLog -Message  "   KB: $($DellItem.releaseID)" -Type 1 -LogFile $LogFile
        Write-Output "   KB: $($DellItem.releaseID)"
        CMTraceLog -Message  "   Link: $TargetLink" -Type 1 -LogFile $LogFile
        Write-Output "   Link: $TargetLink"
        CMTraceLog -Message  "   Info: $($DellItem.ImportantInfo.URL)" -Type 1 -LogFile $LogFile
        Write-Output "   Info: $($DellItem.ImportantInfo.URL)"
        CMTraceLog -Message  "   Version: $DCUVersion " -Type 1 -LogFile $LogFile
        Write-Output "    Version: $DCUVersion "

        #Build Required Info to Download and Update CM Package
        $TargetFilePathName = "$($DellCabExtractPath)\$($TargetFileName)"
        CMTraceLog -Message  "   Running Command: Invoke-WebRequest -Uri $TargetLink -OutFile $TargetFilePathName -UseBasicParsing -Verbose -Proxy $ProxyServer " -Type 1 -LogFile $LogFile
        Invoke-WebRequest -Uri $TargetLink -OutFile $TargetFilePathName -UseBasicParsing -Verbose -Proxy $ProxyServer

        #Confirm Download
        if (Test-Path $TargetFilePathName)
            {
            CMTraceLog -Message  "   Download Complete " -Type 1 -LogFile $LogFile
            $LogFileName = $TargetFilePathName.replace(".exe",".log")
            $Arguments = "/s /l=$LogFileName"
            Write-Output "Starting Update"
            write-output "Log file = $LogFileName"
            CMTraceLog -Message  " Running Command: Start-Process $TargetFilePathName $Arguments -Wait -PassThru " -Type 1 -LogFile $LogFile
            $Process = Start-Process "$TargetFilePathName" $Arguments -Wait -PassThru
            CMTraceLog -Message  " Update Complete with Exitcode: $($Process.ExitCode)" -Type 1 -LogFile $LogFile
            write-output "Update Complete with Exitcode: $($Process.ExitCode)"
            }
        else
            {
            CMTraceLog -Message  " FAILED TO DOWNLOAD Update" -Type 3 -LogFile $LogFile
            Write-Host " FAILED TO DOWNLOAD Update" -ForegroundColor Red
            $Compliance = $false
            }
        }
    else
        {
        #No Cab with XML was able to download
        Write-Host "No Model Cab Downloaded"
        CMTraceLog -Message  "No Model Cab Downloaded" -Type 2 -LogFile $LogFile
        }
}
else
    {
    #No Match in the DCU XML for this Model (SKUNumber)
    Write-Host "No Match in XML for $SystemSKUNumber"
    CMTraceLog -Message  "No Match in XML for $SystemSKUNumber" -Type 2 -LogFile $LogFile
    }

 } 

#Function to Run DCU to install drivers, BIOS and firmware updates.
 function osdcloud-RunDCU {

$DCUReturnTablet = @(
@{ReturnCode = "0";  Description = "Command execution was successful."; Resolution = "None"}
@{ReturnCode = "1";  Description = "A reboot was required from the execution of an operation."; Resolution = "Reboot the system to complete the operation."}
@{ReturnCode = "2";  Description = "An unknown application error has occurred."; Resolution = "None"}
@{ReturnCode = "3";  Description = "The current system manufacturer is not Dell."; Resolution = "Dell Command | Update can only be run on Dell systems."}
@{ReturnCode = "4";  Description = "The CLI was not launched with administrative privilege."; Resolution = "Invoke the Dell Command | Update CLI with administrative privileges."}
@{ReturnCode = "5";  Description = "A reboot was pending from a previous operation."; Resolution = "Reboot the system to complete the operation."}
@{ReturnCode = "6";  Description = "Another instance of the same application (UI or CLI) is already running."; Resolution = "Close any running instance of Dell Command | Update UI or CLI and retry the operation."}
@{ReturnCode = "7";  Description = "The application does not support the current system model."; Resolution = "Contact your administrator if the current system model in not supported by the catalog."}
@{ReturnCode = "8";  Description = "No update filters have been applied or configured."; Resolution = "Supply at least one update filter."}
@{ReturnCode = "1000";  Description = "An error occurred when retrieving the result of the apply updates operation."; Resolution = "Retry the operation."}
@{ReturnCode = "1001";  Description = "The cancellation was initiated, Hence, the apply updates operation is canceled."; Resolution = "Retry the operation."}
@{ReturnCode = "1002";  Description = "An error occurred while downloading a file during the apply updates operation."; Resolution = "Check your network connection, ensure there is Internet connectivity, and retry the command."}

)
$ProcessPath = 'C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe'
$ProcessArgs = '/applyUpdates -updateType=bios,firmware,drivers'

$DCU = Start-Process -FilePath $ProcessPath -ArgumentList $ProcessArgs -Wait -PassThru -NoNewWindow
$DCUReturn = $DCUReturnTablet | Where-Object {$_.ReturnCode -eq $DCU.ExitCode}

Write-Host "DCU Finished with Code: $($DCU.ExitCode): $($DCUReturn.Description)"
}

#endregion
#=================================================
