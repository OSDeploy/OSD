function Select-Volume.osd {
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
    if ($Input) {
        $GetDisk = $Input
    } else {
        $GetDisk = Get-Volume.osd | Sort-Object -Property DriveLetter | `
        Where-Object {$_.SizeGB -gt $MinimumSizeGB}
    }
    #=======================================================================
    #	Filter the File System
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('FileSystem')) {
        $GetVolume = $GetVolume | Where-Object {$_.FileSystem -eq $FileSystem}
    }
    #=======================================================================
    #	Let's bounce if there are no results
    #=======================================================================
    if (-NOT ($GetVolume)) {Return $false}
    #=======================================================================
    #	There was only 1 Item, then we will select it automatically
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('SelectOne')) {
        Write-Verbose "Automatically select "
        if (($GetVolume | Measure-Object).Count -eq 1) {
            $SelectedItem = $GetVolume
            Return $SelectedItem
        }
    }
    #=======================================================================
    #	Table of Items
    #=======================================================================
    $GetVolume | Select-Object -Property DriveLetter, FileSystemLabel,`
    SizeGB, SizeRemainingMB, DriveType | `
    Format-Table | Out-Host
    #=======================================================================
    #	Select an Item
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('Skip')) {
        do {$Selection = Read-Host -Prompt "Select a Volume by DriveLetter, or press S to SKIP"}
        until (($Selection -ge 0) -and ($Selection -in $GetVolume.DriveLetter) -or ($Selection -eq 'S'))
        
        if ($Selection -eq 'S') {Return $false}
    }
    else {
        do {$Selection = Read-Host -Prompt "Select a Volume by DriveLetter"}
        until (($Selection -ge 0) -and ($Selection -in $GetVolume.DriveLetter))
    }
    #=======================================================================
    #	Return Selection
    #=======================================================================
    Return ($GetVolume | Where-Object {$_.DriveLetter -eq $Selection})
    #=======================================================================
}