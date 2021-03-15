function Select-USBVolume {
    [CmdletBinding()]
    param (
        [int]$MinimumSizeGB = 1,

        [ValidateSet('FAT32','NTFS')]
        [string]$FileSystem
    )
    #======================================================================================================
    #	Get USB Volume
    #======================================================================================================
    $GetUSBVolume = Get-USBVolume | Sort-Object -Property DriveLetter | Where-Object {$_.SizeGB -gt $MinimumSizeGB}

    if ($PSBoundParameters.ContainsKey('FileSystem')) {
        $GetUSBVolume = $GetUSBVolume | Where-Object {$_.FileSystem -eq $FileSystem}
    }
    #======================================================================================================
    #	Identify OSDisk
    #======================================================================================================
    if ($GetUSBVolume) {
        $GetUSBVolume | Select-Object -Property DriveLetter, FileSystemLabel, SizeGB, SizeRemainingMB, DriveType | Format-Table | Out-Host

        <# foreach ($Item in $GetUSBVolume) {
            Write-Host "[$($Item.DriveLetter)]" -ForegroundColor Green -BackgroundColor Black -NoNewline
            Write-Host " $($Item.FileSystemLabel) [$($Item.FileSystem) $($Item.DriveType) Total: $($Item.SizeGB) RemainingMB: $($Item.SizeRemainingMB)MB]"
        } #>

        if (($GetUSBVolume | Measure-Object).Count -eq 1) {
            $USBVolume = $GetUSBVolume
        }
        else {
            #Write-Host "[SKIP]" -ForegroundColor Green -BackgroundColor Black  -NoNewline
            #Write-Host " Skip"
    
            do {
                $SelectReadHost = Read-Host -Prompt "Select a USB Volume by Drive Letter"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $GetUSBVolume.DriveLetter))))
            
            if ($SelectReadHost -eq 'S') {
                Continue
            }
            $USBVolume = $GetUSBVolume | Where-Object {$_.DriveLetter -eq $SelectReadHost}
        }
    }
    Return $USBVolume
}