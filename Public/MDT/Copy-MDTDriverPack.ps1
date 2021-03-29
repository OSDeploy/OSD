function Copy-MDTDriverPack {
    [CmdletBinding()]
    param (
        [ValidateSet('Dell','HP','Lenovo')]
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )

    try {
        $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    }
    catch {
        $TSEnv = $false
    }

    if ($TSEnv) {
        $DEPLOYROOT = $TSEnv.Value("DEPLOYROOT")
        $DEPLOYDRIVE = $TSEnv.Value("DEPLOYDRIVE") # Z:
        $OSVERSION = $TSEnv.Value("OSVERSION") # WinPE
        $RESOURCEDRIVE = $TSEnv.Value("RESOURCEDRIVE") # Z:
        $OSDISK = $TSEnv.Value("OSDISK") # E:
        $OSDANSWERFILEPATH = $TSEnv.Value("OSDANSWERFILEPATH") # E:\MININT\Unattend.xml
        $TARGETPARTITIONIDENTIFIER = $TSEnv.Value("TARGETPARTITIONIDENTIFIER") # [SELECT * FROM Win32_LogicalDisk WHERE Size = '134343553024' and VolumeName = 'Windows' and VolumeSerialNumber = '90D39B87']

        $DeployRootDriverPacks = Join-Path $DEPLOYROOT 'DriverPacks'
        $OSDiskDrivers = Join-Path $OSDISK 'Drivers'

        if ($Manufacturer -in ('Dell','HP','Lenovo')) {
            $MyDriverPack = Get-MyDriverPack -Manufacturer $Manufacturer -Product $Product
        }
        else {
            $MyDriverPack = Get-MyDriverPack -Product $Product
        }
    
        if ($MyDriverPack) {
            if ($env:SystemDrive -eq 'X:'){
                Copy-PSModuleToFolder -Name OSD -Destination "$OSDISK\Program Files\WindowsPowerShell\Modules"
            }

            if (-NOT (Test-Path -Path $OSDiskDrivers)) {
                New-Item -Path $OSDiskDrivers -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
    
            Write-Verbose -Verbose "FileName: $($MyDriverPack.FileName)"
    
            $DeployRootDriverPack = @()
            $DeployRootDriverPack = Get-ChildItem "$DeployRootDriverPacks\" -Include $MyDriverPack.FileName -File -Recurse -Force -ErrorAction Ignore | Select-Object -First 1
    
            if ($DeployRootDriverPack) {
                Write-Verbose -Verbose "Source: $($DeployRootDriverPack.FullName)"
                Copy-Item -Path $($DeployRootDriverPack.FullName) -Destination $OSDiskDrivers -Force
            }
            else {
                #Ok, its not looking good, so let's try to see if we can get a download
                #First let's make sure we have curl.exe

                if (Test-Path "$env:SystemRoot\System32\curl.exe") {
                    #All good
                }
                elseif (Test-Path "$OSDISK\Windows\System32\curl.exe") {
                    Copy-Item -Path "$OSDISK\Windows\System32\curl.exe" -Destination "$env:SystemRoot\System32\curl.exe"
                }
                else {
                    #No curl.exe
                    Continue
                }

                if (Test-Path "$env:SystemRoot\System32\curl.exe") {
                    Save-WebFile -SourceUrl $MyDriverPack.DriverPackUrl -DestinationDirectory $OSDiskDrivers -DestinationName $MyDriverPack.FileName
                }
            }
        }
    }
    else {
        Write-Warning "This functions requires a running Task Sequence"
        Start-Sleep -Seconds 5
    }
}