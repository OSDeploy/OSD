function Diskpart-Clean {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DiskNumber
    )
    #Virtual Machines have issues using PowerShell for Clear-Disk
    #$OSDDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$true -PassThru -ErrorAction SilentlyContinue | Out-Null
    
    Write-Verbose "DISKPART> select disk $DiskNumber"
    Write-Verbose "DISKPART> clean"
    Write-Verbose "DISKPART> exit"
    
    #Abort if not in WinPE
    if ($env:SystemDrive -ne "X:") {Return}

$null = @"
select disk $DiskNumber
clean
exit 
"@ | diskpart.exe
}