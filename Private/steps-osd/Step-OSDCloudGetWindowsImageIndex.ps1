function Step-OSDCloudGetWindowsImageIndex {
    <#
        .SYNOPSIS
        Determines the Windows image index to apply from a WIM or ESD.

        .DESCRIPTION
        Validates the provided Windows image path, enumerates available indexes,
        and sets $global:RecastOSDCloud.WindowsImageIndex. If only one index is
        present, index 1 is selected automatically. When an EditionId is supplied,
        it attempts to resolve a matching index. If no single match is found,
        the user is prompted to select an index interactively.

        .PARAMETER ImagePath
        Path to the Windows image file (WIM or ESD). Defaults to
        $global:RecastOSDCloud.OperatingSystemFileObject.FullName.

        .PARAMETER EditionId
        Optional EditionId used to auto-select a matching image index.
        Defaults to $global:RecastOSDCloud.OSEditionId.

        .EXAMPLE
        Step-OSDCloudGetWindowsImageIndex
        Uses default OSDCloud globals to validate the image and determine the
        image index.

        .EXAMPLE
        Step-OSDCloudGetWindowsImageIndex -ImagePath 'D:\OSDCloud\OS\install.wim' -EditionId 'Professional'
        Resolves and sets the matching image index for the specified edition.

        .LINK
        https://github.com/OSDeploy/OSD/tree/master/docs

        .NOTES
        Author: David Segura - Recast Software
        2026-07-17 - Updated comment-based help block
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [System.String]
        $ImagePath = $global:RecastOSDCloud.OperatingSystemFileObject.FullName,

        [Parameter(Mandatory = $false)]
        [System.String]
        $EditionId = $global:RecastOSDCloud.OSEditionId
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    # Do we have a WindowsImage to test?
    if ($null -eq $ImagePath) {
        throw "[$(Get-Date -format s)] WindowsImage does not have an ImagePath."
    }
    #=================================================
    # Does the Path exist?
    if (-not (Test-Path $ImagePath)) {
        throw "[$(Get-Date -format s)] WindowsImage does not exist at the ImagePath: $ImagePath"
    }
    #=================================================
    # Does Get-WindowsImage work?
    try {
        $WindowsImage = Get-WindowsImage -ImagePath $ImagePath -ErrorAction Stop
    }
    catch {
        throw "[$(Get-Date -format s)] Unable to verify the Windows Image using Get-WindowsImage. $_"
    }
    #=================================================
    # Is there only one ImageIndex?
    $WindowsImageCount = ($WindowsImage).Count

    if ($WindowsImageCount -eq 1) {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCloud only found a single ImageIndex to expand"
        $global:RecastOSDCloud.WindowsImageIndex = 1
        return
    }
    #=================================================
    # Get the ImageIndex of the EditionId
    if ($EditionId) {
        $MatchingWindowsImage = $WindowsImage | `
            ForEach-Object { Get-WindowsImage -ImagePath $ImagePath -Index $_.ImageIndex } | `
            Where-Object { $_.EditionId -eq $EditionId }

        if ($MatchingWindowsImage -and $MatchingWindowsImage.Count -eq 1) {
            $global:RecastOSDCloud.WindowsImage = $MatchingWindowsImage
            $global:RecastOSDCloud.WindowsImageIndex = $MatchingWindowsImage.ImageIndex
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] EditionId $EditionId found at ImageIndex $($global:RecastOSDCloud.WindowsImageIndex)"
            return
        }
    }
    #=================================================
    # Unable to determine which ImageIndex to apply, so prompt the user to select the ImageIndex
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] Select the WindowsImage to expand"
    $SelectWindowsImage = $WindowsImage | Where-Object { $_.ImageSize -gt 3000000000 }

    if ($SelectWindowsImage) {
        $SelectWindowsImage | Select-Object -Property ImageIndex, ImageName | Format-Table | Out-Host

        do {
            $SelectReadHost = Read-Host -Prompt 'Select an WindowsImage to expand by ImageIndex [Number]'
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $SelectWindowsImage.ImageIndex))))

        $global:RecastOSDCloud.WindowsImageIndex = $SelectReadHost
        return
    }
    #=================================================
    # Everything we tried failed, so exit OSDCloud
    throw "[$(Get-Date -format s)] Unable to determine the ImageIndex to apply."
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
