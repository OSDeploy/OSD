function Convert-EsdToIso {
    <#
    .SYNOPSIS
    Converts an ESD file into an ISO image.

    .DESCRIPTION
    Expands and exports required images from an ESD into a temporary media
    folder, then creates an ISO using Convert-FolderToIso.

    .PARAMETER esdFullName
    Full path to the source ESD file.

    .PARAMETER isoFullName
    Destination ISO file path. If omitted, an ISO is created beside the ESD.

    .PARAMETER isoLabel
    ISO volume label. Must be 1 to 16 characters.

    .PARAMETER noPrompt
    Uses no-prompt UEFI boot image behavior when creating the ISO.

    .PARAMETER Demo
    Shows conversion actions without exporting images.

    .EXAMPLE
    Convert-EsdToIso -esdFullName 'C:\Media\install.esd'
    Converts install.esd to an ISO in the same directory.

    .EXAMPLE
    Convert-EsdToIso -esdFullName 'C:\Media\install.esd' -isoFullName 'C:\ISO\Custom.iso' -isoLabel 'CustomISO' -noPrompt
    Converts the ESD to a custom-labeled ISO at the specified path.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]$esdFullName,

        [string]$isoFullName = $null,

        [ValidateLength(1,16)]
        [string]$isoLabel = 'EsdToIso',

        [System.Management.Automation.SwitchParameter]$noPrompt,

        [System.Management.Automation.SwitchParameter]$Demo
    )
    #=================================================
    #	Blocks
    #=================================================
    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required to run this function"
        return
    }
    Block-WindowsVersionNe10
    Block-WindowsReleaseIdLt1703
    #=================================================
    #	Test-WindowsImage
    #=================================================
    $TestWindowsImage = Test-WindowsImage -ImagePath $esdFullName
    #=================================================
    #   Test Destination
    #=================================================
    if ($TestWindowsImage) {
        $esdGetItem = Get-Item -Path $esdFullName -ErrorAction Stop

        $folderFullName = $(Join-Path $env:TEMP $(Get-Random))
        New-Item -Path $folderFullName -ItemType Directory -Force -ErrorAction Stop | Out-Null

        if (! ($isoFullName)) {
            #$isoFullName = $(Join-Path $env:TEMP $([string]$(Get-Random) + '.iso'))
            $isoFullName = Join-Path $esdGetItem.Directory ($esdGetItem.BaseName + '.iso')
        }

        if (Test-Path $isoFullName) {
            Write-Warning "Delete exiting ISO at $isoFullName"
            Break
        }
        else {
            try {
                New-Item -Path $isoFullName -Force -ErrorAction Stop | Out-Null
                Remove-Item -Path $isoFullName -Force -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Warning "New-Item failed $isoFullName"
                $isoFullName = $(Join-Path $env:TEMP $([string]$(Get-Random) + '.iso'))
            }
            #Write-Verbose -Verbose "isoFullName: $isoFullName"
        }
        #=================================================
        #   Build
        #=================================================
        Write-Verbose -Verbose "ESD will be expanded to $folderFullName"
        $esdGetWindowsImage = Get-WindowsImage -ImagePath $esdGetItem.FullName -ErrorAction Stop
        foreach ($esdWindowsImage in $esdGetWindowsImage) {
            if ($Demo) {
                if ($esdWindowsImage.ImageName -eq 'Windows Setup Media') {
                    Write-Verbose -Verbose "Expanding Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
                } elseif ($esdWindowsImage.ImageName -like "*Windows PE*") {
                    Write-Verbose -Verbose "Exporting Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
                } elseif ($esdWindowsImage.ImageName -like "*Windows Setup*") {
                    Write-Verbose -Verbose "Exporting Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
                } else {
                    Write-Verbose -Verbose "Exporting Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
                }
            }
            else {
                if ($esdWindowsImage.ImageName -eq 'Windows Setup Media') {
                    Write-Verbose -Verbose "Expanding Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
                    Expand-WindowsImage -ImagePath "$($esdWindowsImage.ImagePath)" -ApplyPath "$folderFullName" -Index "$($esdWindowsImage.ImageIndex)" -ErrorAction SilentlyContinue | Out-Null
                } elseif ($esdWindowsImage.ImageName -like "*Windows PE*") {
                    Write-Verbose -Verbose "Exporting Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
                    Export-WindowsImage -SourceImagePath "$($esdWindowsImage.ImagePath)" -SourceIndex $($esdWindowsImage.ImageIndex) -DestinationImagePath "$folderFullName\sources\boot.wim" -CompressionType Max -ErrorAction SilentlyContinue | Out-Null
                } elseif ($esdWindowsImage.ImageName -like "*Windows Setup*") {
                    Write-Verbose -Verbose "Exporting Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
                    Export-WindowsImage -SourceImagePath "$($esdWindowsImage.ImagePath)" -SourceIndex $($esdWindowsImage.ImageIndex) -DestinationImagePath "$folderFullName\sources\boot.wim" -CompressionType Max -Setbootable -ErrorAction SilentlyContinue | Out-Null
                } else {
                    Write-Verbose -Verbose "Exporting Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
                    Export-WindowsImage -SourceImagePath "$($esdWindowsImage.ImagePath)" -SourceIndex $($esdWindowsImage.ImageIndex) -DestinationImagePath "$folderFullName\sources\install.wim" -CompressionType Max -ErrorAction SilentlyContinue | Out-Null
                }
            }
        }
        #=================================================
        #	Create ISO
        #=================================================
        if ($noPrompt) {
            Convert-FolderToIso -folderFullName $folderFullName -isoFullName $isoFullName -isoLabel $isoLabel -noPrompt
        }
        else {
            Convert-FolderToIso -folderFullName $folderFullName -isoFullName $isoFullName -isoLabel $isoLabel
        }
        #=================================================
    }
}
