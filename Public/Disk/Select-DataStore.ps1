function Select-DataStore{
    [CmdletBinding()]
    param (
        [int]$NotDiskNumber,
        [switch]$Skip,
        [switch]$SelectOne
    )
    #=======================================================================
    #	Get USB Disk and add the MinimumSizeGB filter
    #=======================================================================
    $AllItems = Get-DataStore | Sort-Object -Property DriveLetter
    #=======================================================================
    #	Filter NotDiskNumber
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('NotDiskNumber')) {
        $AllItems = $AllItems | Where-Object {$_.DiskNumber -ne $NotDiskNumber}
    }
    #=======================================================================
    #	Let's bounce if there are no results
    #=======================================================================
    if (-NOT ($AllItems)) {Return $false}
    #=======================================================================
    #	There was only 1 Item, then we will select it automatically
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('SelectOne')) {
        Write-Verbose "Automatically select "
        if (($AllItems | Measure-Object).Count -eq 1) {
            $SelectedItem = $AllItems
            Return $SelectedItem
        }
    }
    #=======================================================================
    #	Table of Items
    #=======================================================================
    $AllItems | Select-Object -Property DriveLetter, FileSystemLabel,`
    @{Name='FreeGB';Expression={[int]($_.SizeRemaining / 1000000000)}},`
    @{Name='TotalGB';Expression={[int]($_.Size / 1000000000)}},`
    FileSystem, DriveType, DiskNumber | Format-Table | Out-Host
    #=======================================================================
    #	Select an Item
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('Skip')) {
        do {$Selection = Read-Host -Prompt "Select a DataStore by DriveLetter, or press S to SKIP"}
        until (($Selection -ge 0) -and ($Selection -in $AllItems.DriveLetter) -or ($Selection -eq 'S'))
        
        if ($Selection -eq 'S') {Return $false}
    }
    else {
        do {$Selection = Read-Host -Prompt "Select a DataStore by DriveLetter"}
        until (($Selection -ge 0) -and ($Selection -in $AllItems.DriveLetter))
    }
    #=======================================================================
    #	Return Selection
    #=======================================================================
    Return ($AllItems | Where-Object {$_.DriveLetter -eq $Selection})
    #=======================================================================
}