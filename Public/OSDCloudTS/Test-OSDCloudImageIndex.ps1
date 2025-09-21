<#
.SYNOPSIS
Test if Image Index exists

.DESCRIPTION
Test if Image Index exists

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>

function Test-OSDCloudImageIndex {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ImagePath,
    
        [Parameter(Mandatory = $true)]
        [int]$Index
    )

    $Image = Get-WindowsImage -ImagePath $ImagePath -Index $Index -ErrorAction Ignore

    If ($Image){
    
         Return $Image.ImageIndex

    }

}
