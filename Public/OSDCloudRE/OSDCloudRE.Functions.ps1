function Get-OSDCloudREPartition {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE Partition object
    
    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE Partition object
    
    .EXAMPLE
    Get-OSDCloudREPartition
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Partition')]
    param ()
    Write-Verbose $MyInvocation.MyCommand

    Get-OSDCloudREVolume | Get-Partition
}
function Get-OSDCloudREPSDrive {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE PSDrive object

    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE PSDrive object

    .EXAMPLE
    Get-OSDCloudREPSDrive

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSDriveInfo])]
    param ()
    Write-Verbose $MyInvocation.MyCommand
    
    Get-PSDrive | Where-Object {$_.Description -eq 'OSDCloudRE'}
}
function Get-OSDCloudREVolume {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE Volume object

    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE Volume object

    .EXAMPLE
    Get-OSDCloudREVolume

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Volume')]
    param ()
    Write-Verbose $MyInvocation.MyCommand
    
    Get-Volume | Where-Object {$_.FileSystemLabel -match 'OSDCloudRE'}
}
function Hide-OSDCloudREDrive {
    <#
    .SYNOPSIS
    OSDCloudRE: Hides the OSDCloudRE Drive
    
    .DESCRIPTION
    OSDCloudRE: Hides the OSDCloudRE Drive
    
    .EXAMPLE
    Hide-OSDCloudREDrive
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    [OutputType([System.Void])]
    param ()
    Write-Verbose $MyInvocation.MyCommand

    Block-StandardUser
    $OSDCloudREPartition = Get-OSDCloudREPartition

    if ($OSDCloudREPartition) {
$null = @"
select disk $($OSDCloudREPartition.DiskNumber)
select partition $($OSDCloudREPartition.PartitionNumber)
remove
set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
gpt attributes=0x8000000000000001
exit
"@ | diskpart.exe
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloudRE partition"
    }
}
function New-OSDCloudREVolume {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE Partition object
    
    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE Partition object
    
    .EXAMPLE
    New-OSDCloudREVolume
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Volume')]
    param (
        [int32]$IsoSize = 1038090240
    )
    Write-Verbose $MyInvocation.MyCommand

    Block-StandardUser

    $WindowsPartition = Get-Partition | Where-Object {$env:SystemDrive -match $_.DriveLetter}
    $WindowsDiskNumber = $WindowsPartition.DiskNumber
    $WindowsSizeMax = $WindowsPartition | Get-PartitionSupportedSize | Select-Object -ExpandProperty SizeMax
    $WindowsShrinkSize = $WindowsSizeMax - $IsoSize - 200MB
    $OSDCloudREVolume = Get-OSDCloudREVolume
    #============================================
    #	Test WindowsPartition
    #============================================
    if ($WindowsPartition) {
        #============================================
        #	Test UEFI
        #============================================
        if ((Get-OSDGather -Property IsUEFI)) {
            #============================================
            #	Test if OSDCloudRE already exists
            #============================================
            if (! $OSDCloudREVolume) {
                #============================================
                #	Shrink Windows Partition
                #============================================
                Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Shrinking Windows partition"
                $WindowsPartition | Resize-Partition -Size $WindowsShrinkSize
                #============================================
                #	Test WindowsPartition
                #   Get Results
                #============================================
                if ($WindowsPartition) {
                    #============================================
                    #   Create NewPartition
                    #============================================
                    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloudRE Partition"
                    $Global:NewPartition = New-Partition -DiskNumber $WindowsDiskNumber -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -UseMaximumSize
                    #============================================
                    #   Test NewPartition
                    #============================================
                    if ($Global:NewPartition) {
                        #============================================
                        #	Test NewPartitionNumber
                        #============================================
                        $Global:NewPartitionNumber = $Global:NewPartition.PartitionNumber
                        #============================================
                        #	Format Partition
                        #============================================
                        if ($Global:NewPartitionNumber) {
                        
                            $Global:FormatVolume = Format-Volume -Partition $Global:NewPartition -FileSystem NTFS -NewFileSystemLabel 'OSDCloudRE' -Force
                            $Global:PartitionAccessPath = Add-PartitionAccessPath -AccessPath O: -DiskNumber $Global:NewPartition.DiskNumber -PartitionNumber $Global:NewPartition.PartitionNumber

                            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Testing OSDCloudRE Volume"
                            #============================================
                            #	Return Results
                            #============================================
                            if (Get-OSDCloudREVolume) {
                                Get-OSDCloudREVolume
                            }
                            else {
                                Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not create OSDCloudRE volume"
                            }
                        }
                        else {
                            Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to get OSDCloudRE partition DiskNumber"
                        }
                    }
                    else {
                        Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create an OSDCloudRE partition"
                    }
                }
                else {
                    Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to shink Windows partition"
                }
            }
            else {
                Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Cannot create a second OSDCloudRE instance"
            }
        }
        else {
            Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE requires UEFI"
        }
    }
    else {
        Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find the Windows Partition"
    }
}
function Set-OSDCloudREBootmgr {
    <#
    .SYNOPSIS
    OSDCloudRE: Configures OSDCloudRE Boot Manager options

    .DESCRIPTION
    OSDCloudRE: Configures OSDCloudRE Boot Manager options. Requires ADMIN righs

    .EXAMPLE
    Set-OSDCloudREBootmgr -SetRamdisk -SetOSloader
    Creates or updates the OSDCloudRE Ramdisk and OSLoader
    Requires boot content in O:\
    
    .EXAMPLE
    Set-OSDCloudREBootmgr -OSMenuAdd
    Adds OSDCloudRE to the Boot Manager Operating System selection

    .EXAMPLE
    Set-OSDCloudREBootmgr -OSMenuRemove
    Removes OSDCloudRE from the Boot Manager Operating System selection

    .EXAMPLE
    Set-OSDCloudREBootmgr -BootToOSDCloudRE
    Boots to OSDCloudRE on the next reboot

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [System.Management.Automation.SwitchParameter]
        #Creates or updates the OSDCloudRE Ramdisk
        $SetRamdisk,

        [System.Management.Automation.SwitchParameter]
        #Creates or updates the OSDCloudRE OSLoader
        $SetOSloader,

        [System.Management.Automation.SwitchParameter]
        #Adds OSDCloudRE to the Boot Manager Operating System selection
        $OSMenuAdd,

        [System.Management.Automation.SwitchParameter]
        #Removes OSDCloudRE from the Boot Manager Operating System selection
        $OSMenuRemove,

        [System.Management.Automation.SwitchParameter]
        #Boots to OSDCloudRE on the next reboot
        $BootToOSDCloudRE
    )
    Write-Verbose $MyInvocation.MyCommand

    Block-StandardUser

    if ($SetRamdisk -or $SetOSloader) {
        $OSDCloudREPartition = Get-OSDCloudREPartition
        if (! $OSDCloudREPartition) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find OSDCloudRE Partition"
        }
    }

    if ($SetRamdisk) {
        if ($OSDCloudREPartition) {
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /create '{4f534452-616d-6469-736b-536567757261}' /d OSDRamdisk /device"
            $null = bcdedit /create '{4f534452-616d-6469-736b-536567757261}' /d "OSDRamdisk" /device
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /set '{4f534452-616d-6469-736b-536567757261}' ramdisksdidevice partition=O:"
            $null = bcdedit /set '{4f534452-616d-6469-736b-536567757261}' ramdisksdidevice partition=O:
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /set '{4f534452-616d-6469-736b-536567757261}' ramdisksdipath \boot\boot.sdi"
            $null = bcdedit /set '{4f534452-616d-6469-736b-536567757261}' ramdisksdipath \boot\boot.sdi
        }
    }

    if ($SetOSloader) {
        if ($OSDCloudREPartition) {
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /create '{4f534443-6c6f-7564-5245-536567757261}' /d OSDCloudRE /application osloader"
            $null = bcdedit /create '{4f534443-6c6f-7564-5245-536567757261}' /d "OSDCloudRE" /application osloader
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' device ramdisk=[O:]\sources\boot.wim,'{4f534452-616d-6469-736b-536567757261}'"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' device ramdisk=[O:]\sources\boot.wim,'{4f534452-616d-6469-736b-536567757261}'
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' osdevice ramdisk=[O:]\sources\boot.wim,'{4f534452-616d-6469-736b-536567757261}'"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' osdevice ramdisk=[O:]\sources\boot.wim,'{4f534452-616d-6469-736b-536567757261}'
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' path \windows\system32\winload.efi"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' path \windows\system32\winload.efi
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' systemroot \Windows"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' systemroot \Windows
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' detecthal Yes"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' detecthal Yes
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' winpe Yes"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' winpe Yes
        }
    }

    if ($OSMenuAdd) {
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /displayorder '{4f534443-6c6f-7564-5245-536567757261}' /addlast"
        $null = bcdedit /displayorder '{4f534443-6c6f-7564-5245-536567757261}' /addlast
    }

    if ($OSMenuRemove) {
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /displayorder '{4f534443-6c6f-7564-5245-536567757261}' /remove"
        $null = bcdedit /displayorder '{4f534443-6c6f-7564-5245-536567757261}' /remove
    }

    if ($BootToOSDCloudRE) {
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /bootsequence '{4f534443-6c6f-7564-5245-536567757261}'"
        try {
            $null = bcdedit /bootsequence '{4f534443-6c6f-7564-5245-536567757261}'
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE set for next boot"
        }
        catch {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE could not be set for next boot"
        }
    }
}
function Show-OSDCloudREDrive {
    <#
    .SYNOPSIS
    OSDCloudRE: Shows the OSDCloudRE Drive
    
    .DESCRIPTION
    OSDCloudRE: Shows the OSDCloudRE Drive
    
    .EXAMPLE
    Show-OSDCloudREDrive
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    [OutputType([System.Void])]
    param ()
    Write-Verbose $MyInvocation.MyCommand

    Block-StandardUser
    $OSDCloudREPartition = Get-OSDCloudREPartition

    if ($OSDCloudREPartition) {
$null = @"
select disk $($OSDCloudREPartition.DiskNumber)
select partition $($OSDCloudREPartition.PartitionNumber)
set id="ebd0a0a2-b9e5-4433-87c0-68b6b72699c7"
gpt attributes=0x0000000000000000
assign letter=o
rescan
exit
"@ | diskpart.exe
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloudRE partition"
    }
}