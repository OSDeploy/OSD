function Convert-EsdToWim {
    <#
    .SYNOPSIS
    Converts an ESD file into a WIM image.

    .DESCRIPTION
    Exports non-setup Windows indexes from an ESD source into a new WIM file.

    .PARAMETER esdFullName
    Full path to the source ESD file.

    .PARAMETER wimFullName
    Destination WIM file path. If omitted, a WIM is created beside the ESD.

    .EXAMPLE
    Convert-EsdToWim -esdFullName 'C:\Media\install.esd'
    Exports Windows image indexes from the ESD into install.wim.

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
        [string]$wimFullName
    )
    #=================================================
    #	Blocks
    #=================================================
    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
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

        if (! ($wimFullName)) {
            $wimFullName = Join-Path $esdGetItem.Directory ($esdGetItem.BaseName + '.wim')
        }

        if (Test-Path $wimFullName) {
            Write-Warning "Delete exiting WIM at $wimFullName"
            Break
        }
        else {
            try {
                New-Item -Path $wimFullName -Force -ErrorAction Stop | Out-Null
                Remove-Item -Path $wimFullName -Force -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Warning "New-Item failed $wimFullName"
                $wimFullName = $(Join-Path $env:TEMP $([string]$(Get-Random) + '.wim'))
            }
        }
        #=================================================
        #   Build
        #=================================================
        Write-Verbose -Verbose "ESD will be expanded to $wimFullName"
        $esdGetWindowsImage = Get-WindowsImage -ImagePath $esdGetItem.FullName -ErrorAction Stop
        foreach ($esdWindowsImage in $esdGetWindowsImage) {
            if ($esdWindowsImage.ImageName -eq 'Windows Setup Media') {
                Write-Verbose -Verbose "Skipping Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
            } elseif ($esdWindowsImage.ImageName -like "*Windows PE*") {
                Write-Verbose -Verbose "Skipping Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
            } elseif ($esdWindowsImage.ImageName -like "*Windows Setup*") {
                Write-Verbose -Verbose "Skipping Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
            } else {
                Write-Verbose -Verbose "Exporting Index $($esdWindowsImage.ImageIndex) $($esdWindowsImage.ImageName)"
                Export-WindowsImage -SourceImagePath $esdGetItem.FullName -SourceIndex $($esdWindowsImage.ImageIndex) -DestinationImagePath $wimFullName -CompressionType Max -ErrorAction SilentlyContinue | Out-Null
            }
        }
        #=================================================
        #	Create ISO
        #=================================================
        Get-Item -Path $wimFullName
        #Get-WindowsImage -ImagePath $wimFullName
        #=================================================
    }
}
