
function Select-Disk.osd {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        [switch]$Skip,
        [switch]$SelectOne
    )
    #=================================================
    #	Get-Disk
    #=================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-Disk.fixed
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($GetDisk | Measure-Object).Count -eq 1) {
                $SelectedItem = $GetDisk
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $GetDisk | Select-Object -Property DiskNumber, BusType, MediaType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName,Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Disk by DiskNumber, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $GetDisk.DiskNumber) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Disk by DiskNumber"}
            until (($Selection -ge 0) -and ($Selection -in $GetDisk.DiskNumber))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($GetDisk | Where-Object {$_.DiskNumber -eq $Selection})
        #=================================================
    }
}
function Select-Disk.ffu {
    [CmdletBinding()]
    param (
        [switch]$Skip,
        [switch]$SelectOne
    )
    #=================================================
    #	Get-Disk
    #=================================================
    $Results = Get-Disk.fixed
    #=================================================
    #	Get USB Disk and add the MinimumSizeGB filter
    #=================================================
    $Results = Get-Disk.fixed
    $InUseDrives = $Results | Where-Object {$_.IsBoot -eq $true}
    foreach ($Item in $InUseDrives) {
        Write-Warning "$($Item.FriendlyName) cannot be backed up because it is in use"
    }
    $Results = $Results | Where-Object {$_.IsBoot -eq $false}
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DiskNumber, BusType, MediaType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName,Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Fixed Disk to Backup by DiskNumber, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Fixed Disk to Backup by DiskNumber"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DiskNumber -eq $Selection})
        #=================================================
    }
}
function Select-Disk.fixed {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        [switch]$Skip,
        [switch]$SelectOne
    )
    #=================================================
    #	Get-Disk
    #=================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-Disk.fixed
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DiskNumber, BusType, MediaType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName,Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Fixed Disk by DiskNumber, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Fixed Disk by DiskNumber"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DiskNumber -eq $Selection})
        #=================================================
    }
}
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
    #=================================================
    #	Get-Disk
    #=================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-Disk.usb | Where-Object {($_.Size -gt ($MinimumSizeGB * 1GB)) -and ($_.Size -lt ($MaximumSizeGB * 1GB))}
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DiskNumber, BusType, MediaType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName,Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a USB Disk by DiskNumber, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a USB Disk by DiskNumber"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DiskNumber))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DiskNumber -eq $Selection})
        #=================================================
    }
}
function Select-Disk.storage {
    [CmdletBinding()]
    param (
        [int]$NotDiskNumber,
        [switch]$Skip,
        [switch]$SelectOne
    )
    #=================================================
    #	Get USB Disk and add the MinimumSizeGB filter
    #=================================================
    $Results = Get-Disk.storage | Sort-Object -Property DriveLetter
    #=================================================
    #	Filter NotDiskNumber
    #=================================================
    if ($PSBoundParameters.ContainsKey('NotDiskNumber')) {
        $Results = $Results | Where-Object {$_.DiskNumber -ne $NotDiskNumber}
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DriveLetter, FileSystemLabel,`
        @{Name='FreeGB';Expression={[int]($_.SizeRemaining / 1000000000)}},`
        @{Name='TotalGB';Expression={[int]($_.Size / 1000000000)}},`
        FileSystem, DriveType, DiskNumber | Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a Disk to save the FFU on by DriveLetter, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a Disk to save the FFU on by DriveLetter"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DriveLetter -eq $Selection})
        #=================================================
    }
}