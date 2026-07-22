function Step-OSDCloudConfirmDriverPackXXXXX {
    <#
    .SYNOPSIS
    Confirms the selected driver pack source is reachable from its online URI.

    .DESCRIPTION
    Validates driver pack selection inputs and URL availability, then performs a lightweight HEAD
    request to test source reachability. If the online source responds successfully, the function
    marks online driver pack confirmation as successful in deployment state.

    .PARAMETER DriverPackName
    Name of the selected driver pack. Values such as None and Microsoft Update Catalog bypass
    online driver pack validation.

    .PARAMETER DriverPackObject
    Driver pack metadata object containing the online URI to validate.

    .EXAMPLE
    Step-OSDCloudConfirmDriverPackXXXXX
    Uses the global driver pack object to verify that the selected online package source is
    reachable.

    .EXAMPLE
    Step-OSDCloudConfirmDriverPackXXXXX -DriverPackName $global:OSDCoreDriverPackObject.Name -DriverPackObject $global:OSDCoreDriverPackObject
    Verifies online source availability for a provided driver pack selection.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-17 - Added comment-based help block
    #>
    [CmdletBinding()]
    param (
        [System.String]
        $DriverPackName = $global:OSDCoreDriverPackObject.Name,

        $DriverPackObject = $global:OSDCoreDriverPackObject
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Confirm DriverPackObject Online:"
    #=================================================
    # Is there a DriverPack Object?
    if (-not ($DriverPackObject)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPackObject is not set. OK."
        return
    }
    #=================================================
    # Is DriverPackName set to None?
    if ($DriverPackName -eq 'None') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPackName is set to None. OK."
        return
    }
    #=================================================
    # Is DriverPackName set to Microsoft Update Catalog?
    if ($DriverPackName -eq 'Microsoft Update Catalog') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPackName is set to Microsoft Update Catalog. OK."
        return
    }
    #=================================================
    # Is there a URL?
    if (-not $($DriverPackObject.Url)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPackObject does not have a Url to validate. OK."
        $global:OSDCoreDriverPackObject = $null
        return
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($DriverPackObject.Url)"
    #=================================================
    # Is the Url reachable?
    # Use a HEAD request as a lightweight reachability/content check.
    try {
        $WebRequest = Invoke-WebRequest -Uri $DriverPackObject.Url -UseBasicParsing -Method Head -ErrorAction Stop
        if ($WebRequest.StatusCode -in 200, 206) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPackObject URI is reachable (HEAD $($WebRequest.StatusCode)). OK."
            $global:RecastOSDCloud.DriverPackObjectUrlTest = $true
        }
    }
    catch {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPackObject URI is not reachable. OK."
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
