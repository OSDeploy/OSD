<#
.SYNOPSIS
Mounts a WIM file

.DESCRIPTION
Mounts a WIM file automatically selecting the Path and the Index

.LINK
https://osd.osdeploy.com/module/functions/mount-osdwindowsimage

.NOTES
19.11.21 David Segura @SeguraOSD
#>
function Mount-OSDWindowsImage {
    [CmdletBinding()]
    Param ( 
        #Specifies the full path to the root directory of the offline Windows image that you will service.
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$ImagePath,

        #Index of the WIM to Mount
        [Parameter(ValueFromPipelineByPropertyName)]
        [UInt32]$Index = 1,

        #Mount the WIM as Read Only
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$ReadOnly,

        #Opens the Path in Windows Explorer
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Explorer
    )

    Begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning 'Mount-WindowsImage: This function requires Admin Rights ELEVATED'
            Break
        }
    }
    Process {
        foreach ($Input in $ImagePath) {
            #===================================================================================================
            #   ImagePath
            #===================================================================================================
            Write-Verbose "ImagePath: $Input" -Verbose
            Write-Verbose "Index: $Index" -Verbose
            #===================================================================================================
            #   Validate File
            #===================================================================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Mount-WindowsImage: Unable to locate WindowsImage at $Input"
                Break
            }
            #===================================================================================================
            #   Get-Item
            #===================================================================================================
            $OSDWindowsImage = Get-Item $Input
            if ($OSDWindowsImage.Extension -ne '.wim') {
                Write-Warning "Mount-WindowsImage: WindowsImage does not have a .wim extension"
                Break
            }
            if ($OSDWindowsImage.IsReadOnly -eq $true) {
                Write-Warning "Mount-WindowsImage: WindowsImage is Read Only"
                Break
            }
            #===================================================================================================
            #   Set Mount Path
            #===================================================================================================
            $OSDMountPath = $env:Temp + '\OSD' + (Get-Random)
            if (! (Test-Path $OSDMountPath)) {New-Item $OSDMountPath -ItemType Directory -Force | Out-Null}
            $Path = (Get-Item $OSDMountPath).FullName
            #===================================================================================================
            #   Mount-WindowsImage
            #===================================================================================================
            if ($ReadOnly.IsPresent) {
                Mount-WindowsImage -Path $Path -ImagePath $Input -Index $Index -ReadOnly | Out-Null
            } else {
                Mount-WindowsImage -Path $Path -ImagePath $Input -Index $Index | Out-Null
            }
            #===================================================================================================
            #   Explorer
            #===================================================================================================
            if ($Explorer.IsPresent) {explorer $Path}
            #===================================================================================================
            #   Return for PassThru
            #===================================================================================================
            Return Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $Path}

        }
    }
    End {}
}