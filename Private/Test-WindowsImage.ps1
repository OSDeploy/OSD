<#
.SYNOPSIS
Returns True if ImagePath is a Windows Image

.DESCRIPTION
Returns True if ImagePath is a Windows Image

.PARAMETER ImagePath
Specifies the full path to the Windows Image

.PARAMETER Index
Index of the Windows Image

.LINK
https://osd.osdeploy.com/module/functions/windowsimage

.NOTES
#>
function Test-WindowsImage {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName
        )]
        [string]$ImagePath,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [UInt32]$Index = 1
    )

    try {
        Get-WindowsImage -ImagePath $ImagePath -Index $Index | Out-Null
        Return $true
    }
    catch {
        Return $false
    }
    finally {
        $Error.Clear()
    }
}