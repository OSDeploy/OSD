function Step-OSDCloudTelemetryPSGallery {
    <#
    .SYNOPSIS
    Ensures the LaunchMethod PowerShell module is available from PSGallery.

    .DESCRIPTION
    Reads the LaunchMethod value from OSDCloud state, validates it, and installs the
    corresponding module from PSGallery only when it is not already available. Any
    installation failure is logged as a warning so deployment can continue.

    .EXAMPLE
    Step-OSDCloudTelemetryPSGallery
    Validates and installs the LaunchMethod module when needed.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial help block created
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    if ($Global:OSDCloud.LaunchMethod) {
        $LaunchMethodModule = [string]$Global:OSDCloud.LaunchMethod
        $LaunchMethodModule = $LaunchMethodModule.Trim()

        if (-not [string]::IsNullOrWhiteSpace($LaunchMethodModule)) {
            if (-not (Get-Module -ListAvailable -Name $LaunchMethodModule)) {
                try {
                    $null = Install-Module -Name $LaunchMethodModule -Force -ErrorAction Stop -WarningAction SilentlyContinue
                }
                catch {
                    Write-Warning "[$(Get-Date -format s)] Unable to install LaunchMethod module '$LaunchMethodModule': $($_.Exception.Message)"
                }
            }
        }
    }
    #=================================================
}
