<#
.SYNOPSIS
Finds Disks that are suitable for OSD.  Returns the Get-Disk Object

.DESCRIPTION
Finds Disks that are suitable for OSD.  Returns the Get-Disk Object
BusType -ne 'USB'
BusType -ne 'File Backed Virtual'
FriendlyName -notmatch 'Reader'
IsReadOnly -eq $false
ProvisioningType -eq 'Fixed'
Size -gt 15GB

.LINK
https://osd.osdeploy.com/module/functions/Get-Disk.osd

.NOTES
19.12.12    Created by David Segura @SeguraOSD
#>
function Get-Disk.osd {
    [CmdletBinding(DefaultParameterSetName = 'OSDDisk')]
    param (
        #Fixed Disk Number
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'OSDDisk')]
        [ValidateSet('DiskNumber','Smallest','Largest')]
        [string]$SortOrder = 'DiskNumber',

        #Disk NVMe Preference
        [Parameter(ParameterSetName = 'OSDDisk')]
        [ValidateSet('Prefer','Require','Exclude')]
        [string]$IsNvme,

        #System Drive Preference
        [Parameter(ParameterSetName = 'OSDDisk')]
        [ValidateSet('Prefer','Require','Exclude')]
        [string]$IsSystem,

        #Return System Disks, which will include IsSystem
        [Parameter(ParameterSetName = 'SystemDisk', Mandatory = $true)]
        [switch]$SystemDisk,

        #Return non System Disks, which will exclude IsSystem
        [Parameter(ParameterSetName = 'NonSystemDisk', Mandatory = $true)]
        [switch]$NonSystemDisk,

        #Display a GridView with PassThru
        [switch]$GridView

    )
    #=======================================================================
    #	Get-Disk
    #=======================================================================
    $global:GetOSDDisk = Get-Disk | Select-Object -Property * | Sort-Object -Property DiskNumber
    #=======================================================================
    #	ProvisioningType -eq Fixed
    #=======================================================================
<#     $global:GetOSDDisk | Where-Object {$_.ProvisioningType -ne 'Fixed'} | ForEach-Object {
        Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - ProvisioningType is not Fixed (exclude)"
    }
    $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.ProvisioningType -eq 'Fixed'} #>
    #=======================================================================
    #	BusType -ne USB
    #=======================================================================
    $global:GetOSDDisk | Where-Object {$_.BusType -eq 'USB'} | ForEach-Object {
        Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - BusType is USB (exclude)"
    }
    $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.BusType -ne 'USB'}
    #=======================================================================
    #	BusType -ne File Backed Virtual
    #=======================================================================
<#     $global:GetOSDDisk | Where-Object {$_.BusType -eq 'File Backed Virtual'} | ForEach-Object {
        Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - BusType File Backed Virtual (exclude)"
    }
    $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.BusType -ne 'File Backed Virtual'} #>
    #=======================================================================
    #	IsReadOnly -eq $false
    #=======================================================================
<#     $global:GetOSDDisk | Where-Object {$_.IsReadOnly -eq $true} | ForEach-Object {
        Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - IsReadOnly (exclude)"
    }
    $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.IsReadOnly -eq $false} #>
    #=======================================================================
    #	LargestFreeExtent  -le 100TB
    #=======================================================================
    $global:GetOSDDisk | Where-Object {$_.LargestFreeExtent -gt 100TB} | ForEach-Object {
        Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - LargestFreeExtent is $([math]::Round(($($_.LargestFreeExtent) / 1TB))) TB (exclude because it's probably a Reader)"
    }
    $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.LargestFreeExtent -le 100TB}
    #=======================================================================
    #	Exclude Drives Smaller than 15GB
    #=======================================================================
<#     $global:GetOSDDisk | Where-Object {$_.Size -lt 16GB} | ForEach-Object {
        Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - Size is $([math]::Round(($($_.Size) / 1GB))) GB (exclude because its too small)"
    }
    $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.Size -ge 16GB} #>
    #=======================================================================
    #	Reader
    #=======================================================================
<#     $global:GetOSDDisk | Where-Object {$_.FriendlyName -match 'Reader'} | ForEach-Object {
        Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - FriendlyName match Reader (exclude)"
    }
    $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.FriendlyName -notmatch 'Reader'} #>
    #=======================================================================
    #   NonSystemDisk
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'SystemDisk') {
        $global:SystemDisks = $global:GetOSDDisk | Where-Object {$_.IsSystem -eq $true}
        if ($GridView.IsPresent) {
            $global:SystemDisks = $global:SystemDisks | Out-GridView -PassThru -Title "Select Disks for PassThru"
        }
        Return $global:SystemDisks
    }
    #=======================================================================
    #   NonSystemDisk
    #=======================================================================
    if ($PSCmdlet.ParameterSetName -eq 'NonSystemDisk') {
        $global:NonSystemDisks = $global:GetOSDDisk | Where-Object {$_.IsSystem -eq $false}
        if ($GridView.IsPresent) {
            $global:NonSystemDisks = $global:NonSystemDisks | Out-GridView -PassThru -Title "Select Disks for PassThru"
        }
        Return $global:NonSystemDisks
    }
    #=======================================================================
    #	IsNvme -eq 'Require'
    #=======================================================================
    if ($IsNvme -eq 'Require') {
        $global:GetOSDDisk | Where-Object {$_.BusType -ne 'NVMe'} | ForEach-Object {
            Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - NVMe False (Required)"
        }
        $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.BusType -eq 'NVMe'}
    }
    #=======================================================================
    #	IsNvme -eq 'Exclude'
    #=======================================================================
    if ($IsNvme -eq 'Exclude') {
        $global:GetOSDDisk | Where-Object {$_.BusType -eq 'NVMe'} | ForEach-Object {
            Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - NVMe True (Exclude)"
        }
        $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.BusType -ne 'NVMe'}
    }
    #=======================================================================
    #	IsSystem -eq 'Require'
    #=======================================================================
    if ($IsSystem -eq 'Require') {
        $global:GetOSDDisk | Where-Object {$_.IsSystem -eq $false} | ForEach-Object {
            Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - IsSystem False (Required)"
        }
        $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.IsSystem -eq $true}
    }
    #=======================================================================
    #	IsSystem -eq 'Exclude'
    #=======================================================================
    if ($IsSystem -eq 'Exclude') {
        $global:GetOSDDisk | Where-Object {$_.IsSystem -eq $true} | ForEach-Object {
            Write-Verbose "DiskNumber $($_.DiskNumber) $($_.FriendlyName) - IsSystem True (Exclude)"
        }
        $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.IsSystem -eq $false}
    }
    #=======================================================================
    #	Return for 0 or 1 Disk
    #=======================================================================
    if (($global:GetOSDDisk).Count -eq 0) {Return}
    
    if (($global:GetOSDDisk).Count -eq 1) {
        if ($GridView.IsPresent) {
            $global:GetOSDDisk = $global:GetOSDDisk | Out-GridView -PassThru -Title "Select Disks for PassThru"
        }
        Return $global:GetOSDDisk
    }


    #=======================================================================
    #	Return Existing System Drive
    #=======================================================================
    if ($IsSystem -eq $true) {
        Write-Verbose "Returning Existing System Disk"
        Return $global:GetOSDDisk = $global:GetOSDDisk | Where-Object {$_.IsSystem -eq $true}
        foreach ($item in $global:GetOSDDisk) {
            if ($item.IsSystem -eq $true) {Return $item}
            if ($item.BootFromDisk -eq $true) {Return $item}
            if ($item.IsBoot -eq $true) {Return $item}
        }
    }
    #=======================================================================
    #	Return First Priority
    #=======================================================================
    if ($SortOrder -eq 'DiskNumber') {

        if ($IsNvme -eq 'Prefer') {
            Write-Verbose "Selecting Priority First NVMe"
            foreach ($item in $global:GetOSDDisk) {if ($item.BusType -eq 'NVMe') {Return $item}}
        }
        
        Write-Verbose "Selecting Priority First"
        $global:GetOSDDisk = $global:GetOSDDisk
        Return $global:GetOSDDisk
    }
    #=======================================================================
    #	Return Smallest Priority
    #=======================================================================
    if ($SortOrder -eq 'Smallest') {
        $global:GetOSDDisk = $global:GetOSDDisk | Sort-Object -Property Size | Group-Object -Property Size | ForEach-Object {$_.Group | Sort-Object -Property DiskNumber}

        if ($IsNvme -eq 'Prefer') {
            Write-Verbose "Selecting Priority Smallest NVMe"
            foreach ($item in $global:GetOSDDisk) {if ($item.BusType -eq 'NVMe') {Return $item}}
        }

        Write-Verbose "Selecting Priority Smallest"
        $global:GetOSDDisk = $global:GetOSDDisk
        Return $global:GetOSDDisk
    }
    #=======================================================================
    #	Return Largest Priority
    #=======================================================================
    if ($SortOrder -eq 'Largest') {
        $global:GetOSDDisk = $global:GetOSDDisk | Sort-Object -Property Size -Descending | Group-Object -Property Size | ForEach-Object {$_.Group | Sort-Object -Property DiskNumber}
    }
    
    if ($IsNvme -eq 'Prefer') {
        Write-Verbose "Selecting Priority Largest NVMe"
        foreach ($item in $global:GetOSDDisk) {if ($item.BusType -eq 'NVMe') {Return $item}}
    }

    Write-Verbose "Selecting Priority Largest"
    $global:GetOSDDisk = $global:GetOSDDisk
    Return $global:GetOSDDisk
}