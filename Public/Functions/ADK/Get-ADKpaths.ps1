<#
.SYNOPSIS
Gets many Windows ADK Paths into a hash to easily use in your code

.DESCRIPTION
Gets many Windows ADK Paths into a hash to easily use in your code

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Get-AdkPaths {
    [CmdletBinding()]
    param (
        [System.String]
        $AdkRoot,

        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('amd64', 'x86', 'arm64')]
        [Alias('Architecture')]
        [string]$Arch = $Env:PROCESSOR_ARCHITECTURE
    )
    #=================================================
    #   Get-AdkPaths AdkRoot
    #=================================================
    if ($AdkRoot) {
        # Do Nothing
    }
    else {
        $InstalledRoots32 = 'HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots'
        $InstalledRoots64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots'
        $RegistryValue = 'KitsRoot10'
        $KitsRoot10 = $null
 
        if (Test-Path -Path $InstalledRoots64) {
            $RegistryKey = Get-Item -Path $InstalledRoots64
            if ($null -ne $RegistryKey.GetValue($RegistryValue)) {
                $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots64 -Name $RegistryValue -ErrorAction SilentlyContinue
            }
        }

        if (-NOT ($KitsRoot10)) {
            if (Test-Path -Path $InstalledRoots32) {
                $RegistryKey = Get-Item -Path $InstalledRoots32
                if ($null -ne $RegistryKey.GetValue($RegistryValue)) {
                    $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots32 -Name $RegistryValue -ErrorAction SilentlyContinue
                }
            }
        }

        if ($KitsRoot10) {
            $AdkRoot = Join-Path $KitsRoot10 'Assessment and Deployment Kit'
        }
        else {
            Write-Warning "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] Unable to determine ADK Path"
            return
        }
    }
    #=================================================
    #   WinPERoot
    #=================================================
    $WinPERoot = Join-Path $AdkRoot 'Windows Preinstallation Environment'
    if (-NOT (Test-Path $WinPERoot -PathType Container)) {
        Write-Warning "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] WinPERoot is not a valid path $WinPERoot"
        $WinPERoot = $null
        return
    }
    #=================================================
    #   PathDeploymentTools
    #=================================================
    $PathDeploymentTools = Join-Path $AdkRoot (Join-Path 'Deployment Tools' $Arch)
    $PathWinPE = Join-Path $WinPERoot $Arch
    #=================================================
    #   Create Object
    #=================================================
    $Results = [PSCustomObject] @{
        #KitsRoot           = $KitsRoot10
        AdkRoot             = $AdkRoot
        PathBCDBoot         = Join-Path $PathDeploymentTools 'BCDBoot'
        PathDeploymentTools = $PathDeploymentTools
        PathDISM            = Join-Path $PathDeploymentTools 'DISM'
        PathOscdimg         = Join-Path $PathDeploymentTools 'Oscdimg'
        PathUsmt            = Join-Path $AdkRoot (Join-Path 'User State Migration Tool' $Arch)
        PathWinPE           = Join-Path $WinPERoot $Arch
        PathWinPEMedia      = Join-Path $PathWinPE 'Media'
        PathWinSetup        = Join-Path $AdkRoot (Join-Path 'Windows Setup' $Arch)
        WinPEOCs            = Join-Path $PathWinPE 'WinPE_OCs'
        WinPERoot           = $WinPERoot
        WimSourcePath       = Join-Path $PathWinPE 'en-us\winpe.wim'

        bcdbootexe          = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bcdboot.exe')
        bcdeditexe          = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bcdedit.exe')
        bootsectexe         = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bootsect.exe')
        dismexe             = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'dism.exe')
        efisysbin           = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'efisys.bin')
        efisysnopromptbin   = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'efisys_noprompt.bin')
        etfsbootcom         = if ($Arch -eq 'arm64') {
            # ARM64 does not have a etfsboot.com | Redirect to amd64 folder
            Join-Path (Join-Path $AdkRoot (Join-Path 'Deployment Tools' 'amd64')) (Join-Path 'Oscdimg' 'etfsboot.com')
        }
        else {
            Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'etfsboot.com')
        }
        imagexexe           = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'imagex.exe')
        oa3toolexe          = Join-Path $PathDeploymentTools (Join-Path 'Licensing\OA30' 'oa3tool.exe')
        oscdimgexe          = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'oscdimg.exe')
        pkgmgrexe           = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'pkgmgr.exe')
    }
    Return $Results
}
