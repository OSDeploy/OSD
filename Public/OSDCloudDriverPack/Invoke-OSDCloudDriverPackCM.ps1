function Invoke-OSDCloudDriverPackCM {
    <#
    .SYNOPSIS
    Downloads a matching DriverPack to %OSDisk%\Drivers

    .DESCRIPTION
    Downloads a matching DriverPack to %OSDisk%\Drivers

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Requires CURL - typically I run this command first in a previous step, "iex (irm sandbox.osdcloud.com)", which will setup your WinPE environment with installing curl.
    #>
    [CmdletBinding()]
    param (
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct),
        [System.String]
        [ValidateSet('Windows 11','Windows 10')]
        $DriverOSVersion = 'Windows 11'
    )
    #=================================================
    #	Make sure we are running in a Task Sequence first
    #=================================================
    try {
        $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    }
    catch {
        $TSEnv = $false
    }

    if ($TSEnv -eq $false) {
        Write-Warning "This functions requires a running Task Sequence"
        Start-Sleep -Seconds 5
        Continue
    }
    else {
        function Confirm-TSProgressUISetup(){
        if ($Script:TaskSequenceProgressUi -eq $null){
            try{$Script:TaskSequenceProgressUi = New-Object -ComObject Microsoft.SMS.TSProgressUI}
            catch{throw "Unable to connect to the Task Sequence Progress UI! Please verify you are in a running Task Sequence Environment. Please note: TSProgressUI cannot be loaded during a prestart command.`n`nErrorDetails:`n$_"}
            }
        }
        function Confirm-TSEnvironmentSetup(){
            if ($Script:TaskSequenceEnvironment -eq $null){
                try{$Script:TaskSequenceEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment}
                catch{throw "Unable to connect to the Task Sequence Environment! Please verify you are in a running Task Sequence Environment.`n`nErrorDetails:`n$_"}
                }
            }
        function Show-TSActionProgress(){
            param(
                [Parameter(Mandatory=$true)]
                [string] $Message,
                [Parameter(Mandatory=$true)]
                [long] $Step,
                [Parameter(Mandatory=$true)]
                [long] $MaxStep
            )

            Confirm-TSProgressUISetup
            Confirm-TSEnvironmentSetup
            $Script:TaskSequenceProgressUi.ShowActionProgress(`
                $Script:TaskSequenceEnvironment.Value("_SMSTSOrgName"),`
                $Script:TaskSequenceEnvironment.Value("_SMSTSPackageName"),`
                $Script:TaskSequenceEnvironment.Value("_SMSTSCustomProgressDialogMessage"),`
                $Script:TaskSequenceEnvironment.Value("_SMSTSCurrentActionName"),`
                [Convert]::ToUInt32($Script:TaskSequenceEnvironment.Value("_SMSTSNextInstructionPointer")),`
                [Convert]::ToUInt32($Script:TaskSequenceEnvironment.Value("_SMSTSInstructionTableSize")),`
                $Message,`
                $Step,`
                $MaxStep)
        }
    }

    #=================================================
    #	Get some Task Sequence variables
    #=================================================
    $DEPLOYROOT = $TSEnv.Value("DEPLOYROOT")
    $DEPLOYDRIVE = $TSEnv.Value("DEPLOYDRIVE") # Z:
    $OSVERSION = $TSEnv.Value("OSVERSION") # WinPE
    $RESOURCEDRIVE = $TSEnv.Value("RESOURCEDRIVE") # Z:
    $OSDISK = $TSEnv.Value("OSDISK") # E:
    $OSDANSWERFILEPATH = $TSEnv.Value("OSDANSWERFILEPATH") # E:\MININT\Unattend.xml
    $TARGETPARTITIONIDENTIFIER = $TSEnv.Value("TARGETPARTITIONIDENTIFIER") # [SELECT * FROM Win32_LogicalDisk WHERE Size = '134343553024' and VolumeName = 'Windows' and VolumeSerialNumber = '90D39B87']
    #=================================================
    #   Windows Debug Transcript
    #=================================================
    $OSDiskWindowsDebug = Join-Path $OSDISK 'Windows\Debug'

    if (-NOT (Test-Path -Path $OSDiskWindowsDebug)) {
        New-Item -Path $OSDiskWindowsDebug -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }
    if (-NOT (Test-Path -Path $OSDiskWindowsDebug)) {
        Write-Warning "Could not create $OSDiskWindowsDebug"
        Start-Sleep -Seconds 5
        Continue
    }

    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Invoke-OSDCloudDriverPackCM.log"
    Start-Transcript -Path (Join-Path $OSDiskWindowsDebug $Transcript) -ErrorAction Ignore
    #=================================================
    #	OSDisk Drivers
    #=================================================
    $OSDiskDrivers = Join-Path $OSDISK 'Drivers'
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPacks will be downloaded to $OSDiskDrivers"

    if (-NOT (Test-Path -Path $OSDiskDrivers)) {
        New-Item -Path $OSDiskDrivers -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }
    if (-NOT (Test-Path -Path $OSDiskDrivers)) {
        Write-Warning "Could not create $OSDiskDrivers"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	Get-MyDriverPack
    #=================================================
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Processing function Get-MyDriverPack"
    Write-Host
    if ($Manufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
        $GetMyDriverPack = Get-OSDCloudDriverPack -OSVersion $DriverOSVersion -Product $Product
    }
    else {
        $GetMyDriverPack = Get-MyDriverPack -Product $Product
    }

    if ($GetMyDriverPack) {     
        $GetMyDriverPackBaseName = ($GetMyDriverPack.FileName).Split('.')[0]
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Matching DriverPack identified"
        Write-Host -ForegroundColor DarkGray "-Name $($GetMyDriverPack.Name)"
        Write-Host -ForegroundColor DarkGray "-BaseName $GetMyDriverPackBaseName"
        Write-Host -ForegroundColor DarkGray "-Product $($GetMyDriverPack.Product)"
        Write-Host -ForegroundColor DarkGray "-FileName $($GetMyDriverPack.FileName)"
        Write-Host -ForegroundColor DarkGray "-Url $($GetMyDriverPack.Url)"
        Write-Host
        $OSDiskDriversFile = Join-Path $OSDiskDrivers $GetMyDriverPack.FileName
        Show-TSActionProgress -Message "Found Driver Pack: $($GetMyDriverPack.FileName)" -Step 1 -MaxStep 5 -ErrorAction SilentlyContinue
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There are no DriverPacks for this computer"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	Get the DriverPack
    #=================================================
    if ($GetMyDriverPack) {
        $ReadyDriverPack = Get-ChildItem -Path $OSDiskDrivers -File -Force -ErrorAction Ignore | Where-Object {$_.Name -match $GetMyDriverPackBaseName} | Where-Object {$_.Extension -in ('.cab','.zip','.exe')}

        if (-Not ($ReadyDriverPack)) {
            if ((-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) -and (-NOT (Test-Path "$OSDISK\Windows\System32\curl.exe"))) {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Curl is required for this to function"
                Start-Sleep -Seconds 5
                Continue
            }
            if ((-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) -and (Test-Path "$OSDISK\Windows\System32\curl.exe")) {
                Copy-Item -Path "$OSDISK\Windows\System32\curl.exe" -Destination "$env:SystemRoot\System32\curl.exe" -Force
            }
            if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Curl is required for this to function"
                Start-Sleep -Seconds 5
                Continue
            }
            Show-TSActionProgress -Message "Downloading Driver Pack: $($GetMyDriverPack.Url)" -Step 2 -MaxStep 5 -ErrorAction SilentlyContinue
            Save-WebFile -SourceUrl $GetMyDriverPack.Url -DestinationDirectory $OSDiskDrivers -DestinationName $GetMyDriverPack.FileName
        }

        $ReadyDriverPack = Get-ChildItem -Path $OSDiskDrivers -File -Force -ErrorAction Ignore | Where-Object {$_.Name -match $GetMyDriverPackBaseName} | Where-Object {$_.Extension -in ('.cab','.zip','.exe','.msi')}
        if ($ReadyDriverPack) {
            $PPKGMethod = $true
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPack has been copied to $OSDiskDrivers"
            if ($ReadyDriverPack.Name -like "sp*.exe"){  #Newer HP Softpaqs are native x64 and will allow to be extracted in WinPE
                Write-Host "Found EXE File: $($ReadyDriverPack.FullName)"
                Show-TSActionProgress -Message "Attempting to Extract HP Driver Pack: $($ReadyDriverPack.FullName)" -Step 3 -MaxStep 5 -ErrorAction SilentlyContinue
                try {Start-Process -FilePath $ReadyDriverPack.FullName -ArgumentList "/s /f $OSDiskDrivers\$GetMyDriverPackBaseName" -Wait}
                catch {Write-Output "Failed to Extract"}
                if (Test-Path "$OSDiskDrivers\$GetMyDriverPackBaseName"){
                    Show-TSActionProgress -Message "Applying HP Driver Pack: $($OSDiskDrivers)\$($GetMyDriverPackBaseName)" -Step 4 -MaxStep 5 -ErrorAction SilentlyContinue
                    Write-Output "Starting DISM /image:C:\ /Add-Driver /driver:$($OSDiskDrivers)\$($GetMyDriverPackBaseName) /recurse"
                    $ArgumentList = "/image:C:\ /Add-Driver /driver:`"$OSDiskDrivers\$GetMyDriverPackBaseName`" /recurse"
                    $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
                    $PPKGMethod = $false
                }
                else {
                    Write-Output "Unable to Extract and Apply Driverpack in WinPE, continue to PPKG method"
                }
            }
            else {
                Write-Output "Did not find EXE file to attempt to extract"
            }

            if ($PPKGMethod -eq $true){
                $OSDCloudDriverPackPPKG = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Provisioning\Invoke-OSDCloudDriverPack.ppkg"
        
                if (Test-Path $OSDCloudDriverPackPPKG) {
                    Show-TSActionProgress -Message "Applying first boot Specialize Provisioning Package" -Step 4 -MaxStep 5 -ErrorAction SilentlyContinue
                    Write-Host
                    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying first boot Specialize Provisioning Package"
                    Write-Host -ForegroundColor DarkGray "dism.exe /Image=$OSDISK\ /Add-ProvisioningPackage /PackagePath:`"$OSDCloudDriverPackPPKG`""
                    $ArgumentList = "/Image=$OSDISK\ /Add-ProvisioningPackage /PackagePath:`"$OSDCloudDriverPackPPKG`""
                    $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
                }
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not download the DriverPack"
        }
        Stop-Transcript
        Start-Sleep -Seconds 5
    }
}
