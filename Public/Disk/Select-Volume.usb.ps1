function Select-Volume.usb {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        [int]$MinimumSizeGB = 1,

        [ValidateSet('FAT32','NTFS')]
        [string]$FileSystem,

        [switch]$Skip,
        [switch]$SelectOne
    )
    #=======================================================================
    #	Get-Volume
    #=======================================================================
    $SelectVolume = Get-Volume.usb | Sort-Object -Property DriveLetter | `
    Where-Object {$_.SizeGB -gt $MinimumSizeGB}
    #=======================================================================
    #	Filter the File System
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('FileSystem')) {
        $SelectVolume = $SelectVolume | Where-Object {$_.FileSystem -eq $FileSystem}
    }
    #=======================================================================
    #	Let's bounce if there are no results
    #=======================================================================
    if (-NOT ($SelectVolume)) {Return $false}
    #=======================================================================
    #	There was only 1 Item, then we will select it automatically
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('SelectOne')) {
        Write-Verbose "Automatically select "
        if (($SelectVolume | Measure-Object).Count -eq 1) {
            $SelectedItem = $SelectVolume
            Return $SelectedItem
        }
    }
    #=======================================================================
    #	Table of Items
    #=======================================================================
    $SelectVolume | Select-Object -Property DriveLetter, FileSystemLabel,`
    SizeGB, SizeRemainingMB, DriveType | `
    Format-Table | Out-Host
    #=======================================================================
    #	Select an Item
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('Skip')) {
        do {$Selection = Read-Host -Prompt "Select a USB Volume by DriveLetter, or press S to SKIP"}
        until (($Selection -ge 0) -and ($Selection -in $SelectVolume.DriveLetter) -or ($Selection -eq 'S'))
        
        if ($Selection -eq 'S') {Return $false}
    }
    else {
        do {$Selection = Read-Host -Prompt "Select a USB Volume by DriveLetter"}
        until (($Selection -ge 0) -and ($Selection -in $SelectVolume.DriveLetter))
    }
    #=======================================================================
    #	Return Selection
    #=======================================================================
    Return ($SelectVolume | Where-Object {$_.DriveLetter -eq $Selection})
    #=======================================================================
}