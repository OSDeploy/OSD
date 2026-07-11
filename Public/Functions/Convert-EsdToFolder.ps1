function Convert-EsdToFolder {
    <#
    .SYNOPSIS
    Expands an ESD file into a Windows setup folder structure.

    .DESCRIPTION
    Converts an ESD image into folder media by expanding setup media and
    exporting boot and install images to the destination structure.

    .PARAMETER esdFullName
    Full path to the source ESD file.

    .PARAMETER folderFullName
    Destination folder path. If omitted, a folder is created next to the ESD.

    .EXAMPLE
    Convert-EsdToFolder -esdFullName 'C:\Media\install.esd'
    Expands the ESD into a setup folder beside the source file.

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
        [string]$folderFullName = $null
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
    #	Test Destination
    #=================================================
    if ($TestWindowsImage) {
        $esdGetItem = Get-Item -Path $esdFullName -ErrorAction Stop

        if (! ($folderFullName)) {
            $folderFullName = Join-Path $esdGetItem.Directory $esdGetItem.BaseName
        }

        if (Test-Path $folderFullName) {
            Write-Warning "Delete exiting folder at $folderFullName"
            Break
        }
        else {
            try {
                New-Item -Path $folderFullName -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Warning "New-Item failed $folderFullName"
                $folderFullName = $(Join-Path $env:TEMP $(Get-Random))
                New-Item -Path $folderFullName -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
        }
        #=================================================
        #   Build
        #=================================================
        Write-Verbose -Verbose "ESD will be expanded to $folderFullName"
        $esdGetWindowsImage = Get-WindowsImage -ImagePath $esdGetItem.FullName -ErrorAction Stop
        foreach ($esdWindowsImage in $esdGetWindowsImage) {
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
        #=================================================
        #	Get-Item
        #=================================================
        Get-Item -Path $folderFullName
        #=================================================
    }
}
