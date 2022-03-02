
function Set-OSDCloudREBootmgr {
    <#
    .SYNOPSIS
    OSDCloudRE: Configures OSDCloudRE Boot Manager options

    .DESCRIPTION
    OSDCloudRE: Configures OSDCloudRE Boot Manager options. Requires ADMIN righs
    
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
    Block-StandardUser

    if ($OSMenuAdd) {
        $null = bcdedit /displayorder '{4f534443-6c6f-7564-5245-536567757261}' /addlast
    }

    if ($OSMenuRemove) {
        $null = bcdedit /displayorder '{4f534443-6c6f-7564-5245-536567757261}' /remove
    }

    if ($BootToOSDCloudRE) {
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /bootsequence {4f534443-6c6f-7564-5245-536567757261}"
        try {
            $null = bcdedit /bootsequence '{4f534443-6c6f-7564-5245-536567757261}'
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE set for next boot"
        }
        catch {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE could not be set for next boot"
        }
    }
}