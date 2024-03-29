function Get-USBPartition {
    [CmdletBinding()]
    param ()

    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDPartition | Where-Object {$_.IsUSB -eq $true})
    #=================================================
}
