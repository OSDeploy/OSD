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
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #	Start
    #=================================================
    if ($env:SystemDrive -eq 'X:') {
        #=================================================
        #   WinPE
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Green "Start-OOBEDeploy in WinPE"
        $ProgramDataOSDeploy = 'C:\ProgramData\OSDeploy'
        $JsonPath = "$ProgramDataOSDeploy\OSDeploy.OOBEDeploy.json"
    }
    else {
        #=================================================
        #   WinOS
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Green "Start-OOBEDeploy"
        $ProgramDataOSDeploy = "$env:ProgramData\OSDeploy"
        $JsonPath = "$ProgramDataOSDeploy\OSDeploy.OOBEDeploy.json"
        #=================================================
        #   Transcript
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-Transcript"
        $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OOBEDeploy.log"
        Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
        #=================================================
        #   Window Title
        #=================================================
        $host.ui.RawUI.WindowTitle = "Running Start-OOBEDeploy $env:SystemRoot\Temp\$Transcript"
    }
    #=================================================
    #   Custom Profile Sample Variables
    #=================================================
    if ($CustomProfile -eq 'Sample') {
        $AddNetFX3 = $true
        $AddRSAT = $true
        $Autopilot = $true
        $UpdateDrivers = $true
        $UpdateWindows = $true
        $RemoveAppx = @('CommunicationsApps','OfficeHub','People','Skype','Solitaire','Xbox','ZuneMusic','ZuneVideo')
        $SetEdition = 'Enterprise'
    }
    #=================================================
    #   Custom Profile
    #=================================================
    if ($CustomProfile) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Loading OOBEDeploy Custom Profile $CustomProfile"

        $CustomProfileJson = Get-ChildItem "$($MyInvocation.MyCommand.Module.ModuleBase)\CustomProfile\OOBEDeploy" *.json | Where-Object {$_.BaseName -eq $CustomProfile} | Select-Object -First 1

        if ($CustomProfileJson) {
            Write-Host -ForegroundColor DarkGray "Saving Module CustomProfile to $JsonPath"
            if (!(Test-Path "$ProgramDataOSDeploy")) {New-Item "$ProgramDataOSDeploy" -ItemType Directory -Force | Out-Null}
            Copy-Item -Path $CustomProfileJson.FullName -Destination $JsonPath -Force -ErrorAction Ignore
        }
    }
    #=================================================
    #   Import Json
    #=================================================
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
    #=================================================
    #   WinOS PSGallery
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        $PSGalleryIP = (Get-PSRepository -Name PSGallery).InstallationPolicy
        if ($PSGalleryIP -eq 'Untrusted') {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
            if ($env:UserName -eq 'defaultuser0') {
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            }
            else {
                Write-Warning 'OOBE defaultuser0 is required to run the following command'
                Write-Host -ForegroundColor Cyan 'Set-PSRepository -Name PSGallery -InstallationPolicy Trusted'
            }
        }
    }
    #=================================================
    #   Initialize Global Variable
    #=================================================
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

    if ($env:SystemDrive -eq 'X:') {
        Write-Host -ForegroundColor DarkGray "Exporting Configuration $ProgramDataOSDeploy\OSDeploy.OOBEDeploy.json"
        @($Global:OOBEDeploy.Keys) | ForEach-Object { 
            if (-not $Global:OOBEDeploy[$_]) { $Global:OOBEDeploy.Remove($_) } 
        }
        $Global:OOBEDeploy | ConvertTo-Json | Out-File "$ProgramDataOSDeploy\OSDeploy.OOBEDeploy.json" -Width 2000 -Force
    }
    else {
        Write-Host -ForegroundColor DarkGray "Exporting Configuration $env:Temp\OSDeploy.OOBEDeploy.json"
        @($Global:OOBEDeploy.Keys) | ForEach-Object { 
            if (-not $Global:OOBEDeploy[$_]) { $Global:OOBEDeploy.Remove($_) } 
        }
        $Global:OOBEDeploy | ConvertTo-Json | Out-File "$env:Temp\OSDeploy.OOBEDeploy.json" -Width 2000 -Force
        #=================================================
        #	ProductKey
        #=================================================
        if ($SetEdition -eq 'Enterprise') {$ProductKey = 'NPPR9-FWDCX-D2C8J-H872K-2YT43'}
        if ($ProductKey) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-WindowsEdition (ChangePK)"
            if ($env:UserName -eq 'defaultuser0') {
                Invoke-Exe changepk.exe /ProductKey $ProductKey
                Get-WindowsEdition -Online
            }
            else {
                Write-Warning 'OOBE defaultuser0 is required to run this group'
                Start-Sleep -Seconds 5
            }
        }
        #=================================================
        #   Autopilot
        #=================================================
        if ($Autopilot) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) AutopilotOOBE"
            Write-Host -ForegroundColor DarkCyan "Install-Module AutopilotOOBE -Force"
            Write-Warning "AutopilotOOBE will open in a new PowerShell Window while OOBEDeploy continues in the background"
            if (($env:UserName -eq 'defaultuser0') -or (!(Get-Module AutopilotOOBE -ListAvailable -ErrorAction Ignore))) {
                Install-Module AutopilotOOBE -Force
            }
            if ($CustomProfile) {
                Start-Process PowerShell.exe -ArgumentList "-Command Start-AutopilotOOBE -CustomProfile $CustomProfile"
            }
            else {
                Start-Process PowerShell.exe -ArgumentList "-Command Start-AutopilotOOBE"
            }
        }
        #=================================================
        #	AddRSAT
        #=================================================
        if ($AddNetFX3) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add Windows Capability NetFX3"
            $AddWindowsCapability = Get-MyWindowsCapability -Match 'NetFX' -Detail

            if ($env:UserName -eq 'defaultuser0') {
                foreach ($Item in $AddWindowsCapability) {
                    Write-Host -ForegroundColor DarkGray "$($Item.DisplayName)"
                    if ($Item.State -notmatch 'Install') {
                        $Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null
                    }
                }
            }
            else {
                Write-Warning 'OOBE defaultuser0 is required to run this group'
                Start-Sleep -Seconds 5
            }
        }
        #=================================================
        #	AddRSAT
        #=================================================
        if ($AddRSAT) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add Windows Capability RSAT"
            $AddWindowsCapability = Get-MyWindowsCapability -Category Rsat -Detail
            
            if ($env:UserName -eq 'defaultuser0') {
                foreach ($Item in $AddWindowsCapability) {
                    if ($Item.State -eq 'Installed') {
                        Write-Host -ForegroundColor DarkGray "$($Item.DisplayName)"
                    }
                    else {
                        Write-Host -ForegroundColor DarkCyan "$($Item.DisplayName)"
                        if ($env:UserName -eq 'defaultuser0') {
                            $Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null
                        }
                        else {
                            Write-Warning 'OOBE defaultuser0 is required to run the following command'
                            Write-Host -ForegroundColor Cyan '$Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null'
                        }
                    }
                }
            }
            else {
                Write-Warning 'OOBE defaultuser0 is required to run this group'
                Start-Sleep -Seconds 5
            }
        }
        #=================================================
        #	Remove-AppxOnline
        #=================================================
        if ($RemoveAppx) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Remove-AppxOnline"
            
            if ($env:UserName -eq 'defaultuser0') {
                foreach ($Item in $RemoveAppx) {
                    if ($env:UserName -eq 'defaultuser0') {
                        Remove-AppxOnline -Name $Item
                    }
                    else {
                        Write-Warning 'OOBE defaultuser0 is required to run the following command'
                        Write-Host -ForegroundColor Cyan "Remove-AppxOnline -Name $Item"
                    }
                }
            }
            else {
                Write-Warning 'OOBE defaultuser0 is required to run this group'
                Start-Sleep -Seconds 5
            }
        }
        #=================================================
        #	UpdateDrivers
        #=================================================
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
            if ($env:UserName -eq 'defaultuser0') {
                Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot
            }
            else {
                Write-Warning 'OOBE defaultuser0 is required to run this group'
                Start-Sleep -Seconds 5
            }
        }
        #=================================================
        #	Windows Update Software
        #=================================================
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
            if ($env:UserName -eq 'defaultuser0') {
                Write-Host -ForegroundColor DarkCyan 'Add-WUServiceManager -MicrosoftUpdate -Confirm:$false'
                Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
                #Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot'
                #Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
                Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot'
                Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
            }
            else {
                Write-Warning 'OOBE defaultuser0 is required to run this group'
                Start-Sleep -Seconds 5
            }
        }
        #=================================================
        #	Restart
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        $host.ui.RawUI.WindowTitle = "Start-OOBEDeploy $env:SystemRoot\Temp\$Transcript"
        Write-Warning "Restart-Computer this device before completing OOBE"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        #=================================================
    }
}