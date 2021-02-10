function Save-BitLockerRecoveryPassword {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName)]
        [string]$Path
    )

    if (-NOT (Test-Path $Path)) {
        Write-Warning "Could not find Path at $Path"
        Break
    }

    $Results = Get-BitLockerKeyProtectors -ShowRecoveryPassword | Sort-Object -Property MountPoint | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'}



    foreach ($Item in $Results) {
        $ComputerName = $Item.ComputerName
        $MountPoint = $Item.MountPoint -replace ":"
        $KeyProtectorId = $Item.KeyProtectorId -replace "{" -replace "}"
        $RecoveryPassword = $item.RecoveryPassword

        $TextContent = @"
BitLocker Drive Encryption recovery key 

To verify that this is the correct recovery key, compare the start of the following identifier with the identifier value displayed on your PC.

Identifier:

	$KeyProtectorId

If the above identifier matches the one displayed by your PC, then use the following key to unlock your drive.

Recovery Key:

	$RecoveryPassword

If the above identifier doesn't match the one displayed by your PC, then this isn't the right key to unlock your drive.
Try another recovery key, or refer to https://go.microsoft.com/fwlink/?LinkID=260589 for additional assistance.
"@

        New-Item -Path "$Path\$ComputerName MountPoint $MountPoint $KeyProtectorId.TXT" -Force
        $TextContent | Set-Content "$Path\$ComputerName MountPoint $MountPoint $KeyProtectorId.TXT" -Force
    }
}