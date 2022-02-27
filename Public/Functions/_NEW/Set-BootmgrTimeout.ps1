function Set-BootmgrTimeout {
    <#
    .Synopsis
    BCD: Sets the Bootmgr Timeout in seconds

    .Description
    BCD: Sets the Bootmgr Timeout in seconds

    .Example
    Set-BootmgrTimeout -Timeout 10

    .Link
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        # Timeout value in seconds
        [Parameter(Mandatory)]
        [uint32]
        $Timeout
    )

    Block-StandardUser
    $null = bcdedit /set '{bootmgr}' timeout $Timeout
}