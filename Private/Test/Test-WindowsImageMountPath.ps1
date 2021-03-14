<#
.SYNOPSIS
Returns True if Path is a Windows Image mount directory

.DESCRIPTION
Returns True if Path is a Windows Image mount directory

.PARAMETER Path
Full Path to a Windows Image mount directory

.LINK
https://osd.osdeploy.com/module/functions/windowsimage

.NOTES
#>
function Test-WindowsImageMountPath {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName
        )]
        [string]$Path
    )

    if (Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $Path}) {
        Return $true
    } else {
        Return $false
    }
}