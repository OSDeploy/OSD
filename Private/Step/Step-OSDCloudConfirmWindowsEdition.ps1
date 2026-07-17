function Step-OSDCloudConfirmWindowsEdition {
    <#
    .SYNOPSIS
    Gets and records the applied Windows edition for the deployed OS volume.

    .DESCRIPTION
    Queries the offline Windows image at C:\ by using Get-WindowsEdition,
    writes the detected edition to the console, and stores the value in
    $global:RecastOSDeploy.WindowsEdition for later OSDCloud steps.

    .EXAMPLE
    Step-OSDCloudConfirmWindowsEdition
    Retrieves the Windows edition from C:\ and saves it to the current
    OSDCloud deployment context.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-17 - Added comment-based help block
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    # Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    try {
        $WindowsEdition = (Get-WindowsEdition -Path 'C:\' -ErrorAction Stop | Out-String).Trim()
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $WindowsEdition"
        $global:RecastOSDeploy.WindowsEdition = $WindowsEdition
    }
    catch {
        Write-Warning "[$(Get-Date -format s)] Unable to get Windows Edition. OK."
        Write-Warning "[$(Get-Date -format s)] $_"
    }
    finally {
        $Error.Clear()
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
