function Step-OSDCloudContentFolders {
    <#
    .SYNOPSIS
    Creates required local content folders used by OSDCloud deployment steps.

    .DESCRIPTION
    Ensures the standard OSDCloud local folder structure exists before later
    workflow steps execute. Missing folders are created and logged; existing
    folders are left unchanged.

    .EXAMPLE
    Step-OSDCloudContentFolders
    Creates any missing required folders such as C:\Drivers and
    C:\OSDCloud\Packages.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Added comment-based help block
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    $ContentFolders = @(
        # 'C:\Drivers'
        # 'C:\OSDCloud\Packages'
        # 'C:\OSDCloud\Scripts'
        'C:\Windows\Panther'
        'C:\Windows\Provisioning\Autopilot'
        'C:\Windows\Setup\Scripts'
    )

    foreach ($Path in $ContentFolders) {
        if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
            $ParamNewItem = @{
                Path = $Path
                ItemType = 'Directory'
                Force = $true
                ErrorAction = 'Stop'
            }
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Creating $Path"
            $null = New-Item @ParamNewItem
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
