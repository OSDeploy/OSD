function Select-Disk.ffu {
    [CmdletBinding()]
    param (
        [switch]$Skip,
        [switch]$SelectOne
    )
    #=======================================================================
    #	Get-Disk
    #=======================================================================
    $Results = Get-Disk.fixed
    #=======================================================================
    #	Get USB Disk and add the MinimumSizeGB filter
    #=======================================================================
    $Results = Get-Disk.fixed
    $InUseDrives = $Results | Where-Object {$_.IsBoot -eq $true}
    foreach ($Item in $InUseDrives) {
        Write-Warning "$($Item.FriendlyName) cannot be backed up because it is in use"
    }
    $Results = $Results | Where-Object {$_.IsBoot -eq $false}
    #=======================================================================
    #	Process Results
    #=======================================================================
    if ($Results) {
        #=======================================================================
        #	There was only 1 Item, then we will select it automatically
        #=======================================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=======================================================================
        #	Table of Items
        #=======================================================================
        $Results | Select-Object -Property DiskNumber, BusType, MediaType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName,Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
        #=======================================================================
        #	Select an Item
        #=======================================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Fixed Disk to Backup by DiskNumber, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Fixed Disk to Backup by DiskNumber"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber))
        }
        #=======================================================================
        #	Return Selection
        #=======================================================================
        Return ($Results | Where-Object {$_.DiskNumber -eq $Selection})
        #=======================================================================
    }
}