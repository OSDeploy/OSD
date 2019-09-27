function Invoke-OSDPSHook {
    [CmdletBinding()]
    Param (
        [string]$FileName = 'OSDPSHook.ps1',
        [string]$Parent = 'OSD'
    )
    
    #======================================================================================
    Write-Verbose "Find <Drive>\$Parent\$FileName"
    #======================================================================================
    $SearchDrives = Get-PSDrive -PSProvider 'FileSystem'
    foreach ($SearchDrive in $SearchDrives) {
        if (Test-Path "$($SearchDrive.Root)$Parent\$FileName") {

            $Global:OSDPSHookParent = "$($SearchDrive.Root)$Parent"
            $Global:OSDPSHook = "$($SearchDrive.Root)$Parent\$FileName"

            #======================================================================================
            Write-Verbose "Call OSDPSHook at $Global:OSDPSHook"
            #======================================================================================
            & "$Global:OSDPSHook"
        }
    }
}