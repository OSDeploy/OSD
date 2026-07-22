function Step-OSDCloudExpandWindowsImage {
    <#
    .SYNOPSIS
    Expands the selected OSDCloud Windows image to the local disk.

    .DESCRIPTION
    Creates a temporary scratch directory, builds parameters from the active
    OSDCloud deployment context, and applies the selected Windows image to C:\.
    In WinPE, the function runs Expand-WindowsImage, removes the source image
    file after a successful apply, and then removes the scratch directory when
    the operation completes.

    .EXAMPLE
    Step-OSDCloudExpandWindowsImage
    Expands the image defined by the current OSDCloud deployment globals to C:\.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-17 - Added comment-based help block
    2026-07-17 - Improved input validation and scratch directory lifecycle handling
    2026-07-17 - Remove source image file after successful expansion
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    # Validate required OSDCloud deployment context before applying the image.
    if ($null -eq $global:RecastOSDCloud) {
        throw "[$(Get-Date -format s)] OSDCloud deployment context was not found."
    }

    $ImagePath = $global:RecastOSDCloud.OperatingSystemFileObject.FullName
    $ImageIndex = $global:RecastOSDCloud.WindowsImageIndex
    $ScratchDirectory = 'C:\OSDCloud\Temp'

    if ([string]::IsNullOrWhiteSpace($ImagePath)) {
        throw "[$(Get-Date -format s)] OSDCloud deployment image path is not set."
    }

    if (-not (Test-Path -Path $ImagePath -ErrorAction SilentlyContinue)) {
        throw "[$(Get-Date -format s)] OSDCloud deployment image path does not exist: $ImagePath"
    }

    if (($ImageIndex -as [int]) -lt 1) {
        throw "[$(Get-Date -format s)] OSDCloud deployment image index is invalid: $ImageIndex"
    }
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    try {
        if (-not (Test-Path -Path $ScratchDirectory -ErrorAction SilentlyContinue)) {
            New-Item -Path $ScratchDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        $ExpandWindowsImageParams = @{
            ApplyPath        = 'C:\'
            ErrorAction      = 'Stop'
            ImagePath        = $ImagePath
            Index            = [int]$ImageIndex
            ScratchDirectory = $ScratchDirectory
        }

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Expand WindowsImage to C:\"
        try {
            Expand-WindowsImage @ExpandWindowsImageParams | Out-Null
        }
        catch {
            throw "[$(Get-Date -format s)] Expand-WindowsImage failed. $_"
        }

        if (Test-Path -Path $ImagePath -ErrorAction SilentlyContinue) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing source image $ImagePath"
            try {
                Remove-Item -Path $ImagePath -Force -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to remove source image $ImagePath. $_"
            }
        }
    }
    finally {
        if (Test-Path -Path $ScratchDirectory -ErrorAction SilentlyContinue) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing scratch directory $ScratchDirectory"
            try {
                Remove-Item -Path $ScratchDirectory -Force -Recurse -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to remove scratch directory $ScratchDirectory. $_"
            }
        }

        if (Test-Path -Path 'C:\OSDCloud' -ErrorAction SilentlyContinue) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing C:\OSDCloud"
            try {
                Remove-Item -Path 'C:\OSDCloud' -Force -Recurse -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to remove C:\OSDCloud. $_"
            }
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
