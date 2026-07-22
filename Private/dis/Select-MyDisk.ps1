function Select-MyDisk {
    [CmdletBinding()]
    param (

        [ValidateSet('NVMe','SATA','USB')]
        [string]$BusType,
        [ValidateSet('NVMe','SATA','USB')]
        [string]$BusTypeNot,
        [ValidateSet('HDD','SSD','USB')]
        [string]$MediaType,
        [string]$MediaTypeNot,
        [int]$MaxSizeGB,
        [int]$MinSizeGB,
        [string]$Message = "Enter the Disk Number or CTRL+C to cancel"
    )

    $GetMyDisk = Get-MyDisk

    if ($BusType) {$GetMyDisk = $GetMyDisk | Where-Object {$_.BusType -match $BusType}}
    if ($BusTypeNot) {$GetMyDisk = $GetMyDisk | Where-Object {$_.BusType -notmatch $BusTypeNot}}
    if ($MediaType) {$GetMyDisk = $GetMyDisk | Where-Object {$_.MediaType -match $MediaType}}
    if ($MediaTypeNot) {$GetMyDisk = $GetMyDisk | Where-Object {$_.MediaType -notmatch $MediaTypeNot}}

    if ($MinSizeGB) {$GetMyDisk = $GetMyDisk | Where-Object {$_."Size(GB)" -gt $MinSizeGB}}
    if ($MaxSizeGB) {$GetMyDisk = $GetMyDisk | Where-Object {$_."Size(GB)" -lt $MaxSizeGB}}

    $Table = $GetMyDisk | Format-Table | Out-Host
    
    $DiskNumber = Read-Host -Prompt "$Table $Message"

    while ($DiskNumber -lt 0 -or $DiskNumber -notin $GetMyDisk.Number) {
        $DiskNumber = Read-Host -Prompt "$Table $Message"
    }
    return $DiskNumber
}