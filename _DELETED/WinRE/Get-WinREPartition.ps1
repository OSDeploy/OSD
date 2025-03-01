function Get-WinREPartition {
    <#
    .SYNOPSIS
    Returns the Partition containing Windows Recovery Environment WIM

    .DESCRIPTION
    Returns the Partition containing Windows Recovery Environment WIM
    This function must be run in Windows

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Partition')]
    param ()

    $WinrePartitionOffset = (Get-ReAgentXml).WinreLocationOffset

    $Results = Get-Partition | Where-Object {$_.Offset -match $WinrePartitionOffset}
    $Results[0]
}