function Step-OSDCloudVerifyODTFile {
    <#
    .SYNOPSIS
    Verifies and selects the Office Deployment Tool configuration for OSDCloud.

    .DESCRIPTION
    When ODT processing is enabled, discovers available ODT configuration files,
    prompts for selection, and logs whether an Office configuration will be used.

    .EXAMPLE
    Step-OSDCloudVerifyODTFile
    Discovers and selects an Office Deployment Tool configuration for the deployment.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial help block created
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    if ($Global:OSDCloud.SkipODT -ne $true) {
        $Global:OSDCloud.ODTFiles = Find-OSDCloudODTFile

        if ($Global:OSDCloud.ODTFiles) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Select Office Deployment Tool Configuration"
            $Global:OSDCloud.ODTFile = Select-OSDCloudODTFile

            if ($Global:OSDCloud.ODTFile) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Office Config: $($Global:OSDCloud.ODTFile.FullName)"
            }
            else {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCloud Office Config will not be configured for this deployment"
            }
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
