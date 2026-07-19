function New-OSDCloudISO {
    <#
    .SYNOPSIS
    Creates an OSDCloud bootable ISO from an OSDCloud workspace.

    .DESCRIPTION
    Validates the local environment and generates an ISO from the workspace
    Media directory by calling New-WindowsAdkISO. If an OSDeploy marker file
    exists, the function creates an OSDeploy-labeled ISO for compatibility.

    .PARAMETER WorkspacePath
    Path to an OSDCloud workspace that contains Media\sources\boot.wim.
    If omitted, the current workspace returned by Get-OSDCloudWorkspace is used.

    .EXAMPLE
    New-OSDCloudISO -WorkspacePath 'C:\OSDCloud'
    Creates OSDCloud.iso from C:\OSDCloud\Media.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Updated comment-based help
    2026-07-16 - Improved validation, path handling, and error flow
    #>
    [CmdletBinding()]
    param (
        #Path to the OSDCloud Workspace containing the Media directory
        #This parameter is not necessary if Get-OSDCloudWorkspace can get a return
        [Parameter(Position=0,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String]$WorkspacePath
    )
    #=================================================
    # Dependency guard: Administrative rights, curl.exe, WinPE, and Windows 10 or later
    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
    }

    # Dependency guard: Function relies on curl.exe for downloads
    if (-not (Get-Command -Name 'curl.exe' -ErrorAction SilentlyContinue)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Requires 'curl.exe' which is not available on this system."
    }

    # Dependency guard: Must not be in WinPE environment (X: drive)
    if ($env:SystemDrive -eq 'X:') {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to run in WinPE (X: drive)."
    }

    # Dependency guard: Must be running Windows 10 or later
    if ([System.Environment]::OSVersion.Version.Major -ne 10) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Windows 10 or later is required."
    }
    #=================================================
    #	Initialize
    #=================================================
    $isoFileName = 'OSDCloud.iso'
    $isoLabel = 'OSDCloud'
    $isoPath = $null
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    #=================================================
    #	WorkspacePath
    #=================================================
    try {
        if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
            Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
        }
        $WorkspacePath = Get-OSDCloudWorkspace -ErrorAction Stop

        if (-not $WorkspacePath) {
            throw "Unable to find an OSDCloud Workspace"
        }

        if (-not (Test-Path -Path $WorkspacePath -PathType Container)) {
            throw "Unable to find an OSDCloud Workspace at $WorkspacePath"
        }

        $mediaPath = Join-Path $WorkspacePath 'Media'
        $bootWimPath = Join-Path $mediaPath 'sources\boot.wim'
        if (-not (Test-Path -Path $bootWimPath -PathType Leaf)) {
            throw "Unable to find an OSDCloud WinPE at $bootWimPath"
        }

        #region OSDeploy Compatibility
        if (Test-Path -Path (Join-Path $WorkspacePath 'OSDeploy.iso') -PathType Leaf) {
            $isoFileName = 'OSDeploy.iso'
            $isoLabel = 'OSDeploy'
        }
        #endregion
        #=================================================
        #   Create ISO
        #=================================================
        $createdIso = New-WindowsAdkISO -MediaPath $mediaPath -isoFileName $isoFileName -isoLabel $isoLabel
        if ($createdIso -and $createdIso.FullName) {
            $isoPath = $createdIso.FullName
        }
        elseif ($createdIso -is [string]) {
            $isoPath = $createdIso
        }
        else {
            $isoPath = Join-Path $WorkspacePath $isoFileName
        }

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Created ISO at $isoPath"
        Get-Item -Path $isoPath -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] $($_.Exception.Message)"
        return
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
}
