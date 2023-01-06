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
    $CabPathIndex = "$env:temp\DellCabDownloads\CatalogIndexPC.cab"
    $CabPathIndexModel = "$env:temp\DellCabDownloads\CatalogIndexModel.cab"
    $DellCabExtractPath = "$env:temp\DellCabDownloads\DellCabExtract"

    # Pull down Dell XML CAB used in Dell Command Update ,extract and Load
    if (!(Test-Path $DellCabExtractPath)){$newfolder = New-Item -Path $DellCabExtractPath -ItemType Directory -Force}
    Write-Host "Downloading Dell Cab" -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://downloads.dell.com/catalog/CatalogIndexPC.cab" -OutFile $CabPathIndex -UseBasicParsing -Verbose -Proxy $ProxyServer
    If(Test-Path "$DellCabExtractPath\DellSDPCatalogPC.xml"){Remove-Item -Path "$DellCabExtractPath\DellSDPCatalogPC.xml" -Force}
    Start-Sleep -Seconds 1
    if (test-path $DellCabExtractPath){Remove-Item -Path $DellCabExtractPath -Force -Recurse}
    $NewFolder = New-Item -Path $DellCabExtractPath -ItemType Directory
    Write-Host "Expanding the Cab File..." -ForegroundColor Yellow
    $Expand = expand $CabPathIndex $DellCabExtractPath\CatalogIndexPC.xml

    write-host "Loading Dell Catalog XML.... can take awhile" -ForegroundColor Yellow
    [xml]$XMLIndex = Get-Content "$DellCabExtractPath\CatalogIndexPC.xml" -Verbose


    #Dig Through Dell XML to find Model of THIS Computer (Based on System SKU)
    $XMLModel = $XMLIndex.ManifestIndex.GroupManifest | Where-Object {$_.SupportedSystems.Brand.Model.systemID -match $SystemSKUNumber}
    if ($XMLModel)
        {
        Invoke-WebRequest -Uri "http://downloads.dell.com/$($XMLModel.ManifestInformation.path)" -OutFile $CabPathIndexModel -UseBasicParsing -Verbose -Proxy $ProxyServer
        if (Test-Path $CabPathIndexModel)
            {
            $Expand = expand $CabPathIndexModel $DellCabExtractPath\CatalogIndexPCModel.xml
            [xml]$XMLIndexCAB = Get-Content "$DellCabExtractPath\CatalogIndexPCModel.xml" -Verbose
            $DCUAppsAvailable = $XMLIndexCAB.Manifest.SoftwareComponent | Where-Object {$_.ComponentType.value -eq "APAC"}
            #This is using the x86 Windows version, not the UWP app.  You can change this if you like
            $AppDCUVersion = ([Version[]]$Version = ($DCUAppsAvailable | Where-Object {$_.path -match 'command-update' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64" -and $_.Description.Display.'#cdata-section' -notmatch "UWP"}).vendorVersion) | Sort-Object | Select-Object -Last 1
            $AppDCU = $DCUAppsAvailable | Where-Object {$_.path -match 'command-update' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64" -and $_.Description.Display.'#cdata-section' -notmatch "UWP" -and $_.vendorVersion -eq $AppDCUVersion}
            if ($AppDCU){
                $DellItem = $AppDCU
                [Version]$DCUVersion = $DellItem.vendorVersion
                $DCUReleaseDate = $(Get-Date $DellItem.releaseDate -Format 'yyyy-MM-dd')               
                $TargetLink = "http://downloads.dell.com/$($DellItem.path)"
                $TargetFileName = ($DellItem.path).Split("/") | Select-Object -Last 1

                Write-Host " New Update available: Installed = $CurrentVersion DCU = $DCUVersion" -ForegroundColor Yellow 
                Write-Output "  Title: $($DellItem.Name.Display.'#cdata-section')"
                Write-Host "  ----------------------------" -ForegroundColor Cyan
                Write-Output "   Severity: $($DellItem.Criticality.Display.'#cdata-section')"
                Write-Output "   FileName: $TargetFileName"
                Write-Output "    Release Date: $DCUReleaseDate"
                Write-Output "   KB: $($DellItem.releaseID)"
                Write-Output "   Link: $TargetLink"
                Write-Output "   Info: $($DellItem.ImportantInfo.URL)"
                Write-Output "    Version: $DCUVersion "

                #Build Required Info to Download and Update CM Package
                $TargetFilePathName = "$($DellCabExtractPath)\$($TargetFileName)"
                Invoke-WebRequest -Uri $TargetLink -OutFile $TargetFilePathName -UseBasicParsing -Verbose -Proxy $ProxyServer

                #Confirm Download
                if (Test-Path $TargetFilePathName)
                    {
                    $LogFileName = $TargetFilePathName.replace(".exe",".log")
                    $Arguments = "/s /l=$LogFileName"
                    Write-Output "Starting Update"
                    write-output "Log file = $LogFileName"
                    $Process = Start-Process "$TargetFilePathName" $Arguments -Wait -PassThru
                    write-output "Update Complete with Exitcode: $($Process.ExitCode)"
                    }
                else
                    {
                    Write-Host " FAILED TO DOWNLOAD Update" -ForegroundColor Red
                    }
                }
            else{
            Write-Host "NO DCU Found in XML to download"
                }
            }
        else
            {
            #No Cab with XML was able to download
            Write-Host "No Model Cab Downloaded"
            }
    }
    else
        {
        #No Match in the DCU XML for this Model (SKUNumber)
        Write-Host "No Match in XML for $SystemSKUNumber"
        }

 } 

#Function to Run DCU to install drivers, BIOS and firmware updates.
function osdcloud-RunDCU {
    <#
    https://dl.dell.com/content/manual13608255-dell-command-update-version-4-x-reference-guide.pdf
    #Update Type: bios, firmware, driver, apps, and others
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("bios", "firmware", "driver", "apps", "other")]
        $UpdateType = "driver"
        )
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
    @{ReturnCode = "500";  Description = "No updates were found for the system when a scan operation was performed."; Resolution = "The system is up to date or no updates were found for the provided filters. Modify the filters and rerun the commands."}
    @{ReturnCode = "501";  Description = "An error occurred while determining the available updates for the system, when a scan operation was performed."; Resolution = "Retry the operation."}
    @{ReturnCode = "503";  Description = "An error occurred while downloading a file during the scan operation."; Resolution = "Check your network connection, ensure there is Internet connectivity and Retry the command."}
    @{ReturnCode = "1000";  Description = "An error occurred when retrieving the result of the apply updates operation."; Resolution = "Retry the operation."}
    @{ReturnCode = "1001";  Description = "The cancellation was initiated, Hence, the apply updates operation is canceled."; Resolution = "Retry the operation."}
    @{ReturnCode = "1002";  Description = "An error occurred while downloading a file during the apply updates operation."; Resolution = "Check your network connection, ensure there is Internet connectivity, and retry the command."}

    )
    $LogFolder = "c:\OSDCloud\Logs"
    $LogFile = "$LogFolder\DCU.log"
    $ProcessPath = 'C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe'
    $ProcessArgs = "/applyUpdates -updateType=$UpdateType -outputLog=$logfile -reboot=enable"
    if (!(test-path $ProcessPath -ErrorAction SilentlyContinue)){throw "No DCU Installed"}
    try {[void][System.IO.Directory]::CreateDirectory($LogFolder)}
    catch {throw}

    $DCU = Start-Process -FilePath $ProcessPath -ArgumentList $ProcessArgs -Wait -PassThru -NoNewWindow
    $DCUReturn = $DCUReturnTablet | Where-Object {$_.ReturnCode -eq $DCU.ExitCode}

    Write-Host "DCU Finished with Code: $($DCU.ExitCode): $($DCUReturn.Description)"
}


function osdcloud-DCUAutoUpdate {
    <#
    Enables DCU Auto Update
    #>

    $ProcessPath = 'C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe'
    $ProcessArgs = "/configure -scheduleAuto -scheduleAction=DownloadInstallAndNotify -scheduledReboot=60"
    if (!(test-path $ProcessPath -ErrorAction SilentlyContinue)){throw "No DCU Installed"}

    $DCU = Start-Process -FilePath $ProcessPath -ArgumentList $ProcessArgs -Wait -PassThru -NoNewWindow
    $DCUReturn = $DCUReturnTablet | Where-Object {$_.ReturnCode -eq $DCU.ExitCode}

    Write-Host "DCU Finished with Code: $($DCU.ExitCode): $($DCUReturn.Description)"
}


#endregion
#=================================================
