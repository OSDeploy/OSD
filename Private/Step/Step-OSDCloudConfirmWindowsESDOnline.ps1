function Step-OSDCloudConfirmWindowsESDOnline {
    <#
    .SYNOPSIS
    Confirms the selected Windows ESD is reachable from its online source URI.

    .DESCRIPTION
    Validates that the selected operating system metadata object is present and contains an online
    source URI, then performs a lightweight ranged web request to verify reachability. When the
    source responds with a valid success status, it marks online ESD confirmation as successful in
    the deployment state.

    .PARAMETER OperatingSystemObject
    Operating system metadata object containing the online source URL for the selected ESD.
    Defaults to the global OSDCore operating system object.

    .PARAMETER DownloadPath
    Reserved path value for the OSDCloud operating system download location.

    .EXAMPLE
    Step-OSDCloudConfirmWindowsESDOnline
    Uses the global operating system object to verify that the online ESD source is reachable.

    .EXAMPLE
    Step-OSDCloudConfirmWindowsESDOnline -OperatingSystemObject $OS -DownloadPath 'D:\OSDCloud\OS'
    Verifies online availability for the provided operating system object source URI.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-17 - Added comment-based help block
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        $OperatingSystemObject = $global:OSDCoreOperatingSystemObject,

        [Parameter()]
        [string]$DownloadPath = 'C:\OSDCloud\OS'
    )
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Confirm WindowsESD Online Availability"
    #=================================================
    # Is there an OperatingSystem Object?
    if (-not ($OperatingSystemObject)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject is not set"
    }
    #=================================================
    # Is there a Url?
    if (-not ($OperatingSystemObject.Url)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject does not have a Url"
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($OperatingSystemObject.Url)"
    #=================================================
    # Is the Url reachable?
    # Use a one-byte ranged GET as a lightweight reachability/content check.
    $OnlineCheckUri = if ($OperatingSystemObject.Url) { $OperatingSystemObject.Url } else { $OperatingSystemObject.FilePath }

    if ($OnlineCheckUri) {
        try {
            $WebRequest = Invoke-WebRequest -Uri $OnlineCheckUri -UseBasicParsing -Method Get -Headers @{ Range = 'bytes=0-0' } -ErrorAction Stop
            if ($WebRequest.StatusCode -in 200, 206) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreOperatingSystemObject URI is reachable (GET $($WebRequest.StatusCode)). OK."
                $global:OSDCloudDeploy.ConfirmWindowsESDOnline = $true
            }
        }
        catch {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreOperatingSystemObject URI is not reachable."
        }
    }
    else {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject URI is not set."
    }
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
