function Step-OSDCloudBcdBoot {
    <#
    .SYNOPSIS
    Configures boot files for the deployed Windows image from WinPE.

    .DESCRIPTION
    Runs bcdboot.exe against C:\Windows during OSDCloud deployment when executed from WinPE (X:).
    The function writes command output to the OSDCloud log folder and throws if bcdboot fails.

    .EXAMPLE
    Step-OSDCloudBcdBoot
    Executes bcdboot for the deployed image and writes output to C:\Windows\Temp\osdcloud-logs\bcdboot.txt.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Improved error handling, logging, and command construction
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
    $LogPath = 'C:\Windows\Temp\osdcloud-logs'
    $null = New-Item -Path $LogPath -ItemType Directory -Force -ErrorAction SilentlyContinue
    $LogFile = Join-Path -Path $LogPath -ChildPath 'bcdboot.txt'
    $BcdBootExe = 'C:\Windows\System32\bcdboot.exe'

    if (-not (Test-Path -Path $BcdBootExe -PathType Leaf)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to locate $BcdBootExe"
    }

    $BcdBootArgs = @('C:\Windows', '/c')
    if ($global:RecastOSDeploy -and $global:RecastOSDeploy.OSBuild -ge 26200) {
        $BcdBootArgs += '/bootex'
    }
    else {
        $BcdBootArgs += '/v'
    }

    $CommandLine = "$BcdBootExe $($BcdBootArgs -join ' ')"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $CommandLine"

    Push-Location -Path 'C:\Windows\System32'
    try {
        $BCDBootOutput = & $BcdBootExe @BcdBootArgs 2>&1
        $BCDBootOutput | Out-File -FilePath $LogFile -Force

        if ($LASTEXITCODE -ne 0) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdboot failed with exit code $LASTEXITCODE. See $LogFile"
        }
    }
    finally {
        Pop-Location
    }
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
