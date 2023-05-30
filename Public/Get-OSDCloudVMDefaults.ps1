function Get-OSDCloudVMDefaults {
    <#
    .SYNOPSIS
    Gets the OSDCloudVM Module defaults from $Global:OSDModuleResource.NewOSDCloudVM

    .DESCRIPTION
    Gets the OSDCloudVM Module defaults from $Global:OSDModuleResource.NewOSDCloudVM

    .EXAMPLE
    Get-OSDCloudVMDefaults

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param ()

    # OSDCloudVM Module Defaults
    $Results = [ordered]@{
        CheckpointVM    = [System.Boolean]$Global:OSDModuleResource.NewOSDCloudVM.CheckpointVM
        Generation      = [System.Int16]$Global:OSDModuleResource.NewOSDCloudVM.Generation
        MemoryStartupGB = [System.Int64]$Global:OSDModuleResource.NewOSDCloudVM.MemoryStartupGB
        NamePrefix      = [System.String]$Global:OSDModuleResource.NewOSDCloudVM.NamePrefix
        ProcessorCount  = [System.Int64]$Global:OSDModuleResource.NewOSDCloudVM.ProcessorCount
        StartVM         = [System.Boolean]$Global:OSDModuleResource.NewOSDCloudVM.StartVM
        SwitchName      = [System.String]$Global:OSDModuleResource.NewOSDCloudVM.SwitchName
        VHDSizeGB       = [System.Int64]$Global:OSDModuleResource.NewOSDCloudVM.VHDSizeGB
    }
    $Results
}