function Get-USBVolume {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDVolume | Where-Object {$_.IsUSB -eq $true})
    #=================================================
}
