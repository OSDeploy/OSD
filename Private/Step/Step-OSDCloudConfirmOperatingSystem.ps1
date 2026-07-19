function Step-OSDCloudConfirmOperatingSystem {
    <#
    .SYNOPSIS
    Verifies that an operating system source is available before deployment continues.

    .DESCRIPTION
    Checks all supported operating system source inputs used by OSDCloud and sets
    $Global:OSDCloud.SectionPassed accordingly. If no source is found, the function
    logs guidance for launch methods and stops execution.

    .EXAMPLE
    Step-OSDCloudConfirmOperatingSystem
    Validates that an operating system source exists in the current OSDCloud context.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial help block created
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    # Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Confirm Operating System Source"
    $Global:OSDCloud.SectionPassed = [bool](
        $global:OSDCoreOperatingSystemObject -or
        $Global:OSDCloud.AzOSDCloudImage -or
        $Global:OSDCloud.ImageFileItem -or
        $Global:OSDCloud.ImageFileDestination -or
        $Global:OSDCloud.ImageFileUrl
    )

    if ($Global:OSDCloud.SectionPassed -eq $true) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OK."
    }
    if ($Global:OSDCloud.SectionPassed -eq $false) {
        Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] OSDCloud Failed"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] An Operating System Source was not specified by any required Variables"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Invoke-OSDCloud should not be run directly unless you know what you are doing"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Try using Start-OSDCloud, Start-OSDCloudGUI, or Start-OSDCloudAzure"
        throw "[$(Get-Date -format s)] OSDCloud Failed: An Operating System Source was not specified by any required Variables"
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
