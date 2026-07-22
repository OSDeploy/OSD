function Get-OSDCoreDriverPackCacheObject {
    <#
    .SYNOPSIS
    Gets the cached driver pack content object for the selected OSDCore driver pack.

    .DESCRIPTION
    Searches OSDCore cache content for the first DriverPacks entry that matches the selected
    driver pack object's FileName. Returns the matching cache content object when found, or
    $null when the driver pack object, cache content, or matching cache item is missing.

    .PARAMETER DriverPackObject
    Driver pack object containing the FileName property to match. Defaults to $global:OSDCoreDriverPackObject.

    .PARAMETER CacheContent
    Cache content inventory to search. Defaults to $global:OSDCoreCacheContent.

    .EXAMPLE
    Get-OSDCoreDriverPackCacheObject
    Returns the cache content object for $global:OSDCoreDriverPackObject when it exists.

    .EXAMPLE
    if (Get-OSDCoreDriverPackCacheObject) { 'Driver pack cache content exists.' }
    Tests whether the selected driver pack exists in the cache inventory.

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
        $DriverPackObject = $global:OSDCoreDriverPackObject,

        [Parameter()]
        [psobject[]]
        $CacheContent = $global:OSDCoreCacheContent
    )

    process {
        if ($null -eq $DriverPackObject) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackObject is not set."
            return $null
        }

        $DriverPackFileName = [string]$DriverPackObject.FileName
        if ([string]::IsNullOrWhiteSpace($DriverPackFileName)) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackObject FileName is not set."
            return $null
        }

        if (-not $CacheContent) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreCacheContent is not set."
            return $null
        }

        $CacheContent | Where-Object { $_.Type -eq 'DriverPacks' -and $_.Name -eq $DriverPackFileName } | Select-Object -First 1
    }
}
