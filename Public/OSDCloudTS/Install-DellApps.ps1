Function Install-DellApps {
    <#
    Gary Blok | @gwblok

    Updates  on DELL machines by finding latest version avialble in Dell Command Update XML, Downloading and installing, then triggers a Reboot

    Used the Dell DCU Legacy Install, not the Universal / UWP app Install.  If you want to modify it for yourself, search for "UWP" and make needed changes.

    Changes: 
    23.03.09 
     - Updated to deal with multiple DCU's being returned
     - Added App Matching, if you already have "Universal" installed, it will install the Universal.
     - Removed Date Time modification on whim that it is causing issues
     - Updated some variable names from DCU... to DCM ... to make reading code easier.
    23.11.09
     - Updated to fix issue https://github.com/gwblok/garytown/issues/12
       - When DCU or DCM is NOT installed, set version to 0.0.0.0 instead of NULL

    #>

    $temproot = "$env:windir\temp"
    $ScriptVersion = "24.05.21.1"
    $whoami = $env:USERNAME
    $OSDCloudFolder = "C:\OSDCloud"
    $LogFilePath = "$OSDCloudFolder\Logs"
    $LogFile = "$LogFilePath\Dell-Updates.log"
    $scriptName = "Dell DCU Update - From Cloud"
    $SystemSKUNumber = (Get-CimInstance -ClassName Win32_ComputerSystem).SystemSKUNumber
    #$SystemSKUNumber = "0B0B" #Testing
    $Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
    $CabPathIndex = "$temproot\DellCabDownloads\CatalogIndexPC.cab"
    $CabPathIndexModel = "$temproot\DellCabDownloads\CatalogIndexModel.cab"
    $DellCabExtractPath = "$temproot\DellCabDownloads\DellCabExtract"
    $Compliance = $true
    $Remediate = $true
    if ($Remediate -eq $true){$ComponentText = "DCU Apps - Remediation"}
    else {$ComponentText = "DCU Apps - Detection"}


    if (!(Test-Path -Path $LogFilePath)){New-Item -Path $LogFilePath -ItemType Directory -Force | Out-Null}                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    Function Get-InstalledApplication {
      [CmdletBinding()]
      Param(
        [Parameter(
          Position=0,
          ValueFromPipeline=$true,
          ValueFromPipelineByPropertyName=$true
        )]
        [String[]]$ComputerName=$ENV:COMPUTERNAME,

        [Parameter(Position=1)]
        [String[]]$Properties,

        [Parameter(Position=2)]
        [String]$IdentifyingNumber,

        [Parameter(Position=3)]
        [String]$Name,

        [Parameter(Position=4)]
        [String]$Publisher
      )
      Begin{
        Function IsCpuX86 ([Microsoft.Win32.RegistryKey]$hklmHive){
          $regPath='SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
          $key=$hklmHive.OpenSubKey($regPath)

          $cpuArch=$key.GetValue('PROCESSOR_ARCHITECTURE')

          if($cpuArch -eq 'x86'){
            return $true
          }else{
            return $false
          }
        }
      }
      Process{
        foreach($computer in $computerName){
          $regPath = @(
            'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
            'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
          )

          Try{
            $hive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey(
              [Microsoft.Win32.RegistryHive]::LocalMachine, 
              $computer
            )
            if(!$hive){
              continue
            }
        
            # if CPU is x86 do not query for Wow6432Node
            if($IsCpuX86){
              $regPath=$regPath[0]
            }

            foreach($path in $regPath){
              $key=$hive.OpenSubKey($path)
              if(!$key){
                continue
              }
              foreach($subKey in $key.GetSubKeyNames()){
                $subKeyObj=$null
                if($PSBoundParameters.ContainsKey('IdentifyingNumber')){
                  if($subKey -ne $IdentifyingNumber -and 
                    $subkey.TrimStart('{').TrimEnd('}') -ne $IdentifyingNumber){
                    continue
                  }
                }
                $subKeyObj=$key.OpenSubKey($subKey)
                if(!$subKeyObj){
                  continue
                }
                $outHash=New-Object -TypeName Collections.Hashtable
                $appName=[String]::Empty
                $appName=($subKeyObj.GetValue('DisplayName'))
                if($PSBoundParameters.ContainsKey('Name')){
                  if($appName -notlike $name){
                    continue
                  }
                }
                if($appName){
                  if($PSBoundParameters.ContainsKey('Properties')){
                    if($Properties -eq '*'){
                      foreach($keyName in ($hive.OpenSubKey("$path\$subKey")).GetValueNames()){
                        Try{
                          $value=$subKeyObj.GetValue($keyName)
                          if($value){
                            $outHash.$keyName=$value
                          }
                        }Catch{
                          Write-Warning "Subkey: [$subkey]: $($_.Exception.Message)"
                          continue
                        }
                      }
                    }else{
                      foreach ($prop in $Properties){
                        $outHash.$prop=($hive.OpenSubKey("$path\$subKey")).GetValue($prop)
                      }
                    }
                  }
                  $outHash.Name=$appName
                  $outHash.IdentifyingNumber=$subKey
                  $outHash.Publisher=$subKeyObj.GetValue('Publisher')
                  if($PSBoundParameters.ContainsKey('Publisher')){
                    if($outHash.Publisher -notlike $Publisher){
                      continue
                    }
                  }
                  $outHash.ComputerName=$computer
                  $outHash.Version=$subKeyObj.GetValue('DisplayVersion')
                  $outHash.Path=$subKeyObj.ToString()
                  New-Object -TypeName PSObject -Property $outHash
                }
              }
            }
          }Catch{
            Write-Error $_
          }
        }
      }
      End{}
    }
    function CMTraceLog {
        [CmdletBinding()]
        Param (
	        [Parameter(Mandatory=$false)]
	        $Message,
 
	        [Parameter(Mandatory=$false)]
	        $ErrorMessage,
 
	        [Parameter(Mandatory=$false)]
	        $Component = $ComponentText,
 
	        [Parameter(Mandatory=$false)]
	        [int]$Type,
		
	        [Parameter(Mandatory=$true)]
	        $LogFile = "$env:ProgramData\Intune\Logs\IForgotToNameTheLogVar.log"
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
	    $LogMessage | Out-File -Append -Encoding UTF8 -FilePath $LogFile
    }

    CMTraceLog -Message  "---------------------------------" -Type 1 -LogFile $LogFile
    CMTraceLog -Message  "Starting $ScriptName, $ScriptVersion | Remediation Mode $Remediate" -Type 1 -LogFile $LogFile
    CMTraceLog -Message  "Running as $whoami" -Type 1 -LogFile $LogFile

    if ($Manufacturer -match "Dell"){

        $InstallApps = Get-InstalledApplication
        $InstalledDCM = $InstallApps | Where-Object {$_.Name -eq 'Dell Command | Monitor'}
        $InstalledDCU = $InstallApps | Where-Object {$_.Name -match 'Dell Command' -and $_.Name -match 'Update'}

        If ($InstalledDCM){[Version]$DCM_InstalledVersion = $InstalledDCM.Version}
        If ($InstalledDCU){[Version]$DCU_InstalledVersion = $InstalledDCU.Version}


        # Pull down Dell XML CAB used in Dell Command Update ,extract and Load
        if (!(Test-Path $DellCabExtractPath)){$newfolder = New-Item -Path $DellCabExtractPath -ItemType Directory -Force}
        Write-Host "Downloading Dell Cab" -ForegroundColor Yellow
        Invoke-WebRequest -Uri "https://downloads.dell.com/catalog/CatalogIndexPC.cab" -OutFile $CabPathIndex -UseBasicParsing -Verbose
        [int32]$n=1
        While(!(Test-Path $CabPathIndex) -and $n -lt '3'){
            Invoke-WebRequest -Uri "https://downloads.dell.com/catalog/CatalogIndexPC.cab" -OutFile $CabPathIndex -UseBasicParsing -Verbose
            $n++
        }
        If(Test-Path "$DellCabExtractPath\DellSDPCatalogPC.xml"){Remove-Item -Path "$DellCabExtractPath\DellSDPCatalogPC.xml" -Force}
        Start-Sleep -Seconds 1
        if (test-path $DellCabExtractPath){Remove-Item -Path $DellCabExtractPath -Force -Recurse}
        New-Item -Path $DellCabExtractPath -ItemType Directory | Out-Null
        Write-Host "Expanding the Cab File..." -ForegroundColor Yellow
        $Expand = expand $CabPathIndex $DellCabExtractPath\CatalogIndexPC.xml

        write-host "Loading Dell Catalog XML.." -ForegroundColor Yellow
        [xml]$XMLIndex = Get-Content "$DellCabExtractPath\CatalogIndexPC.xml" -Verbose


        #Dig Through Dell XML to find Model of THIS Computer (Based on System SKU)
        $XMLModel = $XMLIndex.ManifestIndex.GroupManifest | Where-Object {$_.SupportedSystems.Brand.Model.systemID -match $SystemSKUNumber}
        if ($XMLModel){
            CMTraceLog -Message  "Found Match for SKU: $SystemSKUNumber" -Type 1 -LogFile $LogFile
            CMTraceLog -Message  "Downloaded Dell DCU XML, now looking for Model Updates" -Type 1 -LogFile $LogFile
            Invoke-WebRequest -Uri "http://downloads.dell.com/$($XMLModel.ManifestInformation.path)" -OutFile $CabPathIndexModel -UseBasicParsing -Verbose
            if (Test-Path $CabPathIndexModel){
                $Expand = expand $CabPathIndexModel $DellCabExtractPath\CatalogIndexPCModel.xml
                [xml]$XMLIndexCAB = Get-Content "$DellCabExtractPath\CatalogIndexPCModel.xml" -Verbose
                $DCUAvailable = $XMLIndexCAB.Manifest.SoftwareComponent | Where-Object {$_.ComponentType.value -eq ""}
                $DCUAppsAvailable = $XMLIndexCAB.Manifest.SoftwareComponent | Where-Object {$_.ComponentType.value -eq "APAC"}
                $AppNames = $DCUAppsAvailable.name.display.'#cdata-section' | Select-Object -Unique
                #If you already have the Universal Version Installed:
                if ($InstalledDCU -match "Universal"){
                    $AppDCUVersion = ([Version[]]$Version = ($DCUAppsAvailable | Where-Object {$_.path -match 'command-update' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64" -and $_.path -match 'universal'}).vendorVersion) | Sort-Object | Select-Object -Last 1
                    $AppDCU = $DCUAppsAvailable | Where-Object {$_.path -match 'command-update' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64" -and $_.path -match 'universal' -and $_.vendorVersion -eq $AppDCUVersion}
                    if ($AppDCU.Count -gt 1){
                        $AppDCU = $AppDCU | Select-Object -First 1
                    }
                }
                #This is using the x86 Windows version, not the UWP app
                else {
                    $AppDCUVersion = ([Version[]]$Version = ($DCUAppsAvailable | Where-Object {$_.path -match 'command-update' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64" -and $_.Description.Display.'#cdata-section' -notmatch "UWP" -and $_.path -notmatch 'universal'}).vendorVersion) | Sort-Object | Select-Object -Last 1
                    $AppDCU = $DCUAppsAvailable | Where-Object {$_.path -match 'command-update' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64" -and $_.Description.Display.'#cdata-section' -notmatch "UWP" -and $_.path -notmatch 'universal' -and $_.vendorVersion -eq $AppDCUVersion}
                    if ($AppDCU.Count -gt 1){
                        $AppDCU = $AppDCU | Select-Object -First 1
                    }
                }
                $AppDCMVersion = ([Version[]]$Version = ($DCUAppsAvailable | Where-Object {$_.path -match 'Command-Monitor' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64"} | Select-Object -Property vendorVersion).vendorVersion) | Sort-Object | Select-Object -last 1
                $AppDCM = $DCUAppsAvailable | Where-Object {$_.path -match 'Command-Monitor' -and $_.SupportedOperatingSystems.OperatingSystem.osArch -match "x64" -and $_.vendorVersion -eq $AppDCMVersion }
            
                #$DCUDRIVERSAvailable = $XMLIndexCAB.Manifest.SoftwareComponent | Where-Object {$_.ComponentType.value -eq "DRVR"}
                #$DCUFIRMWAREAvailable = $XMLIndexCAB.Manifest.SoftwareComponent | Where-Object {$_.ComponentType.value -eq "FRMW"}

                #Lets CHeck DCU First
                $DellItem = $AppDCU
                If ($InstalledDCU){[Version]$CurrentVersion = $InstalledDCU.Version}
                Else {[Version]$CurrentVersion = 0.0.0.0}
                [Version]$DCUVersion = $DellItem.vendorVersion
                #$DCUReleaseDate = $(Get-Date $DellItem.releaseDate -Format 'yyyy-MM-dd')
                $DCUReleaseDate = $($DellItem.releaseDate)              
                $TargetLink = "http://downloads.dell.com/$($DellItem.path)"
                $TargetFileName = ($DellItem.path).Split("/") | Select-Object -Last 1
                if ($DCUVersion -gt $CurrentVersion){
                    if ($CurrentVersion -eq 0.0.0.0){[String]$CurrentVersion = "Not Installed"}
                    if ($Remediate -eq $true){
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
                        CMTraceLog -Message  "   Running Command: Invoke-WebRequest -Uri $TargetLink -OutFile $TargetFilePathName -UseBasicParsing -Verbose" -Type 1 -LogFile $LogFile
                        Invoke-WebRequest -Uri $TargetLink -OutFile $TargetFilePathName -UseBasicParsing -Verbose

                        #Confirm Download
                        if (Test-Path $TargetFilePathName){
                            CMTraceLog -Message  "   Download Complete " -Type 1 -LogFile $LogFile
                            $LogFileName = $TargetFilePathName.replace(".exe",".log")
                            $Arguments = "/s /l=$LogFileName"
                            Write-Output "Starting Update"
                            write-output "Log file = $LogFileName"
                            CMTraceLog -Message  " Running Command: Start-Process $TargetFilePathName $Arguments -Wait -PassThru " -Type 1 -LogFile $LogFile
                            $Process = Start-Process "$TargetFilePathName" $Arguments -Wait -PassThru
                            CMTraceLog -Message  " Update Complete with Exitcode: $($Process.ExitCode)" -Type 1 -LogFile $LogFile
                            write-output "Update Complete with Exitcode: $($Process.ExitCode)"
                            If($Process -ne $null -and $Process.ExitCode -eq '2'){
                                $RestartComputer = $true
                            }
                        }
                        else{
                            CMTraceLog -Message  " FAILED TO DOWNLOAD Update" -Type 3 -LogFile $LogFile
                            Write-Host " FAILED TO DOWNLOAD Update" -ForegroundColor Red
                            $Compliance = $false
                        }
                    }
                    else{
                        #Needs Remediation
                        CMTraceLog -Message  "New Update available for $($DellItem.Name.Display.'#cdata-section'): Installed = $CurrentVersion | DCU = $DCUVersion | Remediation Required" -Type 1 -LogFile $LogFile
                        $Compliance = $false
                    }
            
                }
                else{
                    #Compliant
                    Write-Host " Update in DCU XML for $($DellItem.Name.Display.'#cdata-section') same as Installed Version: $CurrentVersion" -ForegroundColor Yellow
                    CMTraceLog -Message  " Update in DCU XML for $($DellItem.Name.Display.'#cdata-section') same as Installed Version: $CurrentVersion" -Type 1 -LogFile $LogFile
                }

                #Lets CHeck DCM Now
                $DellItem = $AppDCM
                If ($InstalledDCM){[Version]$CurrentVersion = $InstalledDCM.Version}
                Else {[Version]$CurrentVersion = 0.0.0.0}


                [Version]$DCMVersion = $DellItem.vendorVersion
                #$DCMReleaseDate = $(Get-Date $DellItem.releaseDate -Format 'yyyy-MM-dd')  
                $DCMReleaseDate = $($DellItem.releaseDate)            
                $TargetLink = "http://downloads.dell.com/$($DellItem.path)"
                $TargetFileName = ($DellItem.path).Split("/") | Select-Object -Last 1

                if ($DCMVersion -gt $CurrentVersion){
                    if ($CurrentVersion -eq 0.0.0.0){[String]$CurrentVersion = "Not Installed"}
                    if ($Remediate -eq $true){
                        CMTraceLog -Message  "New Update available: Installed = $CurrentVersion DCM = $DCMVersion" -Type 1 -LogFile $LogFile
                        Write-Host " New  Update available: Installed = $CurrentVersion DCM = $DCMVersion" -ForegroundColor Yellow 
                        CMTraceLog -Message  "  Title: $($DellItem.Name.Display.'#cdata-section')" -Type 1 -LogFile $LogFile
                        Write-Output "  Title: $($DellItem.Name.Display.'#cdata-section')"
                        CMTraceLog -Message  "  ----------------------------" -Type 1 -LogFile $LogFile
                        Write-Host "  ----------------------------" -ForegroundColor Cyan
                        CMTraceLog -Message  "   Severity: $($DellItem.Criticality.Display.'#cdata-section')" -Type 1 -LogFile $LogFile
                        Write-Output "   Severity: $($DellItem.Criticality.Display.'#cdata-section')"
                        CMTraceLog -Message  "   FileName: $TargetFileName" -Type 1 -LogFile $LogFile
                        Write-Output "   FileName: $TargetFileName"
                        CMTraceLog -Message  "    Release Date: $DCMReleaseDate" -Type 1 -LogFile $LogFile
                        Write-Output "    Release Date: $DCMReleaseDate"
                        CMTraceLog -Message  "   KB: $($DellItem.releaseID)" -Type 1 -LogFile $LogFile
                        Write-Output "   KB: $($DellItem.releaseID)"
                        CMTraceLog -Message  "   Link: $TargetLink" -Type 1 -LogFile $LogFile
                        Write-Output "   Link: $TargetLink"
                        CMTraceLog -Message  "   Info: $($DellItem.ImportantInfo.URL)" -Type 1 -LogFile $LogFile
                        Write-Output "   Info: $($DellItem.ImportantInfo.URL)"
                        CMTraceLog -Message  "   Version: $DCUVersion " -Type 1 -LogFile $LogFile
                        Write-Output "    Version: $DCMVersion "

                        #Build Required Info to Download and Update CM Package
                        $TargetFilePathName = "$($DellCabExtractPath)\$($TargetFileName)"
                        CMTraceLog -Message  "   Running Command: Invoke-WebRequest -Uri $TargetLink -OutFile $TargetFilePathName -UseBasicParsing -Verbose " -Type 1 -LogFile $LogFile
                        Invoke-WebRequest -Uri $TargetLink -OutFile $TargetFilePathName -UseBasicParsing -Verbose

                        #Confirm Download
                        if (Test-Path $TargetFilePathName){
                            CMTraceLog -Message  "   Download Complete " -Type 1 -LogFile $LogFile
                                     
                            $LogFileName = $TargetFilePathName.replace(".exe",".log")
                            $Arguments = "/s /l=$LogFileName"
                            Write-Output "Starting Update"
                            write-output "Log file = $LogFileName"
                            CMTraceLog -Message  " Running Command: Start-Process $TargetFilePathName $Arguments -Wait -PassThru " -Type 1 -LogFile $LogFile
                            $Process = Start-Process "$TargetFilePathName" $Arguments -Wait -PassThru
                            CMTraceLog -Message  " Update Complete with Exitcode: $($Process.ExitCode)" -Type 1 -LogFile $LogFile
                            write-output "Update Complete with Exitcode: $($Process.ExitCode)"
                    
                            If($Process -ne $null -and $Process.ExitCode -eq '2'){
                                $RestartComputer = $true
                            }
                        }
                        else{
                            CMTraceLog -Message  " FAILED TO DOWNLOAD Update" -Type 3 -LogFile $LogFile
                            Write-Host " FAILED TO DOWNLOAD Update" -ForegroundColor Red
                            $Compliance = $false
                        }
                    }
                    else{
                        #Needs Remediation
                        #$DellItem.Name.Display.'#cdata-section'
                        CMTraceLog -Message  "New Update available for $($DellItem.Name.Display.'#cdata-section'): Installed = $CurrentVersion | DCU = $DCUVersion | Remediation Required" -Type 1 -LogFile $LogFile
                        $Compliance = $false
                    }
            
                }
                else{
                    #Compliant
                    Write-Host " Update in DCU XML for $($DellItem.Name.Display.'#cdata-section') same as Installed Version: $CurrentVersion" -ForegroundColor Yellow
                    CMTraceLog -Message  " Update in DCU XML for $($DellItem.Name.Display.'#cdata-section') same as Installed Version: $CurrentVersion" -Type 1 -LogFile $LogFile
                }
            }
            else{
                #No Cab with XML was able to download
                Write-Host "No Model Cab Downloaded"
                CMTraceLog -Message  "No Model Cab Downloaded" -Type 2 -LogFile $LogFile
            }
        }
        else{
            #No Match in the DCU XML for this Model (SKUNumber)
            Write-Host "No Match in XML for $SystemSKUNumber"
            CMTraceLog -Message  "No Match in XML for $SystemSKUNumber" -Type 2 -LogFile $LogFile
        }

        if ($Compliance -eq $false){
            CMTraceLog -Message  "Exit Script Non-Compliant" -Type 2 -LogFile $LogFile
            Write-Output "Non-Compliant, Exit 1, to trigger Remediation to Update Software"
            exit 1
        }
        if ($RestartComputer -eq $true) {Write-Host "You should Reboot!!"}
    }
    else{
        CMTraceLog -Message  "This isn't a Dell... exiting... check with admin on why this is running.  Script should only be applied to a dynamic group that contains Dell computers." -Type 2 -LogFile $LogFile
    }
}