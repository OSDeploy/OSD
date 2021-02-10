function Save-BitLockerExternalKey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName)]
        [string]$Path
    )

    if (-NOT (Test-Path $Path)) {
        Write-Warning "Could not find Path at $Path"
        Break
    }

    $Results = Get-BitLockerKeyProtectors | Sort-Object -Property MountPoint | Where-Object {$_.KeyProtectorType -eq 'ExternalKey'}

    foreach ($Item in $Results) {
        manage-bde -protectors -get $Item.MountPoint -Type ExternalKey -SaveExternalKey $Path
    }
}