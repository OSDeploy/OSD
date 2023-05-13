function Import-OSDCloudWinPEDriverMDT {
    <#
    .SYNOPSIS
    Imports OSDCloud CloudDrivers into an MDT Deployment Share

    .DESCRIPTION
    Imports OSDCloud CloudDrivers into an MDT Deployment Share

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        #WinPE Driver: Download and install in WinPE drivers from Dell,HP,IntelNet,LenovoDock,Nutanix,Surface,USB,VMware,WiFi
        [ValidateSet('*','Dell','HP','IntelNet','LenovoDock','Surface','Nutanix','USB','VMware','WiFi')]
        [Alias('CloudDriver')]
        [System.String[]]$Driver,

        #WinPE Driver: HardwareID of the Driver to add to WinPE
        [Alias('HardwareID')]
        [System.String[]]$DriverHWID,

        [Alias('Share')]
        [System.String]$ShareName
    )

    try {
        Import-Module "$env:ProgramFiles\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
    }
    catch {
        Write-Error "Microsoft Deployment Toolkit is not installed"
        Break
    }

    if ((Get-MDTPersistentDrive).Length -lt 2){
        $MDTPersistentDrive = (Get-MDTPersistentDrive).Path
    }
    else{
        $MDTPersistentDrive = $ShareName
    }

    if ($MDTPersistentDrive) {
        $MDTPSDrive = New-PSDrive -Name 'OSDCloudMDT' -PSProvider MDTProvider -Root $MDTPersistentDrive -ErrorAction Ignore
    }

    if ($MDTPSDrive) {
        #Get-ItemProperty -Path OSDCloudMDT:
    
        #Set-ItemProperty -Path OSDCloudMDT: -Name SupportX86 -Value 'False'
        Set-ItemProperty -Path OSDCloudMDT: -Name SupportX64 -Value 'True'

        Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.UseBootWim -Value 'True'
        #Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.ScratchSpace -Value '512'
        Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.IncludeNetworkDrivers -Value 'True'
        Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.IncludeMassStorageDrivers -Value 'True'
        Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.IncludeVideoDrivers -Value 'False'
        Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.IncludeSystemDrivers -Value 'True'
        Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.IncludeAllDrivers -Value 'True'

        #Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.GenerateGenericWIM -Value 'False'
        #Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.GenerateGenericISO -Value 'False'

        #Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.GenerateLiteTouchISO -Value 'True'

        #Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.SelectionProfile -Value 'OSDCloud WinPE x64'
        #Set-ItemProperty -Path OSDCloudMDT: -Name Boot.x64.SupportUEFI -Value 'True'
        #=================================================
        #   Create Selection Profile
        #=================================================
        if (! (Test-Path 'OSDCloudMDT:\Selection Profiles\OSDCloud WinPE x64')) {
            New-Item -Path 'OSDCloudMDT:\Selection Profiles' -Enable 'True' -Name 'OSDCloud WinPE x64' -Comments 'OSDCloud WinPE x64' -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\OSDCloud WinPE x64`" ></Include></SelectionProfile>" -ReadOnly 'False' -Verbose
        }
        #=================================================
        #   Create Directory for CloudDrivers
        #=================================================
        if (! (Test-Path 'OSDCloudMDT:\Out-of-Box Drivers\OSDCloud WinPE x64')) {
            New-Item -Path 'OSDCloudMDT:\Out-of-Box Drivers' -Enable 'True' -Name 'OSDCloud WinPE x64' -Comments 'OSDCloud WinPE x64' -ItemType Folder -Verbose
        }
        #=================================================
        #   DriverHWID
        #=================================================
        if ($DriverHWID) {
            foreach ($Item in $DriverHWID) {
                $AddWindowsDriverPath = Join-Path $env:TEMP (Get-Random)
                Save-MsUpCatDriver -HardwareID $Item -DestinationDirectory $AddWindowsDriverPath
            }
            try {
                Import-MDTDriver -Path 'OSDCloudMDT:\Out-of-Box Drivers\OSDCloud WinPE x64' -SourcePath $AddWindowsDriverPath -Verbose
            }
            catch {
                Write-Warning "Unable to find a driver for $Item"
            }
        }
        #=================================================
        #   CloudDriver
        #=================================================
        if ($Driver -contains '*') {
            $Driver = @('Dell','HP','IntelNet','LenovoDock','Nutanix','Surface','USB','VMware','WiFi')
        }
        foreach ($DriverName in $Driver) {
            if (! (Test-Path "OSDCloudMDT:\Out-of-Box Drivers\OSDCloud WinPE x64\$DriverName")) {
                New-Item -Path 'OSDCloudMDT:\Out-of-Box Drivers\OSDCloud WinPE x64' -Enable 'True' -Name $DriverName -Comments '' -ItemType Folder -Verbose
            }
            $WinPECloudDriver = Save-WinPECloudDriver -CloudDriver $DriverName
            Import-MDTDriver -Path "OSDCloudMDT:\Out-of-Box Drivers\OSDCloud WinPE x64\$DriverName" -SourcePath $WinPECloudDriver.FullName -Verbose
        }
        Remove-PSDrive -Name 'OSDCloudMDT' -ErrorAction Ignore
    }
}