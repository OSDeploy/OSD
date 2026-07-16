function Step-OSDCloudAddWindowsDriverOemWinOS {
    <#
    .SYNOPSIS
    Adds offline Windows drivers from the OSDCloud WinPE staging folder.

    .DESCRIPTION
    Runs in WinPE only. If staged drivers are present, the function injects them
    into C:\ using Add-WindowsDriver and writes DISM logging to the OSDCloud log path.

    .EXAMPLE
    Step-OSDCloudAddWindowsDriverOemWinOS
    Injects staged WinPE drivers into the offline Windows image at C:\.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Added comment-based help and improved logging and error handling
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] This step will only run in WinPE (X:)"
        return
    }
    #=================================================
    $LogPath = Join-Path -Path $env:windir -ChildPath 'Temp\osdcloud-logs'
    $DriverPath = Join-Path -Path $env:windir -ChildPath 'Temp\osdcloud-drivers-winpe'
    $DismLogPath = Join-Path -Path $LogPath -ChildPath 'dism-add-windowsdriver-winpe.log'

    if (-not (Test-Path -Path $DriverPath -PathType Container)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Driver path not found. Skipping: $DriverPath"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
        return
    }

    if (-not (Test-Path -Path $LogPath -PathType Container)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }

    try {
        Add-WindowsDriver -Path 'C:\' -Driver $DriverPath -Recurse -ForceUnsigned -LogPath $DismLogPath -ErrorAction Stop | Out-Null
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Driver injection completed. Log: $DismLogPath"
    }
    catch {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Add-WindowsDriver failed: $($_.Exception.Message)"
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
