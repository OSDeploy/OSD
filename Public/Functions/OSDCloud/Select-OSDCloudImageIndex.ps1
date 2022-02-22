function Select-OSDCloudImageIndex {
    [CmdletBinding()]
    param (
        [string]$ImagePath
    )

    $Results = Get-WindowsImage -ImagePath $ImagePath

    if (($Results | Measure-Object).Count -eq 1) {
        $SelectedItem = $GetDisk
        Return $Results.ImageIndex
    }

    if ($Results) {
        $Results | Select-Object -Property ImageIndex, ImageName | Format-Table | Out-Host

        do {
            $SelectReadHost = Read-Host -Prompt "Select an Image to apply by ImageIndex [Number]"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Results.ImageIndex))))
        
        if ($SelectReadHost -eq 'S') {
            Return $false
        }

        $Results = $Results | Where-Object {$_.ImageIndex -eq $SelectReadHost}

        Return $Results.ImageIndex
    }
}