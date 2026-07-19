function Get-OSDCoreCacheOperatingSystemObject {
    <#
    .SYNOPSIS
    Gets the cached operating system content object for the selected OSDCore operating system.

    .DESCRIPTION
    Searches OSDCore cache content for the first USB-backed ESD or WIM entry that matches the
    selected operating system object's FileName. Returns the matching cache content object when
    found, or $null when the operating system object, cache content, or matching cache item is missing.

    .PARAMETER OperatingSystemObject
    Operating system object containing the FileName property to match. Defaults to $global:OSDCoreOperatingSystemObject.

    .PARAMETER CacheContent
    Cache content inventory to search. Defaults to $global:OSDCoreCacheContent.

    .EXAMPLE
    Get-OSDCoreCacheOperatingSystemObject
    Returns the USB cache content object for $global:OSDCoreOperatingSystemObject when it exists.

    .EXAMPLE
    if (Get-OSDCoreCacheOperatingSystemObject) { 'Operating system cache content exists.' }
    Tests whether the selected operating system payload exists in the USB cache inventory.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-19 - Initial private helper created
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(ValueFromPipeline)]
        [psobject]
        $OperatingSystemObject = $global:OSDCoreOperatingSystemObject,

        [Parameter()]
        [psobject[]]
        $CacheContent = $global:OSDCoreCacheContent
    )

    process {
        if ($null -eq $OperatingSystemObject) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject is not set."
            return $null
        }

        $OperatingSystemFileName = [string]$OperatingSystemObject.FileName
        if ([string]::IsNullOrWhiteSpace($OperatingSystemFileName)) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject FileName is not set."
            return $null
        }

        if (-not $CacheContent) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreCacheContent is not set."
            return $null
        }

        $CacheContent | Where-Object { $_.Type -in @('ESD', 'WIM') -and $_.Name -eq $OperatingSystemFileName -and $_.USB } | Select-Object -First 1
    }
}
