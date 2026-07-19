function Step-OSDCloudPreinstallHooks {
    <#
    .SYNOPSIS
    Discovers and processes OSDCloud preinstall scripts and automation artifacts.

    .DESCRIPTION
    Scans removable and non-C file system drives for Config and Automate content used by OSDCloud,
    executes startup scripts, and stages shutdown scripts plus Autopilot and provisioning artifacts.

    .EXAMPLE
    Step-OSDCloudPreinstallHooks
    Discovers preinstall hooks and runs startup scripts before validation and deployment steps.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Extracted preinstall hook discovery and staging from Invoke-RecastOSDCloud
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    # Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    #region ----- ..\OSDCloud\Config\Scripts\Startup\*.ps1
    <#
    These scripts will be in the OSDCloud Workspace in Config\Scripts\Startup
    When Edit-OSDCloudWinPE is executed then these files should be copied to the mounted WinPE
    In WinPE, the scripts will exist in X:\OSDCloud\Config\Scripts\Startup\*
    #>
    # Write-SectionHeader '[i] Config Startup Scripts'
    $Global:OSDCloud.ScriptStartup = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($_.Root)OSDCloud\Config\Scripts\Startup\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\Startup\" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.ScriptStartup) {
        $Global:OSDCloud.ScriptStartup = $Global:OSDCloud.ScriptStartup | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.ScriptStartup) {
            Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] Execute $($Item.FullName)"
            & "$($Item.FullName)"
        }
    }
    #endregion

    #region ----- ..\OSDCloud\Config\Scripts\Shutdown\*.ps1
    # Write-SectionHeader '[i] Config Shutdown Scripts'
    $Global:OSDCloud.ShutdownScript = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne 'C' } | ForEach-Object {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($_.Root)OSDCloud\Config\Scripts\Shutdown\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Config\Scripts\Shutdown\" -Include '*.ps1' -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.ShutdownScript) {
        $Global:OSDCloud.ShutdownScript = $Global:OSDCloud.ShutdownScript | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.ShutdownScript) {
            Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] Staging $($Item.FullName)"
        }
    }
    #endregion

    #region ----- ..\OSDCloud\Automate\AutopilotConfigurationFile.json
    # Write-SectionHeader '[i] Automate AutopilotConfigurationFile.json'
    $Global:OSDCloud.AutomateAutopilot = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($_.Root)OSDCloud\Automate\AutopilotConfigurationFile.json"
        Get-ChildItem "$($_.Root)OSDCloud\Automate" -Include "AutopilotConfigurationFile.json" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateAutopilot) {
        $Global:OSDCloud.AutomateAutopilot = $Global:OSDCloud.AutomateAutopilot | Sort-Object -Property FullName | Select-Object -First 1
        foreach ($Item in $Global:OSDCloud.AutomateAutopilot) {
            Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] Staging $($Item.FullName)"
        }
    }
    #endregion

    #region ----- ..\OSDCloud\Automate\Provisioning\*.ppkg
    # Write-SectionHeader '[i] Automate Provisioning Package'
    $Global:OSDCloud.AutomateProvisioning = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($_.Root)OSDCloud\Automate\Provisioning\*.ppkg"
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Provisioning" -Include "*.ppkg" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateProvisioning) {
        $Global:OSDCloud.AutomateProvisioning = $Global:OSDCloud.AutomateProvisioning | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.AutomateProvisioning) {
            Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] Staging $($Item.FullName)"
        }
    }
    #endregion

    #region ----- ..\OSDCloud\Automate\Startup\*.ps1
    # Write-SectionHeader '[i] Automate Startup Scripts'
    $Global:OSDCloud.AutomateStartupScript = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($_.Root)OSDCloud\Automate\Startup\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Startup" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateStartupScript) {
        $Global:OSDCloud.AutomateStartupScript = $Global:OSDCloud.AutomateStartupScript | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.AutomateStartupScript) {
            Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] Execute $($Item.FullName)"
            & "$($Item.FullName)"
        }
    }
    #endregion

    #region ----- ..\OSDCloud\Automate\Shutdown\*.ps1
    # Write-SectionHeader '[i] Automate Shutdown Scripts'
    $Global:OSDCloud.AutomateShutdownScript = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($_.Root)OSDCloud\Automate\Shutdown\*.ps1"
        Get-ChildItem "$($_.Root)OSDCloud\Automate\Shutdown" -Include "*.ps1" -File -Recurse -Force -ErrorAction Ignore
    }
    if ($Global:OSDCloud.AutomateShutdownScript) {
        $Global:OSDCloud.AutomateShutdownScript = $Global:OSDCloud.AutomateShutdownScript | Sort-Object -Property FullName
        foreach ($Item in $Global:OSDCloud.AutomateShutdownScript) {
            Write-Host -ForegroundColor Gray "[$(Get-Date -format s)] Staging $($Item.FullName)"
        }
    }
    #endregion
    #=================================================
}
