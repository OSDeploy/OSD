function Get-OSDCloudREPSDrive {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE PSDrive object

    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE PSDrive object

    .EXAMPLE
    Get-OSDCloudREPSDrive

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSDriveInfo])]
    param ()
    Write-Verbose $MyInvocation.MyCommand
    
    Get-PSDrive | Where-Object {$_.Description -eq 'OSDCloudRE'}
}