function Select-Disk.usb {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        
        [Alias('Min','MinGB','MinSize')]
        [int]$MinimumSizeGB = 8,

        [Alias('Max','MaxGB','MaxSize')]
        [int]$MaximumSizeGB = 1800,

        [switch]$Skip,
        [switch]$SelectOne
    )
    #=======================================================================
    #	Get-Disk
    #=======================================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-Disk.usb | Where-Object {($_.Size -gt ($MinimumSizeGB * 1GB)) -and ($_.Size -lt ($MaximumSizeGB * 1GB))}
    }
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
            do {$Selection = Read-Host -Prompt "Select a USB Disk by DiskNumber, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a USB Disk by DiskNumber"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber))
        }
        #=======================================================================
        #	Return Selection
        #=======================================================================
        Return ($Results | Where-Object {$_.DiskNumber -eq $Selection})
        #=======================================================================
    }
}