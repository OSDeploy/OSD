
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
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        #Creates or updates the OSDCloudRE Ramdisk
        [System.Management.Automation.SwitchParameter]
        $SetRamdisk,

        #Creates or updates the OSDCloudRE OSLoader
        [System.Management.Automation.SwitchParameter]
        $SetOSloader,

        #Adds OSDCloudRE to the Boot Manager Operating System selection
        [System.Management.Automation.SwitchParameter]
        $OSMenuAdd,

        #Removes OSDCloudRE from the Boot Manager Operating System selection
        [System.Management.Automation.SwitchParameter]
        $OSMenuRemove,

        #Boots to OSDCloudRE on the next reboot
        [System.Management.Automation.SwitchParameter]
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