<#
.SYNOPSIS
Test if WIM file exists

.DESCRIPTION
Test if WIM file exists

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Test-OSDCloudFileWim {
    [CmdletBinding()]
    param (
    
        $ImageFileItem
    
    )

    $Name = Split-Path $ImageFileItem -Leaf
    $Path = Split-Path $ImageFileItem


    $Result = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        # Exclude C:\ and X:\ drives
        if ($_.Name -notin @('C', 'X')) {
            $item = Get-Item "$($_.Name):$("\OSDCloud\OS\$($Path)\$($Name)")" -Filter "*.wim,*.esd,*.install.swm" -Force -ErrorAction SilentlyContinue
        
            # If we have found an item, return it
            if ($item) {
                return $item 
            }
        }
    }

    If ($Result){

        Return Get-Item (Join-Path $Result.Directory $Result.Name)

    }
    
}
