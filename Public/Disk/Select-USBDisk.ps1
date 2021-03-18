function Select-USBDisk {
    [CmdletBinding()]
    param (
        [Alias('Min','MinGB','MinSize')]
        [int]$MinimumSizeGB = 8,

        [Alias('Max','MaxGB','MaxSize')]
        [int]$MaximumSizeGB = 1800,

        [switch]$Skip,
        [switch]$SelectOne
    )
    #Get the USB Disk and add the MinimumSizeGB filter
    $GetUSBDisk = Get-USBDisk | Sort-Object -Property DiskNumber | Where-Object {($_.Size -gt ($MinimumSizeGB * 1GB)) -and ($_.Size -lt ($MaximumSizeGB * 1GB))}

    #Let's bounce if there is nothing to do
    if (-NOT ($GetUSBDisk)) {Return $false}

    #There was only 1 Item, then we will select it automatically
    if ($PSBoundParameters.ContainsKey('SelectOne')) {
        Write-Verbose "Automatically select "
        if (($GetUSBDisk | Measure-Object).Count -eq 1) {
            $USBDisk = $GetUSBDisk
            Return $USBDisk
        }
    }

    #Display the Selection Menu
    $GetUSBDisk | Select-Object -Property DiskNumber, BusType,`
    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
    FriendlyName,Model, PartitionStyle,`
    @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
    Format-Table | Out-Host

    #Allow a Skip option
    if ($PSBoundParameters.ContainsKey('Skip')) {
        do {$Selection = Read-Host -Prompt "Select a USB Disk by DiskNumber, or press S to SKIP"}
        until (($Selection -ge 0) -and ($Selection -in $GetUSBDisk.DiskNumber) -or ($Selection -eq 'S'))
        
        if ($Selection -eq 'S') {Return $false}
    }
    else {
        do {$Selection = Read-Host -Prompt "Select a USB Disk by DiskNumber"}
        until (($Selection -ge 0) -and ($Selection -in $GetUSBDisk.DiskNumber))
    }

    #That's it
    Return $GetUSBDisk | Where-Object {$_.DiskNumber -eq $Selection}
}