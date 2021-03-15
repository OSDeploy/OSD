<#
.SYNOPSIS
Returns True if ImagePath is Mounted

.DESCRIPTION
Returns True if ImagePath is Mounted

.PARAMETER ImagePath
Specifies the full path to the Windows Image

.PARAMETER Index
Index of the Windows Image

.LINK
https://osd.osdeploy.com/module/functions/windowsimage

.NOTES
#>
function Test-WindowsImageMounted {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName
        )]
        [string]$ImagePath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [UInt32]$Index = 1
    )

    if (Get-WindowsImage -Mounted | Where-Object {($_.ImagePath -eq $ImagePath) -and ($_.ImageIndex -eq $Index)}) {
        Return $true
    } else {
        Return $false
    }
}