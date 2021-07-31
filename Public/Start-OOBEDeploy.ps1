function Start-OOBEDeploy {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$CustomProfile,
        [switch]$AddNetFX3,
        [switch]$AddRSAT,
        [switch]$Autopilot,
        [string]$ProductKey,
        [string[]]$RemoveAppx,
        [switch]$UpdateDrivers,
        [switch]$UpdateWindows,
        [ValidateSet('Enterprise')]
        [string]$SetEdition
    )
    #=======================================================================
    #	Block
    #=======================================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OOBEDeploy"
    #=======================================================================
    #   Variables
    #=======================================================================
    $JsonPath = "$env:ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json"
    #=======================================================================
    #   Transcript
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-Transcript"
    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OOBEDeploy.log"
    Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
    #=======================================================================
    #   Custom Profile Sample Variables
    #=======================================================================
    if ($CustomProfile -in 'Sample') {
        $AddNetFX3 = $true
        $AddRSAT = $true
        $Autopilot = $true
        $UpdateDrivers = $true
        $UpdateWindows = $true
        $RemoveAppx = @('CommunicationsApps','OfficeHub','People','Skype','Solitaire','Xbox','ZuneMusic','ZuneVideo')
        $SetEdition = 'Enterprise'
    }
    #=======================================================================
    #   Custom Profile
    #=======================================================================
    if ($CustomProfile) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Loading OOBEDeploy Custom Profile $CustomProfile"

        $CustomProfileJson = Get-ChildItem "$($MyInvocation.MyCommand.Module.ModuleBase)\CustomProfile\OOBEDeploy" *.json | Where-Object {$_.BaseName -eq $CustomProfile} | Select-Object -First 1

        if ($CustomProfileJson) {
            Write-Host -ForegroundColor DarkGray "Saving Module CustomProfile to $JsonPath"
            if (!(Test-Path "$env:ProgramData\OSDeploy")) {New-Item "$env:ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null}
            Copy-Item -Path $CustomProfileJson.FullName -Destination $JsonPath -Force -ErrorAction Ignore
        }
    }
    #=======================================================================
    #   Import Json
    #=======================================================================
    if (Test-Path $JsonPath) {
        Write-Host -ForegroundColor DarkGray "Importing Configuration $JsonPath"
        $ImportOOBEDeploy = @()
        $ImportOOBEDeploy = Get-Content -Raw -Path $JsonPath | ConvertFrom-Json
    
        $ImportOOBEDeploy.PSObject.Properties | ForEach-Object {
            if ($_.Value -match 'IsPresent=True') {
                $_.Value = $true
            }
            if ($_.Value -match 'IsPresent=False') {
                $_.Value = $false
            }
            if ($null -eq $_.Value) {
                Continue
            }
            Set-Variable -Name $_.Name -Value $_.Value -Force
        }
    }
    #=======================================================================
    #   PSGallery
    #=======================================================================
    $PSGalleryIP = (Get-PSRepository -Name PSGallery).InstallationPolicy
    if ($PSGalleryIP -eq 'Untrusted') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    #=======================================================================
    #   Initialize Global Variable
    #=======================================================================
    $Global:OOBEDeploy = [ordered]@{
        AddNetFX3 = $AddNetFX3
        AddRSAT = $AddRSAT
        Autopilot = $Autopilot
        CustomProfile = $CustomProfile
        ProductKey = $ProductKey
        RemoveAppx = $RemoveAppx
        SetEdition = $SetEdition
        UpdateDrivers = $UpdateDrivers
        UpdateWindows = $UpdateWindows
    }
    Write-Host -ForegroundColor DarkGray "Exporting Configuration $env:Temp\OSDeploy.OOBEDeploy.json"
    @($Global:OOBEDeploy.Keys) | ForEach-Object { 
        if (-not $Global:OOBEDeploy[$_]) { $Global:OOBEDeploy.Remove($_) } 
    }
    $Global:OOBEDeploy | ConvertTo-Json | Out-File "$env:Temp\OSDeploy.OOBEDeploy.json" -Force
    #=======================================================================
    #	ProductKey
    #=======================================================================
    if ($SetEdition -eq 'Enterprise') {$ProductKey = 'NPPR9-FWDCX-D2C8J-H872K-2YT43'}
    if ($ProductKey) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-WindowsEdition (ChangePK)"
        Invoke-Exe changepk.exe /ProductKey $ProductKey
        Get-WindowsEdition -Online
    }
    #=======================================================================
    #   Autopilot
    #=======================================================================
    if ($Autopilot) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) AutopilotOOBE"
        Write-Host -ForegroundColor DarkCyan "Install-Module AutopilotOOBE -Force"
        Write-Warning "AutopilotOOBE will open in a new PowerShell Window while OOBEDeploy continues in the background"
        Install-Module AutopilotOOBE -Force
        if ($CustomProfile) {
            Start-Process PowerShell.exe -ArgumentList "-Command Start-AutopilotOOBE -CustomProfile $CustomProfile"
        }
        else {
            Start-Process PowerShell.exe -ArgumentList "-Command Start-AutopilotOOBE"
        }
    }
    #=======================================================================
    #	AddRSAT
    #=======================================================================
    if ($AddNetFX3) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add Windows Capability NetFX3"
        $AddWindowsCapability = Get-MyWindowsCapability -Match 'NetFX' -Detail
        foreach ($Item in $AddWindowsCapability) {
            if ($Item.State -eq 'Installed') {
                Write-Host -ForegroundColor DarkGray "$($Item.DisplayName)"
            }
            else {
                Write-Host -ForegroundColor DarkCyan "$($Item.DisplayName)"
                $Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null
            }
        }
    }
    #=======================================================================
    #	AddRSAT
    #=======================================================================
    if ($AddRSAT) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add Windows Capability RSAT"
        $AddWindowsCapability = Get-MyWindowsCapability -Category Rsat -Detail
        foreach ($Item in $AddWindowsCapability) {
            if ($Item.State -eq 'Installed') {
                Write-Host -ForegroundColor DarkGray "$($Item.DisplayName)"
            }
            else {
                Write-Host -ForegroundColor DarkCyan "$($Item.DisplayName)"
                $Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null
            }
        }
    }
    #=======================================================================
    #	Remove-AppxOnline
    #=======================================================================
    if ($RemoveAppx) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Remove-AppxOnline"

        foreach ($Item in $RemoveAppx) {
            Remove-AppxOnline -Name $Item
        }
    }
    #=======================================================================
    #	UpdateDrivers
    #=======================================================================
    if ($UpdateDrivers) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Windows Update Drivers"
        if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
            try {
                Install-Module PSWindowsUpdate -Force
            }
            catch {
                Write-Warning 'Unable to install PSWindowsUpdate PowerShell Module'
                $UpdateDrivers = $false
            }
        }
    }
    if ($UpdateDrivers) {
        Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot
    }
    #=======================================================================
    #	Windows Update Software
    #=======================================================================
    if ($UpdateWindows) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Windows and Microsoft Update Software"
        if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
            try {
                Install-Module PSWindowsUpdate -Force
            }
            catch {
                Write-Warning 'Unable to install PSWindowsUpdate PowerShell Module'
                $UpdateWindows = $false
            }
        }
    }
    if ($UpdateWindows) {
        Write-Host -ForegroundColor DarkCyan 'Add-WUServiceManager -MicrosoftUpdate -Confirm:$false'
        Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
        #Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot'
        #Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
        Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot'
        Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
    }
    #=======================================================================
    #	Stop-Transcript
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Stop-Transcript"
    Write-Warning "It is recommended that you restart your computer using Restart-Computer before completing Windows Setup"
    Stop-Transcript
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=======================================================================
}