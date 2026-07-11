function Set-BootmgrTimeout {
    <#
    .SYNOPSIS
    Sets the Windows Boot Manager timeout value in BCD.

    .DESCRIPTION
    Updates the '{bootmgr}' timeout entry in BCD using bcdedit. This controls
    how many seconds the boot menu waits before selecting the default entry.

    .PARAMETER Timeout
    Timeout value in seconds to set on the Boot Manager entry.

    .EXAMPLE
    Set-BootmgrTimeout -Timeout 10
    Sets the Boot Manager timeout to 10 seconds.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Updated comment-based help
    #>
    
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [Parameter(Position = 0, Mandatory = $True)]
        [uint32]
        $Timeout
    )
    Write-Verbose $MyInvocation.MyCommand

    Block-StandardUser
    $null = bcdedit /set '{bootmgr}' timeout $Timeout
}
