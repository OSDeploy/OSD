function Invoke-OSDCloudDriverPackMDT {
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
    #	Set some Variables
    #   DeployRootDriverPacks are where DriverPacks must be staged
    #   This is not working out so great at the moment, so I would suggest
    #   not doing this yet
    #=================================================
    $DeployRootDriverPacks = Join-Path $DEPLOYROOT 'DriverPacks'
    $OSDiskDrivers = Join-Path $OSDISK 'Drivers'
    #=================================================
    #	Create $OSDiskDrivers
    #=================================================
    if (-NOT (Test-Path -Path $OSDiskDrivers)) {
        New-Item -Path $OSDiskDrivers -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }
    if (-NOT (Test-Path -Path $OSDiskDrivers)) {
        Write-Warning "Could not create $OSDiskDrivers"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	Start-Transcript
    #=================================================
    Start-Transcript -OutputDirectory $OSDiskDrivers
    #=================================================
    #	Get-MyDriverPack
    #=================================================
    Write-Verbose -Verbose "Processing function Get-MyDriverPack"
    if ($Manufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
        $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Manufacturer -Product $Product
    }
    else {
        $GetMyDriverPack = Get-MyDriverPack -Product $Product
    }
    if (-NOT ($GetMyDriverPack)) {
        Write-Warning "There are no DriverPacks for this computer"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	Get-MyDriverPack
    #=================================================
    Write-Verbose -Verbose "Name: $($GetMyDriverPack.Name)"
    Write-Verbose -Verbose "Product: $($GetMyDriverPack.Product)"
    Write-Verbose -Verbose "FileName: $($GetMyDriverPack.FileName)"
    Write-Verbose -Verbose "Url: $($GetMyDriverPack.Url)"
    $OSDiskDriversFile = Join-Path $OSDiskDrivers $GetMyDriverPack.FileName
    #=================================================
    #	MDT DeployRoot DriverPacks
    #   See if the DriverPack we need exists in $DeployRootDriverPacks
    #=================================================
    $DeployRootDriverPack = @()
    $DeployRootDriverPack = Get-ChildItem "$DeployRootDriverPacks\" -Include $GetMyDriverPack.FileName -File -Recurse -Force -ErrorAction Ignore | Select-Object -First 1
    if ($DeployRootDriverPack) {
        Write-Verbose -Verbose "Source: $($DeployRootDriverPack.FullName)"
        Write-Verbose -Verbose "Destination: $OSDiskDriversFile"
        Copy-Item -Path $($DeployRootDriverPack.FullName) -Destination $OSDiskDrivers -Force
    }

    if (Test-Path $OSDiskDriversFile) {
        Write-Verbose -Verbose "DriverPack is in place and ready to go"
        Stop-Transcript
        Continue
    }
    #=================================================
    #	Curl
    #   Make sure Curl is available
    #=================================================
    if ((-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) -and (-NOT (Test-Path "$OSDISK\Windows\System32\curl.exe"))) {
        Write-Warning "Curl is required for this to function"
        Start-Sleep -Seconds 5
        Continue
    }
    if ((-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) -and (Test-Path "$OSDISK\Windows\System32\curl.exe")) {
        Copy-Item -Path "$OSDISK\Windows\System32\curl.exe" -Destination "$env:SystemRoot\System32\curl.exe" -Force
    }

    if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
        Write-Warning "Curl is required for this to function"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	OSDCloud DriverPacks
    #   Finally, let's download the file and see where this goes
    #=================================================
    Save-WebFile -SourceUrl $GetMyDriverPack.Url -DestinationDirectory $OSDiskDrivers -DestinationName $GetMyDriverPack.FileName

    if (Test-Path $OSDiskDriversFile) {
        $OSDCloudDriverPackPPKG = Join-Path (Get-Module OSD).ModuleBase "Provisioning\Invoke-OSDCloudDriverPack.ppkg"
    
        if (Test-Path $OSDCloudDriverPackPPKG) {
            Write-Host -ForegroundColor DarkGray "dism.exe /Image=$OSDISK\ /Add-ProvisioningPackage /PackagePath:`"$OSDCloudDriverPackPPKG`""
            $Dism = "dism.exe"
            $ArgumentList = "/Image=$OSDISK\ /Add-ProvisioningPackage /PackagePath:`"$OSDCloudDriverPackPPKG`""
            $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
        }

        Write-Verbose -Verbose "DriverPack is in place and ready to go"
        Stop-Transcript
    }
    else {
        Write-Warning "Could not download the DriverPack.  Sorry!"
        Stop-Transcript
    }
    Start-Sleep -Seconds 5
    #=================================================
}