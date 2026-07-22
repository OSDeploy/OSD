function Step-OSDCloudTelemetryPH {
    <#
    .SYNOPSIS
    Collects deployment telemetry and submits the OSDCloud deploy event.

    .DESCRIPTION
    Gathers device and OS analytics used by OSDCloud telemetry, builds the event payload,
    and sends the osd_deploy event to the telemetry endpoint. Event submission failures are
    handled without stopping deployment.

    .EXAMPLE
    Step-OSDCloudTelemetryPH
    Collects deployment analytics and submits the osd_deploy event.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial help block created
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    # Win32_BIOS
    $classWin32BIOS = Get-CimInstance -ClassName Win32_BIOS | Select-Object -Property *
    #=================================================
    # Win32_ComputerSystem
    $classWin32ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property *
    $ComputerSystemFamily = $classWin32ComputerSystem.SystemFamily | ConvertTo-TrimmedString
    $ComputerSystemSKU = $classWin32ComputerSystem.SystemSKUNumber | ConvertTo-TrimmedString
    #=================================================
    # Win32_ComputerSystemProduct
    $classWin32ComputerSystemProduct = Get-CimInstance -ClassName Win32_ComputerSystemProduct | Select-Object -Property *
    $ComputerSystemProduct = $classWin32ComputerSystemProduct.Version | ConvertTo-TrimmedString
    #=================================================
    # Win32_Keyboard
    try {
        $classWin32Keyboard = Get-CimInstance -ClassName Win32_Keyboard -ErrorAction Stop | Select-Object -Property *
        $classWin32Keyboard | Out-File (Join-Path -Path $LogsPath -ChildPath 'Win32_Keyboard.txt') -Width 4096 -Force
        $KeyboardLayout = [System.String]$classWin32Keyboard.Layout
        $KeyboardName = [System.String]$classWin32Keyboard.Name
    }
    catch {
        $classWin32Keyboard = $null
        $KeyboardLayout = $null
        $KeyboardName = $null
    }
    #=================================================
    # Win32_TimeZone
    $classWin32TimeZone = Get-CimInstance -ClassName Win32_TimeZone | Select-Object -Property *
    #=================================================
    $eventName = 'osd_deploy'
    function Send-RecastOSDCloudEvent {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]$EventName,
            [Parameter(Mandatory)]
            [string]$ApiKey,
            [Parameter(Mandatory)]
            [string]$DistinctId,
            [Parameter()]
            [hashtable]$Properties
        )

        try {
            $payload = [ordered]@{
                api_key    = $ApiKey
                event      = $EventName
                properties = $Properties + @{
                    distinct_id = $DistinctId
                }
                timestamp  = (Get-Date).ToString('o')
            }

            $body = $payload | ConvertTo-Json -Depth 4 -Compress
            Invoke-RestMethod -Method Post `
                -Uri 'https://us.i.posthog.com/capture/' `
                -Body $body `
                -ContentType 'application/json' `
                -TimeoutSec 2 `
                -ErrorAction Stop | Out-Null

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] [OSDCloud] Event sent: $EventName"
        }
        catch {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] [OSDCloud] Failed to send event: $($_.Exception.Message)"
        }
    }
    # UUID
    $deviceUUID = $classWin32ComputerSystemProduct.UUID
    # Convert the UUID to a hash value to protect user privacyand ensure a consistent identifier across events
    $deviceUUIDHash = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($deviceUUID))).Replace("-", "")
    [string]$distinctId = $deviceUUIDHash
    if ([string]::IsNullOrWhiteSpace($distinctId)) {
        $distinctId = [System.Guid]::NewGuid().ToString()
    }

    $computerInfo = Get-ComputerInfo -ErrorAction Ignore
    if ($env:SystemDrive -eq 'X:') {
        $deploymentPhase = 'WinPE'
        $osName = 'Microsoft WindowsPE'
    }
    else {
        $deploymentPhase = 'Windows'
        $osName = [string]$computerInfo.OsName
    }
    $global:OSDCoreEvent = [ordered]@{
        deploymentPhase            = $deploymentPhase
        osdManufacturer            = $global:OSDCoreDevice.OSDManufacturer
        osdModel                   = $global:OSDCoreDevice.OSDModel
        osdProduct                 = $global:OSDCoreDevice.OSDProduct
        deviceManufacturer         = $global:OSDCoreDevice.OSDManufacturer
        deviceModel                = $global:OSDCoreDevice.ComputerModel
        deviceSystemFamily         = $global:OSDCoreDevice.ComputerSystemFamily
        deviceSystemProduct        = $global:OSDCoreDevice.ComputerSystemProduct
        deviceSystemSKU            = $global:OSDCoreDevice.ComputerSystemSKU
        deviceSystemType           = $global:OSDCoreDevice.ComputerSystemType
        biosReleaseDate            = $global:OSDCoreDevice.BiosReleaseDate
        biosSMBIOSBIOSVersion      = $global:OSDCoreDevice.BiosVersion
        keyboardName               = $global:OSDCoreDevice.KeyboardName
        keyboardLayout             = $global:OSDCoreDevice.KeyboardLayout
        winArchitecture            = [string]$env:PROCESSOR_ARCHITECTURE
        winBuildLabEx              = [string]$computerInfo.WindowsBuildLabEx
        winBuildNumber             = [string]$computerInfo.OsBuildNumber
        winCountryCode             = [string]$computerInfo.OsCountryCode
        winEditionId               = [string]$computerInfo.WindowsEditionId
        winInstallationType        = [string]$computerInfo.WindowsInstallationType
        winLanguage                = [string]$computerInfo.OsLanguage
        winName                    = [string]$osName
        winTimeZone                = [string]$computerInfo.TimeZone
        winVersion                 = [string]$computerInfo.OsVersion
        osdcloudModuleVersion      = $($MyInvocation.MyCommand.Module.Version)
        osdcloudWorkflowName       = $OSDCloud.Function
        osdcloudWorkflowTaskName   = $OSDCloud.LaunchMethod
        osdcloudDriverPackName     = $OSDCloud.DriverPackName
        osdcloudOSName             = $OSDCloud.OSName
        osdcloudOSVersion          = $OSDCloud.OSReleaseID
        osdcloudOSActivationStatus = $OSDCloud.OSActivation
        osdcloudOSBuild            = $OSDCloud.OSBuild
        osdcloudOSBuildVersion     = $OSDCloud.OSBuild
        osdcloudOSLanguageCode     = $OSDCloud.OSLanguage
    }
    $postApi = 'phc_2h7nQJCo41Hc5C64B2SkcEBZOvJ6mHr5xAHZyjPl3ZK'
    Send-RecastOSDCloudEvent -EventName $eventName -ApiKey $postApi -DistinctId $distinctId -Properties $global:OSDCoreEvent
    #=================================================
}
