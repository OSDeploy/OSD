<#
.SYNOPSIS
    Initializes the OSDCloud startnet environment.

.DESCRIPTION
    This function initializes the OSDCloud startnet environment by performing the following tasks:
    - Creates a log path if it does not already exist.
    - Copies OSDCloud config startup scripts to the mounted WinPE.
    - Initializes a splash screen if a SPLASH.JSON file is found in OSDCloud\Config.
    - Initializes hardware devices.
    - Initializes wireless network (optional).
    - Initializes network connections.
    - Updates PowerShell modules.

.PARAMETER WirelessConnect
    Specifies whether to connect to a wireless network. If this switch is specified, the function will attempt to connect to a wireless network using the Start-WinREWiFi function.

.EXAMPLE
    Initialize-OSDCloudStartnet -WirelessConnect
    Initializes the OSDCloud startnet environment and attempts to connect to a wireless network.
#>
function Initialize-OSDCloudStartnet {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        $WirelessConnect
    )
    # Make sure we are in WinPE
    if ($env:SystemDrive -eq 'X:') {
        $StartTime = Get-Date

        $LogsPath = "$env:SystemDrive\OSDCloud\Logs"
        if (-NOT (Test-Path -Path $LogsPath)) {
            New-Item -Path $LogsPath -ItemType Directory -Force | Out-Null
        }

        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Win32_BIOS"
        $Win32BIOS = Get-CimInstance -ClassName Win32_BIOS | Select-Object -Property *
        $Win32BIOS | Out-File $LogsPath\Win32_BIOS.txt -Width 4096 -Force
        Write-Host -ForegroundColor Cyan '  Name:' $Win32BIOS.Name
        Write-Host -ForegroundColor Cyan '  ReleaseDate:' $Win32BIOS.ReleaseDate
        Write-Host -ForegroundColor Cyan '  SerialNumber:' $Win32BIOS.SerialNumber

        $Win32BaseBoard = Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property *
        $Win32BaseBoard | Out-File $LogsPath\Win32_BaseBoard.txt -Width 4096 -Force
        if ($Win32BaseBoard.Product) {
            $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
            Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Win32_BaseBoard"
            Write-Host -ForegroundColor Cyan '  Product:' $Win32BaseBoard.Product
        }

        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Win32_ComputerSystem"
        $Win32ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property *
        $Win32ComputerSystem | Out-File $LogsPath\Win32_ComputerSystem.txt -Width 4096 -Force
        Write-Host -ForegroundColor Cyan '  Name:' $Win32ComputerSystem.Name
        Write-Host -ForegroundColor Cyan '  Manufacturer:' $Win32ComputerSystem.Manufacturer
        Write-Host -ForegroundColor Cyan '  Model:' $Win32ComputerSystem.Model
        Write-Host -ForegroundColor Cyan '  SystemFamily:' $Win32ComputerSystem.SystemFamily
        Write-Host -ForegroundColor Cyan '  NumberOfLogicalProcessors:' $Win32ComputerSystem.NumberOfLogicalProcessors
        if (($Win32ComputerSystem.SystemSKUNumber) -and ($Win32ComputerSystem.SystemSKUNumber -ne 'None')) {
            Write-Host -ForegroundColor Cyan '  SystemSKUNumber:' $Win32ComputerSystem.SystemSKUNumber
        }
        $TotalMemory = $([math]::Round($Win32ComputerSystem.TotalPhysicalMemory / 1024 / 1024 / 1024))
        Write-Host -ForegroundColor Cyan '  TotalPhysicalMemory:' $TotalMemory 'GB'
        if ($TotalMemory -lt 6) {
            Write-Host -ForegroundColor Red "OSDCloud WinPE requires at least 6GB of memory to function without issues"
        }

        Get-ScreenPNG -Directory $LogsPath | Out-Null

        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Win32_OperatingSystem"
        $Win32OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property *
        $Win32OperatingSystem | Out-File $LogsPath\Win32_OperatingSystem.txt -Width 4096 -Force
        Write-Host -ForegroundColor Cyan '  BuildNumber:' $Win32OperatingSystem.BuildNumber
        Write-Host -ForegroundColor Cyan '  OSArchitecture:' $Win32OperatingSystem.OSArchitecture
        Write-Host -ForegroundColor Cyan '  Version:' $Win32OperatingSystem.Version

        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Win32_Processor"
        $Win32Processor = Get-CimInstance -ClassName Win32_Processor | Select-Object -Property *
        $Win32Processor | Out-File $LogsPath\Win32_Processor.txt -Width 4096 -Force
        foreach ($Item in $Win32Processor) {
            Write-Host -ForegroundColor Cyan "  $($Item.Name)"
        }
        
        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Win32_DiskDrive"
        $Win32DiskDrive = Get-CimInstance -ClassName Win32_DiskDrive | Select-Object -Property *
        $Win32DiskDrive | Out-File $LogsPath\Win32_DiskDrive.txt -Width 4096 -Force
        foreach ($Item in $Win32DiskDrive) {
            Write-Host -ForegroundColor Cyan "  $($Item.DeviceID) $($Item.Model)"
        }

        $Win32NetworkAdapter = Get-CimInstance -ClassName Win32_NetworkAdapter | Select-Object -Property *
        $Win32NetworkAdapter | Out-File $LogsPath\Win32_NetworkAdapter.txt -Width 4096 -Force
        $Win32NetworkAdapterGuid = $Win32NetworkAdapter | Where-Object {$null -ne $_.GUID}
        if ($Win32NetworkAdapterGuid) {
            $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
            Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Win32_NetworkAdapter"
            foreach ($Item in $Win32NetworkAdapterGuid) {
                Write-Host -ForegroundColor Cyan "  $($Item.MACAddress) $($Item.Name)"
            }
        }

        Get-ScreenPNG -Directory $LogsPath | Out-Null

        $Win32PnPEntity = Get-CimInstance -ClassName Win32_PnPEntity | Select-Object -Property * | Where-Object {$_.Status -eq 'Error'}
        $Win32PnPEntity | Out-File $LogsPath\Win32_PnPEntity.txt -Width 4096 -Force
        $Win32PnPEntityName = $Win32PnPEntity | Where-Object {$null -ne $_.Name} | Sort-Object HardwareID -Unique | Sort-Object Name
        $Win32PnPEntityName | Out-File $LogsPath\Win32_PnPEntityErrors.txt -Width 4096 -Force
        if ($Win32PnPEntityName) {
            $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
            Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Win32_PnPEntity device errors are logged in $LogsPath\Win32_PnPEntityErrors.txt"
            foreach ($Item in $Win32PnPEntityName) {
                #Write-Host -ForegroundColor DarkCyan "  $($Item.Name): $($Item.HardwareID[0])"
            }
            #Get-ScreenPNG -Directory $LogsPath | Out-Null
        }

        # This delay is to let PNP devices initialize
        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Initialize Hardware Devices"
        Start-Sleep -Seconds 10

        <#
        OSDCloud Config Startup Scripts
        These scripts will be in the OSDCloud Workspace in Config\Scripts\StartNet
        When Edit-OSDCloudWinPE is executed then these files should be copied to the mounted WinPE
        In WinPE, the scripts will exist in X:\OSDCloud\Config\Scripts\*
        #>
        $Global:ScriptStartNet = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
            Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\StartNet\" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
        }
        if ($Global:ScriptStartNet) {
            $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
            Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Initialize Startnet Scripts"
            $Global:ScriptStartNet = $Global:ScriptStartNet | Sort-Object -Property FullName
            foreach ($Item in $Global:ScriptStartNet) {
                Write-Host -ForegroundColor DarkGray "$($Item.FullName)"
                & "$($Item.FullName)"
            }
        }

        # Initialize Splash Screen  
        # Looks for SPLASH.JSON files in OSDCloud\Config, if found, it will run a splash screen.
        $Global:SplashScreen = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
            Get-ChildItem "$($_.Root)OSDCloud\Config\" -Include "SPLASH.JSON" -File -Recurse -Force -ErrorAction Ignore
        }

        if ($Global:SplashScreen) {
            $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
            Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Initialize Splash Screen"
            $Global:SplashScreen = $Global:SplashScreen | Sort-Object -Property FullName
            foreach ($Item in $Global:SplashScreen) {
                Write-Host -ForegroundColor DarkGray "Found: $($Item.FullName)"
            }
            if ($Global:SplashScreen.count -gt 1) {
                $SplashJson = $Global:SplashScreen | Select-Object -Last 1
                Write-Host -ForegroundColor DarkGray "Using $($SplashJson.FullName)"
            }
            if (Test-Path -Path "C:\OSDCloud\Logs") {
                Remove-Item -Path "C:\OSDCloud\Logs" -Recurse -Force
            }
            Start-Transcript -Path "X:\OSDCloud\Logs\Deploy-OSDCloud.log"
            if (-NOT ($Global:ModuleBase = (Get-Module -Name OSD).ModuleBase)) {
                Import-Module OSD -Force -ErrorAction Ignore -WarningAction Ignore
            }
            if ($Global:ModuleBase = (Get-Module -Name OSD).ModuleBase) {
                # Write-Host -ForegroundColor DarkGray "Starting $Global:ModuleBase\Resources\SplashScreen\Show-Background.ps1"
                & $Global:ModuleBase\Resources\SplashScreen\Show-Background.ps1
            }
        }

        # Initialize Wireless Networking
        if (Test-Path "$env:SystemRoot\System32\dmcmnutils.dll") {
            $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
            Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Initialize Wireless Networking"
            if ($WirelessConnect) {
                Start-Process PowerShell -ArgumentList 'Start-WinREWiFi -WirelessConnect' -Wait
            }
            else {
                Start-Process PowerShell Start-WinREWiFi -Wait
            }
        }

        # Initialize Network Connections
        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Initialize Network Connections"
        Start-Sleep -Seconds 10

        # Check if the OSD Module in the PowerShell Gallery is newer than the installed version
        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Updating OSD PowerShell Module"
        $PSModuleName = 'OSD'
        $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
        $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore -WarningAction Ignore

        # Install the OSD module if it is not installed or if the version is older than the gallery version
        if ($GalleryPSModule) {
            if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
                Write-Host -ForegroundColor DarkGray "$PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Install-Module $PSModuleName -Scope AllUsers -Force -SkipPublisherCheck
                Import-Module $PSModuleName -Force
            }
        }

        # Start backup PowerShell Session (minimized)
        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Host -ForegroundColor DarkGray "$($TimeSpan.ToString("mm':'ss")) Start backup PowerShell Session (minimized)"
        Start-Process PowerShell -WindowStyle Minimized

        Get-ScreenPNG -Directory $LogsPath | Out-Null
        Start-Sleep -Seconds 3

        # Force import the OSD module
        Import-Module OSD -Force -ErrorAction Ignore -WarningAction Ignore

        # Get the OSD version
        $OSDVersion = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
        $TimeSpan = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Host -ForegroundColor Green "$($TimeSpan.ToString("mm':'ss")) OSDCloud $OSDVersion Ready"
    }
}