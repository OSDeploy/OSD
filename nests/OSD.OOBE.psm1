if ($env:UserName -eq 'defaultuser0') {
    function Invoke-oobeAddNetFX3 {
        [CmdletBinding()]
        param ()
        #================================================
        #   Initialize
        #================================================
        $Title = 'Invoke-oobeAddNetFX3'
        $host.ui.RawUI.WindowTitle = "Running $Title"
        $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size(2000,2000)
        #================================================
        #   Temp
        #================================================
        if (!(Test-Path "$env:SystemRoot\Temp")) {
            New-Item -Path "$env:SystemRoot\Temp" -ItemType Directory -Force
        }
        #================================================
        #   Transcript
        #================================================
        $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$Title.log"
        Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
        $host.ui.RawUI.WindowTitle = "Running $Title $env:SystemRoot\Temp\$Transcript"
        #================================================
        #   Main
        #================================================
        if ($env:UserName -eq 'defaultuser0') {
            $AddWindowsCapability = Get-MyWindowsCapability -Match 'NetFX' -Detail
            foreach ($Item in $AddWindowsCapability) {
                if ($Item.State -ne 'Install') {
                    Write-Host -ForegroundColor DarkCyan "$($Item.DisplayName)"
                    $Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null
                }
                else {
                    Write-Host -ForegroundColor DarkGray "$($Item.DisplayName)"
                }
            }
        }
        else {
            Write-Warning "OOBE defaultuser0 is required to run $Title"
            Start-Sleep -Seconds 5
        }
        #================================================
        #   Complete
        #================================================
        if ($Global:OOBEDeployWindowTitle) {
            $host.ui.RawUI.WindowTitle = $Global:OOBEDeployWindowTitle
        }
        else {
            $host.ui.RawUI.WindowTitle = "$Title $env:SystemRoot\Temp\$Transcript"
        }
        Stop-Transcript
        #================================================
    }
    function Invoke-oobeAddRSAT {
        [CmdletBinding()]
        param ()
        #================================================
        #   Initialize
        #================================================
        $Title = 'Invoke-oobeAddRSAT'
        $host.ui.RawUI.WindowTitle = "Running $Title"
        $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size(2000,2000)
        #================================================
        #   Temp
        #================================================
        if (!(Test-Path "$env:SystemRoot\Temp")) {
            New-Item -Path "$env:SystemRoot\Temp" -ItemType Directory -Force
        }
        #================================================
        #   Transcript
        #================================================
        $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$Title.log"
        Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
        $host.ui.RawUI.WindowTitle = "Running $Title $env:SystemRoot\Temp\$Transcript"
        #================================================
        #   Main
        #================================================
        if ($env:UserName -eq 'defaultuser0') {
            $AddWindowsCapability = Get-MyWindowsCapability -Category Rsat -Detail
            foreach ($Item in $AddWindowsCapability) {
                if ($Item.State -ne 'Installed') {
                    Write-Host -ForegroundColor DarkCyan "$($Item.DisplayName)"
                    $Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null
                }
                else {
                    Write-Host -ForegroundColor DarkGray "$($Item.DisplayName)"
                }
            }
        }
        else {
            Write-Warning "OOBE defaultuser0 is required to run $Title"
            Start-Sleep -Seconds 5
        }
        #================================================
        #   Complete
        #================================================
        if ($Global:OOBEDeployWindowTitle) {
            $host.ui.RawUI.WindowTitle = $Global:OOBEDeployWindowTitle
        }
        else {
            $host.ui.RawUI.WindowTitle = "$Title $env:SystemRoot\Temp\$Transcript"
        }
        Stop-Transcript
        #================================================
    }
    function Invoke-oobeRemoveAppx {
        [CmdletBinding()]
        param (
            [string[]]$RemoveAppx
        )
        #================================================
        #   Initialize
        #================================================
        $Title = 'Invoke-oobeRemoveAppx'
        $host.ui.RawUI.WindowTitle = "Running $Title"
        $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size(2000,2000)
        #================================================
        #   Temp
        #================================================
        if (!(Test-Path "$env:SystemRoot\Temp")) {
            New-Item -Path "$env:SystemRoot\Temp" -ItemType Directory -Force
        }
        #================================================
        #   Transcript
        #================================================
        $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$Title.log"
        Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
        $host.ui.RawUI.WindowTitle = "Running $Title $env:SystemRoot\Temp\$Transcript"
        #================================================
        #   Main
        #================================================
        if ($env:UserName -eq 'defaultuser0') {
            foreach ($Item in $RemoveAppx) {
                Remove-AppxOnline -Name $Item
            }
        }
        else {
            Write-Warning "OOBE defaultuser0 is required to run $Title"
            Start-Sleep -Seconds 5
        }
    
        #================================================
        #   Complete
        #================================================
        if ($Global:OOBEDeployWindowTitle) {
            $host.ui.RawUI.WindowTitle = $Global:OOBEDeployWindowTitle
        }
        else {
            $host.ui.RawUI.WindowTitle = "$Title $env:SystemRoot\Temp\$Transcript"
        }
        Stop-Transcript
        #================================================
    }
    function Invoke-oobeUpdateDrivers {
        [CmdletBinding()]
        param ()
        #================================================
        #   Initialize
        #================================================
        $Title = 'Invoke-oobeUpdateDrivers'
        $host.ui.RawUI.WindowTitle = "Running $Title"
        $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size(2000,2000)
        #================================================
        #   Temp
        #================================================
        if (!(Test-Path "$env:SystemRoot\Temp")) {
            New-Item -Path "$env:SystemRoot\Temp" -ItemType Directory -Force
        }
        #================================================
        #   Transcript
        #================================================
        $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$Title.log"
        Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
        $host.ui.RawUI.WindowTitle = "Running $Title $env:SystemRoot\Temp\$Transcript"
        #================================================
        #   Main
        #================================================
        if ($env:UserName -eq 'defaultuser0') {
            if (!(Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore)) {
                try {
                    Install-Module PSWindowsUpdate -Force
                    Import-Module PSWindowsUpdate -Force
                }
                catch {
                    Write-Warning 'Unable to install PSWindowsUpdate Driver Updates'
                }
            }
            if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
                Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot
            }
        }
        else {
            Write-Warning "OOBE defaultuser0 is required to run $Title"
            Start-Sleep -Seconds 5
        }
    
        #================================================
        #   Complete
        #================================================
        if ($Global:OOBEDeployWindowTitle) {
            $host.ui.RawUI.WindowTitle = $Global:OOBEDeployWindowTitle
        }
        else {
            $host.ui.RawUI.WindowTitle = "$Title $env:SystemRoot\Temp\$Transcript"
        }
        Stop-Transcript
        #================================================
    }
    function Invoke-oobeUpdateWindows {
        [CmdletBinding()]
        param ()
        #================================================
        #   Initialize
        #================================================
        $Title = 'Invoke-oobeUpdateWindows'
        $host.ui.RawUI.WindowTitle = "Running $Title"
        $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size(2000,2000)
        #================================================
        #   Temp
        #================================================
        if (!(Test-Path "$env:SystemRoot\Temp")) {
            New-Item -Path "$env:SystemRoot\Temp" -ItemType Directory -Force
        }
        #================================================
        #   Transcript
        #================================================
        $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$Title.log"
        Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
        $host.ui.RawUI.WindowTitle = "Running $Title $env:SystemRoot\Temp\$Transcript"
        #================================================
        #   Main
        #================================================
        if ($env:UserName -eq 'defaultuser0') {
            if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
                try {
                    Install-Module PSWindowsUpdate -Force
                    Import-Module PSWindowsUpdate -Force
                }
                catch {
                    Write-Warning 'Unable to install PSWindowsUpdate Windows Updates'
                }
            }
            if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
                Write-Host -ForegroundColor DarkCyan 'Add-WUServiceManager -MicrosoftUpdate -Confirm:$false'
                Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
                #Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot'
                #Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
                Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot'
                Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle 'Preview' -NotKBArticleID 'KB890830','KB5005463','KB4481252'
            }
        }
        else {
            Write-Warning "OOBE defaultuser0 is required to run $Title"
            Start-Sleep -Seconds 5
        }
        #================================================
        #   Complete
        #================================================
        if ($Global:OOBEDeployWindowTitle) {
            $host.ui.RawUI.WindowTitle = $Global:OOBEDeployWindowTitle
        }
        else {
            $host.ui.RawUI.WindowTitle = "$Title $env:SystemRoot\Temp\$Transcript"
        }
        Stop-Transcript
        #================================================
    }    
}