function Select-Disk.fixed {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        [switch]$Skip,
        [switch]$SelectOne
    )
    #=======================================================================
    #	Get-Disk
    #=======================================================================
    if ($Input) {
        $GetDisk = $Input
    } else {
        $GetDisk = Get-Disk.fixed | Sort-Object -Property DiskNumber | `
        Where-Object {($_.Size -gt ($MinimumSizeGB * 1GB)) -and ($_.Size -lt ($MaximumSizeGB * 1GB))}
    }
    #=======================================================================
    #	Let's bounce if there are no results
    #=======================================================================
    if (-NOT ($GetDisk)) {Return $false}
    #=======================================================================
    #	There was only 1 Item, then we will select it automatically
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('SelectOne')) {
        Write-Verbose "Automatically select "
        if (($GetDisk | Measure-Object).Count -eq 1) {
            $SelectedItem = $GetDisk
            Return $SelectedItem
        }
    }
    #=======================================================================
    #	Table of Items
    #=======================================================================
    $GetDisk | Select-Object -Property DiskNumber, BusType,`
    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
    FriendlyName,Model, PartitionStyle,`
    @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
    Format-Table | Out-Host
    #=======================================================================
    #	Select an Item
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('Skip')) {
        do {$Selection = Read-Host -Prompt "Select a Fixed Disk by DiskNumber, or press S to SKIP"}
        until (($Selection -ge 0) -and ($Selection -in $GetDisk.DiskNumber) -or ($Selection -eq 'S'))
        
        if ($Selection -eq 'S') {Return $false}
    }
    else {
        do {$Selection = Read-Host -Prompt "Select a Fixed Disk by DiskNumber"}
        until (($Selection -ge 0) -and ($Selection -in $GetDisk.DiskNumber))
    }
    #=======================================================================
    #	Return Selection
    #=======================================================================
    Return ($GetDisk | Where-Object {$_.DiskNumber -eq $Selection})
    #=======================================================================
}