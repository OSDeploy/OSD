function Step-OSDCloudUpdateSetupDisplayedEula {
    <#
    .SYNOPSIS
    Sets SetupDisplayedEula in the offline SOFTWARE hive.

    .DESCRIPTION
    Loads the local SOFTWARE registry hive into a temporary key, updates the
    SetupDisplayedEula value to 1 under OOBE, and then unloads the hive.

    .EXAMPLE
    Step-OSDCloudUpdateSetupDisplayedEula
    Marks OOBE EULA as displayed by setting SetupDisplayedEula to 1.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Added comment-based help and robust hive load/unload error handling
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] $($MyInvocation.MyCommand.Name) is skipped when not running in WinPE (X:)"
        return
    }
    #=================================================
    #region Main
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Updating the OOBE SetupDisplayedEula value in the registry."

    $SoftwareHivePath = 'C:\Windows\System32\Config\SOFTWARE'
    $TempHive = 'HKLM\TempSOFTWARE'
    $SetupKey = "$TempHive\Microsoft\Windows\CurrentVersion\Setup\OOBE"
    $HiveLoaded = $false

    if (-not (Test-Path -Path $SoftwareHivePath -PathType Leaf)) {
        Write-Warning "[$(Get-Date -format s)] SOFTWARE hive not found: $SoftwareHivePath"
        return
    }

    try {
        $null = reg load $TempHive $SoftwareHivePath
        if ($LASTEXITCODE -ne 0) {
            throw "reg load failed with exit code $LASTEXITCODE"
        }
        $HiveLoaded = $true

        $null = reg add $SetupKey /v SetupDisplayedEula /t REG_DWORD /d 0x00000001 /f
        if ($LASTEXITCODE -ne 0) {
            throw "reg add failed with exit code $LASTEXITCODE"
        }

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] SetupDisplayedEula updated successfully. OK."
    }
    catch {
        Write-Warning "[$(Get-Date -format s)] Failed to update SetupDisplayedEula: $($_.Exception.Message)"
    }
    finally {
        if ($HiveLoaded) {
            $null = reg unload $TempHive
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "[$(Get-Date -format s)] reg unload failed with exit code $LASTEXITCODE"
            }
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
