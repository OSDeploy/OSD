function Get-WindowsAdkPaths {
    <#
    .SYNOPSIS
    Retrieves the command paths of the Windows Assessment and Deployment Kit (ADK).

    .DESCRIPTION
    Retrieves the command paths of the Windows Assessment and Deployment Kit (ADK).

    .NOTES
    Author: David Segura
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        # Windows ADK architecture to get. Valid values are 'amd64', 'x86', and 'arm64'.
        [ValidateSet('amd64', 'x86', 'arm64')]
        [Alias('Arch')]
        [string]$Architecture = $Env:PROCESSOR_ARCHITECTURE,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        # Path to the Windows ADK root directory. Typically 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
        [ValidateScript({
            if (!($_ | Test-Path)) {
                throw 'Path does not exist'
            }
            if (!($_ | Test-Path -PathType Container)) {
                throw 'Path must be a directory'
            }
            if (!(Test-Path "$($_.FullName)\Deployment Tools")) {
                throw 'Path does not contain a Deployment Tools directory'
            }
            if (!(Test-Path "$($_.FullName)\Windows Preinstallation Environment")) {
                throw 'Path does not contain a Windows Preinstallation Environment directory'
            }
            return $true
        })]
        [System.IO.FileInfo]
        [Alias('AdkRoot')]
        $WindowsAdkRoot
    )
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    # region Get Windows ADK information from the Registry
    if (-not $WindowsAdkRoot) {
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
            $WindowsAdkRoot = Join-Path $KitsRoot10 'Assessment and Deployment Kit'
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] Unable to determine ADK Path"
            return
        }
    }
    #endregion
    #=================================================
    # region Validate Windows ADK Path
    $WinPERoot = Join-Path $WindowsAdkRoot 'Windows Preinstallation Environment'
    if (-NOT (Test-Path $WinPERoot -PathType Container)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] WinPERoot is not a valid path $WinPERoot"
        $WinPERoot = $null
        return
    }
    #endregion
    #=================================================
    # region Set ADK Paths
    $PathDeploymentTools = Join-Path $WindowsAdkRoot (Join-Path 'Deployment Tools' $Architecture)
    $PathWinPE = Join-Path $WinPERoot $Architecture
    #endregion
    #=================================================
    # region Build Results
    $Results = [PSCustomObject] @{
        #KitsRoot           = $KitsRoot10
        AdkRoot             = $WindowsAdkRoot
        PathBCDBoot         = Join-Path $PathDeploymentTools 'BCDBoot'
        PathDeploymentTools = $PathDeploymentTools
        PathDISM            = Join-Path $PathDeploymentTools 'DISM'
        PathOscdimg         = Join-Path $PathDeploymentTools 'Oscdimg'
        PathUsmt            = Join-Path $WindowsAdkRoot (Join-Path 'User State Migration Tool' $Architecture)
        PathWinPE           = Join-Path $WinPERoot $Architecture
        PathWinPEMedia      = Join-Path $PathWinPE 'Media'
        PathWinSetup        = Join-Path $WindowsAdkRoot (Join-Path 'Windows Setup' $Architecture)
        WinPEOCs            = Join-Path $PathWinPE 'WinPE_OCs'
        WinPERoot           = $WinPERoot
        WimSourcePath       = Join-Path $PathWinPE 'en-us\winpe.wim'

        bcdbootexe          = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bcdboot.exe')
        bcdeditexe          = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bcdedit.exe')
        bootsectexe         = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bootsect.exe')
        dismexe             = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'dism.exe')
        efisysbin           = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'efisys.bin')
        efisysnopromptbin   = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'efisys_noprompt.bin')
        etfsbootcom         = if ($Architecture -eq 'arm64') {
            # ARM64 does not have a etfsboot.com | Redirect to amd64 folder
            Join-Path (Join-Path $WindowsAdkRoot (Join-Path 'Deployment Tools' 'amd64')) (Join-Path 'Oscdimg' 'etfsboot.com')
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
    #endregion
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}