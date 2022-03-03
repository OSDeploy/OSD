function New-OSDCloudREVolume {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE Partition object
    
    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE Partition object
    
    .EXAMPLE
    New-OSDCloudREVolume
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param ()
    Write-Verbose $MyInvocation.MyCommand

    Block-StandardUser

    $WindowsPartition = Get-Partition | Where-Object {$env:SystemDrive -match $_.DriveLetter}
    $WindowsDiskNumber = $WindowsPartition.DiskNumber
    $WindowsSizeMax = $WindowsPartition | Get-PartitionSupportedSize | Select-Object -ExpandProperty SizeMax
    $WindowsShrinkSize = $WindowsSizeMax - 990MB
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
                Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Shrinking Windows partition 990MB"
                $WindowsPartition | Resize-Partition -Size $WindowsShrinkSize
                #============================================
                #	Test WindowsPartition
                #   Get Results
                #============================================
                if ($WindowsPartition) {
                    #============================================
                    #	Create NewPartition
                    #============================================
                    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloudRE Partition"
                    $NewPartition = New-Partition -DiskNumber $WindowsDiskNumber -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -UseMaximumSize
                    #============================================
                    #	Test NewPartition
                    #============================================
                    if ($NewPartition) {
                        #============================================
                        #	Test NewPartitionNumber
                        #============================================
                        $NewPartitionNumber = $NewPartition.PartitionNumber
                        #============================================
                        #	Format Partition
                        #============================================
                        if ($NewPartitionNumber) {
                            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) select disk $WindowsDiskNumber"
                            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) select partition $NewPartitionNumber"
                            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) format fs=ntfs quick label=`"OSDCloudRE`""
                            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) assign letter=o"
                            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) rescan"
                            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) exit"
        
$null = @"
select disk $WindowsDiskNumber
select partition $NewPartitionNumber
format fs=ntfs quick label="OSDCloudRE"
assign letter=o
rescan
exit
"@ | diskpart.exe
        
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