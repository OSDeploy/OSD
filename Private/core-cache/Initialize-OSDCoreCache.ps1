function Initialize-OSDCoreCache {
    <#
    .SYNOPSIS
        Initializes the in-memory OSDCore cache inventory.

    .DESCRIPTION
        Resets the global OSDCore cache content collection and repopulates it from
        local cache content discovered by Get-OSDCoreCacheContent.

        The resulting cache objects are stored in $global:OSDCoreCacheContent for
        subsequent workflow and selection logic.

    .OUTPUTS
        None. This function updates $global:OSDCoreCacheContent.

    .EXAMPLE
        Initialize-OSDCoreCache

        Rebuilds $global:OSDCoreCacheContent using currently discovered local
        OSDCloud cache content.

    .LINK
        https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
        Author: David Segura - Recast Software
        2026-09-30 - Added standard comment-based help metadata
        Depends on Get-OSDCoreCacheContent being available in the session.
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [INFO] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    $global:OSDCoreCacheContent = @()
    $global:OSDCoreCacheContent = Get-OSDCoreCacheContent
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [INFO] Ready: OSDCoreCacheContent"
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
