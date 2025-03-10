function Invoke-OSDCloudDriverPackMDT {
    <#
    .SYNOPSIS
    Downloads a matching DriverPack to %OSDisk%\Drivers

    .DESCRIPTION
    Downloads a matching DriverPack to %OSDisk%\Drivers

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
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

    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Invoke-OSDCloudDriverPackMDT.log"
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
        $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Manufacturer -Product $Product
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
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There are no DriverPacks for this computer"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	DeployRoot DriverPacks
    #=================================================
    if ($GetMyDriverPack) {
        $DeployRootDriverPacks = Join-Path $DEPLOYROOT 'DriverPacks'
        
        $DeployRootDriverPack = @()
        $DeployRootDriverPack = Get-ChildItem $DeployRootDriverPacks -File -Recurse -Force -ErrorAction Ignore | Where-Object {$_.Name -match $GetMyDriverPackBaseName} | Where-Object {$_.Extension -in ('.cab','.zip','.exe','.msi')} | Select-Object -First 1
        if ($DeployRootDriverPack) {
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying existing DriverPack from the MDT DeploymentShare"
            Write-Host -ForegroundColor DarkGray "-Source $($DeployRootDriverPack.FullName)"
            Write-Host -ForegroundColor DarkGray "-Destination $OSDiskDriversFile"
            Copy-Item -Path $($DeployRootDriverPack.FullName) -Destination $OSDiskDrivers -Force
            Write-Host
        }
    }
    #=================================================
    #	Get the DriverPack
    #=================================================
    if ($GetMyDriverPack) {
        $ReadyDriverPack = Get-ChildItem -Path $OSDiskDrivers -File -Force -ErrorAction Ignore | Where-Object {$_.Name -match $GetMyDriverPackBaseName} | Where-Object {$_.Extension -in ('.cab','.zip','.exe','.msi')}

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
            Save-WebFile -SourceUrl $GetMyDriverPack.Url -DestinationDirectory $OSDiskDrivers -DestinationName $GetMyDriverPack.FileName
        }

        $ReadyDriverPack = Get-ChildItem -Path $OSDiskDrivers -File -Force -ErrorAction Ignore | Where-Object {$_.Name -match $GetMyDriverPackBaseName} | Where-Object {$_.Extension -in ('.cab','.zip','.exe','.msi')}
        if ($ReadyDriverPack) {
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPack has been copied to $OSDiskDrivers"

            $OSDCloudDriverPackPPKG = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Provisioning\Invoke-OSDCloudDriverPack.ppkg"
        
            if (Test-Path $OSDCloudDriverPackPPKG) {
                Write-Host
                Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying first boot Specialize Provisioning Package"
                Write-Host -ForegroundColor DarkGray "dism.exe /Image=$OSDISK\ /Add-ProvisioningPackage /PackagePath:`"$OSDCloudDriverPackPPKG`""
                $ArgumentList = "/Image=$OSDISK\ /Add-ProvisioningPackage /PackagePath:`"$OSDCloudDriverPackPPKG`""
                $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not download the DriverPack"
        }
        Stop-Transcript
        Start-Sleep -Seconds 5
    }
}