function Get-LocalDisk {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Get-OSDDisk
    #=================================================
    $GetDisk = Get-OSDDisk -BusTypeNot 'File Backed Virtual',MAX,'Microsoft Reserved',USB,Virtual
    #=================================================
    #	Return
    #=================================================
    Return $GetDisk
    #=================================================
}
