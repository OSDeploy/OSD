function Step-OSDCloudAddWindowsDriverOemWinRE {
    <#
    .SYNOPSIS
    Injects staged drivers into WinRE for OSDCloud.

    .DESCRIPTION
    Runs in WinPE only. Mounts winre.wim, adds drivers from the OSDCloud WinPE
    driver staging folder, dismounts with save, and removes the temporary mount path.

    .EXAMPLE
    Step-OSDCloudAddWindowsDriverOemWinRE
    Mounts WinRE, injects staged drivers, and commits the image.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Added comment-based help and hardened WinRE mount and cleanup logic
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
    $WinrePath = Join-Path -Path $env:windir -ChildPath 'System32\Recovery\winre.wim'
    $WinreMountPath = Join-Path -Path $env:windir -ChildPath 'Temp\mount-winre'

    $MountLogPath = Join-Path -Path $LogPath -ChildPath 'dism-mount-windowsimage-winre.log'
    $AddDriverLogPath = Join-Path -Path $LogPath -ChildPath 'dism-add-windowsdriver-winre.log'
    $DismountLogPath = Join-Path -Path $LogPath -ChildPath 'dism-dismount-windowsimage-winre.log'

    if (-not (Test-Path -Path $DriverPath -PathType Container)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Driver path not found. Skipping: $DriverPath"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
        return
    }

    if (-not (Test-Path -Path $WinrePath -PathType Leaf)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] WinRE image not found. Skipping: $WinrePath"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
        return
    }

    if (-not (Test-Path -Path $LogPath -PathType Container)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
    if (-not (Test-Path -Path $WinreMountPath -PathType Container)) {
        New-Item -ItemType Directory -Path $WinreMountPath -Force | Out-Null
    }

    $IsMounted = $false
    try {
        $Params = @{
            Path      = $WinreMountPath
            ImagePath = $WinrePath
            Index     = 1
            LogPath   = $MountLogPath
            ErrorAction = 'Stop'
        }
        Mount-WindowsImage @Params | Out-Null
        $IsMounted = $true

        Add-WindowsDriver -Path $WinreMountPath -Driver $DriverPath -Recurse -ForceUnsigned -LogPath $AddDriverLogPath -ErrorAction Stop | Out-Null
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] WinRE driver injection completed."
    }
    catch {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] WinRE driver injection failed: $($_.Exception.Message)"
    }
    finally {
        if ($IsMounted) {
            try {
                Dismount-WindowsImage -Path $WinreMountPath -Save -LogPath $DismountLogPath -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Dismount-WindowsImage failed: $($_.Exception.Message)"
            }
        }

        if (Test-Path -Path $WinreMountPath -PathType Container) {
            try {
                Remove-Item -Path $WinreMountPath -Recurse -Force -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to remove mount path: $WinreMountPath"
            }
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
