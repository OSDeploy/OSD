function Get-MyAdk {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('amd64','x86')]
        [string]$Arch = $Env:PROCESSOR_ARCHITECTURE
    )



    #===================================================================================================
    #   Get-MyAdk AdkRoot
    #===================================================================================================
    $InstalledRoots32 = 'HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots'
    $InstalledRoots64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots'

    if (Test-Path $InstalledRoots32) {
        $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots32 -Name 'KitsRoot10'
    } elseif (Test-Path $InstalledRoots64) {
        $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots64 -Name 'KitsRoot10'
    } else {
        Write-Warning "Unable to determine ADK Path"
        Break
    }
    $AdkRoot = Join-Path $KitsRoot10 'Assessment and Deployment Kit'
    #===================================================================================================
    #   WinPERoot
    #===================================================================================================
    $WinPERoot = Join-Path $AdkRoot 'Windows Preinstallation Environment'
    if (-NOT (Test-Path $WinPERoot -PathType Container)) {
        Write-Warning "Cannot find WinPERoot: $WinPERoot"
        $WinPERoot = $null
    }
    #===================================================================================================
    #   Directories
    #===================================================================================================
    $PathDeploymentTools    = Join-Path $AdkRoot (Join-Path 'Deployment Tools' $Arch)
    $PathDism               = Join-Path $PathDeploymentTools 'DISM'
    $PathOscdimg            = Join-Path $PathDeploymentTools 'Oscdimg'
    $PathUsmt               = Join-Path $AdkRoot (Join-Path 'User State Migration Tool' $Arch)
    $PathWinPE              = Join-Path $WinPERoot $Arch
    $PathWinSetup           = Join-Path $AdkRoot (Join-Path 'Windows Setup' $Arch)
    $PathWinPEMedia         = Join-Path $PathWinPE 'Media'
    #===================================================================================================
    #   Tools
    #===================================================================================================
    $BcdbootEx              = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bcdboot.exe')
    $DismEx                 = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'dism.exe')
    $ImagexEx               = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'imagex.exe')
    $PkgmgrEx               = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'pkgmgr.exe')
    #===================================================================================================
    #   Create Object
    #===================================================================================================


    
    $Results = [PSCustomObject] @{
        #KitsRoot           = $KitsRoot10
        AdkRoot             = $AdkRoot
        WinPERoot           = $WinPERoot

        PathDeploymentTools = $PathDeploymentTools
        PathDism            = $PathDism
        PathOscdimg         = $PathOscdimg
        PathUsmt            = $PathUsmt
        PathWinPE           = $PathWinPE
        PathWinPEMedia      = $PathWinPEMedia
        PathWinSetup        = $PathWinSetup

        BcdbootEx           = $BcdbootEx
        DismEx              = $DismEx
        ImagexEx            = $ImagexEx
        PkgmgrEx            = $PkgmgrEx
    }

    Return $Results
}