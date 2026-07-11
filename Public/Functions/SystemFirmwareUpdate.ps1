function Get-SystemFirmwareUpdate {
    <#
    .SYNOPSIS
    Retrieves the latest system firmware update from Microsoft Update Catalog

    .DESCRIPTION
    Searches Microsoft Update Catalog for the latest system firmware update available for the current computer's firmware device. Requires PowerShell 5.1 and MSCatalog module.

    .EXAMPLE
    Get-SystemFirmwareUpdate
    Returns the latest available firmware update

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help
    #>
    [CmdLetBinding()]
    param()
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if ($PSVersionTable.PSVersion.Major -ne 5) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PowerShell 5.1 is required to run this function"
        return
    }
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -SkipPublisherCheck -ErrorAction Ignore
    }
    #=================================================
    #	Make sure the Module was installed
    #=================================================
    if (Get-Module -ListAvailable -Name MSCatalog) {
        if (Test-MicrosoftUpdateCatalog) {
            Try {
                Get-MSCatalogUpdate -Search (Get-SystemFirmwareResource) -SortBy LastUpdated -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1
            }
            Catch {
                #Do nothing
            }
        }
        else {
            Write-Host -ForegroundColor DarkGray "Get-SystemFirmwareUpdate: Could not reach https://www.catalog.update.microsoft.com/"
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "Get-SystemFirmwareUpdate: Could not install required PowerShell Module MSCatalog"
    }
    #=================================================
}
