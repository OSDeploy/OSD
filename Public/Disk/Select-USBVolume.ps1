function Select-USBVolume {
    [CmdletBinding()]
    param (
        [int]$MinimumSizeGB = 1,

        [ValidateSet('FAT32','NTFS')]
        [string]$FileSystem
    )
    #======================================================================================================
    #	Get USB Disk
    #======================================================================================================
    $GetUSBVolume = Get-USBVolume | Sort-Object -Property DriveLetter | Where-Object {$_.SizeGB -gt $MinimumSizeGB}
    #======================================================================================================
    #	Get USB Volume
    #======================================================================================================
    if ($PSBoundParameters.ContainsKey('FileSystem')) {
        $GetUSBVolume = $GetUSBVolume | Where-Object {$_.FileSystem -eq $FileSystem}
    }
    #======================================================================================================
    #	If there are none, then $false
    #======================================================================================================
    if (-NOT ($GetUSBVolume)) {Return $false}
    #======================================================================================================
    #	Count = 1
    #   If there is no need to offer a selection, then uncomment
    #======================================================================================================
    #if (($GetUSBVolume | Measure-Object).Count -eq 1) {$USBVolume = $GetUSBVolume; Return $USBVolume}
    #======================================================================================================
    #	Display the selections
    #======================================================================================================
    $GetUSBVolume | Select-Object -Property DriveLetter, FileSystemLabel, SizeGB, SizeRemainingMB, DriveType | Format-Table | Out-Host
    #======================================================================================================
    #	Select the USBVolume
    #======================================================================================================
    do {
        $SelectReadHost = Read-Host -Prompt "Select a USB Volume by DriveLetter, and press Enter"
    }
    until (($SelectReadHost -ge 0) -and ($SelectReadHost -in $GetUSBVolume.DriveLetter))
    #======================================================================================================
    #	Done!
    #======================================================================================================
    $USBVolume = $GetUSBVolume | Where-Object {$_.DriveLetter -eq $SelectReadHost}
    Return $USBVolume
    #======================================================================================================
}