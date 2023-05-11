function Clear-LocalDisk {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,

        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

        [Alias('I')]
        [System.Management.Automation.SwitchParameter]$Initialize,

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('F')]
        [System.Management.Automation.SwitchParameter]$Force,

        [System.Management.Automation.SwitchParameter]$NoResults,

        [Alias('W','Warn','Warning')]
        [System.Management.Automation.SwitchParameter]$ShowWarning
    )
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    #=================================================
    #	Enable Verbose if Force parameter is not $true
    #=================================================
    if ($IsForcePresent -eq $false) {
        $VerbosePreference = 'Continue'
    }
    #=================================================
    #	Get-Disk
    #=================================================
    if ($Input) {
        $GetDisk = $Input
    } else {
        $GetDisk = Get-LocalDisk | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number
    }
    #=================================================
    #	Get DiskNumber
    #=================================================
    if ($PSBoundParameters.ContainsKey('DiskNumber')) {
        $GetDisk = $GetDisk | Where-Object {$_.DiskNumber -eq $DiskNumber}
    }
    #=================================================
    #	-PartitionStyle
    #=================================================
    if (-NOT ($PSBoundParameters.ContainsKey('PartitionStyle'))) {
        if (Get-OSDGather -Property IsUEFI) {
            Write-Verbose "IsUEFI = $true"
            $PartitionStyle = 'GPT'
        } else {
            Write-Verbose "IsUEFI = $false"
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "PartitionStyle = $PartitionStyle"
    #=================================================
    #	Get-Help
    #=================================================
    if ($IsForcePresent -eq $false) {
        Get-Help $($MyInvocation.MyCommand.Name)
    }
    #=================================================
    #	Display Disk Information
    #=================================================
    $GetDisk | Select-Object -Property DiskNumber, BusType,`
    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
    FriendlyName,Model, PartitionStyle,`
    @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
    Format-Table | Out-Host
    
    if ($IsForcePresent -eq $false) {
        Break
    }
    #=================================================
    #	Display Warning
    #=================================================
    if ($PSBoundParameters.ContainsKey('ShowWarning')) {
        Write-Warning "All data on the cleared Disk will be cleared and all data will be lost"
        pause
    }
    #=================================================
    #	Clear-Disk
    #=================================================
    $ClearDisk = @()
    foreach ($Item in $GetDisk) {
        if ($PSCmdlet.ShouldProcess(
            "Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]",
            "Clear-Disk"
        ))
        {
            Write-Warning "Cleaning Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]"
            Diskpart-Clean -DiskNumber $Item.Number

            if ($Initialize -eq $true) {
                Write-Warning "Initializing $PartitionStyle Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName)"
                $Item | Initialize-Disk -PartitionStyle $PartitionStyle
            }
            
            $ClearDisk += Get-OSDDisk -Number $Item.Number
        }
    }
    #=================================================
    #	Return
    #=================================================
    if ($PSBoundParameters.ContainsKey('NoResults')) {
        #Don't return results
    }
    else {
        $ClearDisk | Select-Object -Property DiskNumber, BusType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName, Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
    }
    #=================================================
}
