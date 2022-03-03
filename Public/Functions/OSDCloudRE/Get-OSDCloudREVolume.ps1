function Get-OSDCloudREVolume {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE Volume object

    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE Volume object

    .EXAMPLE
    Get-OSDCloudREVolume

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param ()
    Write-Verbose $MyInvocation.MyCommand
    
    Get-Volume | Where-Object {$_.FileSystemLabel -match 'OSDCloudRE'}
}