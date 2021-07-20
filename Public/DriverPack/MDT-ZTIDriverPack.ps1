function Expand-ZTIDriverPack {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Set some Variables
    #=======================================================================
    $OSDiskDrivers = 'C:\Drivers'
    #=======================================================================
    #	Create $OSDiskDrivers
    #=======================================================================
    if (-NOT (Test-Path -Path $OSDiskDrivers)) {
        Write-Warning "Could not find $OSDiskDrivers"
        Start-Sleep -Seconds 5
        Continue
    }
    #=======================================================================
    #	Start-Transcript
    #=======================================================================
    Start-Transcript -OutputDirectory $OSDiskDrivers
    #=======================================================================
    #   Expand
    #=======================================================================
    $DriverPacks = Get-ChildItem -Path $OSDiskDrivers -File

    foreach ($Item in $DriverPacks) {
        $ExpandFile = $Item.FullName
        Write-Verbose -Verbose "DriverPack: $ExpandFile"
        #=======================================================================
        #   Cab
        #=======================================================================
        if ($Item.Extension -eq '.cab') {
            $DestinationPath = Join-Path $Item.Directory $Item.BaseName

            if (-NOT (Test-Path "$DestinationPath")) {
                New-Item $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null

                Write-Verbose -Verbose "Expanding CAB Driver Pack to $DestinationPath"
                Expand -R "$ExpandFile" -F:* "$DestinationPath" | Out-Null

                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                pnpunattend.exe AuditSystem /L
                Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
            }
            Continue
        }
        #=======================================================================
        #   HP
        #=======================================================================
        if ($Item.Extension -eq '.exe') {
            if (($Item.VersionInfo.InternalName -match 'hpsoftpaqwrapper') -or ($Item.VersionInfo.OriginalFilename -match 'hpsoftpaqwrapper.exe') -or ($Item.VersionInfo.FileDescription -like "HP *")) {
                Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                Write-Verbose -Verbose "InternalName: $($Item.VersionInfo.InternalName)"
                Write-Verbose -Verbose "OriginalFilename: $($Item.VersionInfo.OriginalFilename)"
                Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"
                
                $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                if (-NOT (Test-Path "$DestinationPath")) {
                    Write-Verbose -Verbose "Expanding HP Driver Pack to $DestinationPath"
                    Start-Process -FilePath $ExpandFile -ArgumentList "/s /e /f `"$DestinationPath`"" -Wait

                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                    pnpunattend.exe AuditSystem /L
                    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                }
                Continue
            }
        }
        #=======================================================================
        #   Lenovo
        #=======================================================================
        if ($Item.Extension -eq '.exe') {
            if ($Item.VersionInfo.FileDescription -match 'Lenovo') {
                Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"

                $DestinationPath = Join-Path $Item.Directory 'SCCM'

                if (-NOT (Test-Path "$DestinationPath")) {
                    Write-Verbose -Verbose "Expanding Lenovo Driver Pack to $DestinationPath"
                    Start-Process -FilePath $ExpandFile -ArgumentList "/SILENT /SUPPRESSMSGBOXES" -Wait

                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                    pnpunattend.exe AuditSystem /L
                    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                }
                Continue
            }
        }
        #=======================================================================
        #   MSI
        #=======================================================================
        if ($Item.Extension -eq '.msi') {
            $DateStamp = Get-Date -Format yyyyMMddTHHmmss
            $logFile = '{0}-{1}.log' -f $ExpandFile,$DateStamp
            $MSIArguments = @(
                "/i"
                ('"{0}"' -f $ExpandFile)
                "/qb"
                "/norestart"
                "/L*v"
                $logFile
            )
            Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
            Continue
        }
        #=======================================================================
        #   Zip
        #=======================================================================
        if ($Item.Extension -eq '.zip') {
            $DestinationPath = Join-Path $Item.Directory $Item.BaseName

            if (-NOT (Test-Path "$DestinationPath")) {
                Write-Verbose -Verbose "Expanding ZIP Driver Pack to $DestinationPath"
                Expand-Archive -Path $ExpandFile -DestinationPath $DestinationPath -Force
            
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                pnpunattend.exe AuditSystem /L
                Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
            }
            Continue
        }
        #=======================================================================
        #   Everything Else
        #=======================================================================
        Write-Warning "Unable to expand $ExpandFile"
        #=======================================================================
    }
}
function Save-ZTIDriverPack {
    [CmdletBinding()]
    param (
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )
    #=======================================================================
    #	Make sure we are running in a Task Sequence first
    #=======================================================================
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
    #=======================================================================
    #	Get some Task Sequence variables
    #=======================================================================
    $DEPLOYROOT = $TSEnv.Value("DEPLOYROOT")
    $DEPLOYDRIVE = $TSEnv.Value("DEPLOYDRIVE") # Z:
    $OSVERSION = $TSEnv.Value("OSVERSION") # WinPE
    $RESOURCEDRIVE = $TSEnv.Value("RESOURCEDRIVE") # Z:
    $OSDISK = $TSEnv.Value("OSDISK") # E:
    $OSDANSWERFILEPATH = $TSEnv.Value("OSDANSWERFILEPATH") # E:\MININT\Unattend.xml
    $TARGETPARTITIONIDENTIFIER = $TSEnv.Value("TARGETPARTITIONIDENTIFIER") # [SELECT * FROM Win32_LogicalDisk WHERE Size = '134343553024' and VolumeName = 'Windows' and VolumeSerialNumber = '90D39B87']
    #=======================================================================
    #	Set some Variables
    #   DeployRootDriverPacks are where DriverPacks must be staged
    #   This is not working out so great at the moment, so I would suggest
    #   not doing this yet
    #=======================================================================
    $DeployRootDriverPacks = Join-Path $DEPLOYROOT 'DriverPacks'
    $OSDiskDrivers = Join-Path $OSDISK 'Drivers'
    #=======================================================================
    #	Create $OSDiskDrivers
    #=======================================================================
    if (-NOT (Test-Path -Path $OSDiskDrivers)) {
        New-Item -Path $OSDiskDrivers -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }
    if (-NOT (Test-Path -Path $OSDiskDrivers)) {
        Write-Warning "Could not create $OSDiskDrivers"
        Start-Sleep -Seconds 5
        Continue
    }
    #=======================================================================
    #	Start-Transcript
    #=======================================================================
    Start-Transcript -OutputDirectory $OSDiskDrivers
    #=======================================================================
    #	Copy-PSModuleToFolder
    #   The OSD Module needs to be available on the next boot for Specialize
    #   Drivers to work
    #=======================================================================
    if ($env:SystemDrive -eq 'X:'){
        Copy-PSModuleToFolder -Name OSD -Destination "$OSDISK\Program Files\WindowsPowerShell\Modules"
    }
    #=======================================================================
    #	Get-MyDriverPack
    #=======================================================================
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
    #=======================================================================
    #	Get-MyDriverPack
    #=======================================================================
    Write-Verbose -Verbose "Name: $($GetMyDriverPack.Name)"
    Write-Verbose -Verbose "Product: $($GetMyDriverPack.Product)"
    Write-Verbose -Verbose "FileName: $($GetMyDriverPack.FileName)"
    Write-Verbose -Verbose "DriverPackUrl: $($GetMyDriverPack.DriverPackUrl)"
    $OSDiskDriversFile = Join-Path $OSDiskDrivers $GetMyDriverPack.FileName
    #=======================================================================
    #	MDT DeployRoot DriverPacks
    #   See if the DriverPack we need exists in $DeployRootDriverPacks
    #=======================================================================
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
    #=======================================================================
    #	Curl
    #   Make sure Curl is available
    #=======================================================================
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
    #=======================================================================
    #	OSDCloud DriverPacks
    #   Finally, let's download the file and see where this goes
    #=======================================================================
    Save-WebFile -SourceUrl $GetMyDriverPack.DriverPackUrl -DestinationDirectory $OSDiskDrivers -DestinationName $GetMyDriverPack.FileName

    if (Test-Path $OSDiskDriversFile) {
        Write-Verbose -Verbose "DriverPack is in place and ready to go"
        Stop-Transcript
    }
    else {
        Write-Warning "Could not download the DriverPack.  Sorry!"
        Stop-Transcript
    }
    #=======================================================================
}