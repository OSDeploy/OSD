function Step-OSDCloudWriteGetWindowsEdition {
    <#
    .SYNOPSIS
    Writes offline Windows edition details for the applied image.

    .DESCRIPTION
    In WinPE deployments, runs Get-WindowsEdition against C:\ and writes the
    formatted output to the console for deployment visibility.

    .EXAMPLE
    Step-OSDCloudWriteGetWindowsEdition
    Displays the current offline Windows edition metadata from C:\.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial help block created
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    if ($Global:OSDCloud.IsWinPE -eq $true) {
        Write-SectionHeader 'Get-WindowsEdition'
        $WindowsEdition = (Get-WindowsEdition -Path 'C:\' | Out-String).Trim()
        $WindowsEdition | Write-Host
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
