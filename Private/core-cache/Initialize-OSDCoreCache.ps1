function Initialize-OSDCoreCache {
    <#
    .SYNOPSIS
        Initializes the in-memory OSDCore cache inventory.

    .DESCRIPTION
        Resets the global OSDCore cache collection and repopulates it from
        local cache content discovered by Get-OSDCoreCacheContent.

        The resulting cache objects are stored in $global:OSDCoreCache for
        subsequent workflow and selection logic.

    .OUTPUTS
        None. This function updates $global:OSDCoreCache.

    .EXAMPLE
        Initialize-OSDCoreCache

        Rebuilds $global:OSDCoreCache using currently discovered local
        OSDCloud cache content.

    .NOTES
        Depends on Get-OSDCoreCacheContent being available in the session.
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [INFO] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    $global:OSDCoreCache = @()
    $global:OSDCoreCache = Get-OSDCoreCacheContent
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [INFO] Ready: OSDCoreCache"
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
