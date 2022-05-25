<#
.SYNOPSIS
Mounts a WIM file

.DESCRIPTION
Mounts a WIM file automatically selecting the Path and the Index

.PARAMETER ImagePath
Specifies the full path to the Windows Image

.PARAMETER Index
Index of the Windows Image

.PARAMETER ReadOnly
Mount the Windows Image as Read Only

.PARAMETER Explorer
Opens Windows Explorer to the Mount Directory

.LINK
https://osd.osdeploy.com/module/functions/mywindowsimage

.NOTES
#>
function Mount-MyWindowsImage {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$ImagePath,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [UInt32]$Index = 1,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [System.Management.Automation.SwitchParameter]$ReadOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [System.Management.Automation.SwitchParameter]$Explorer
    )

    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #=================================================
        #   Get Registry Information
        #=================================================
        $GetRegCurrentVersion = Get-RegCurrentVersion
        #=================================================
        #   Require OSMajorVersion 10
        #=================================================
        if ($GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
            Write-Warning "$($MyInvocation.MyCommand) requires OS MajorVersion 10"
            Break
        }
        #=================================================
    }
    process {
        foreach ($Input in $ImagePath) {
            Write-Verbose "$Input"
            #=================================================
            #   Get-Item
            #=================================================
            if (Get-Item $Input -ErrorAction SilentlyContinue) {
                $GetItemInput = Get-Item -Path $Input
            } else {
                Write-Warning "Unable to locate WindowsImage at $Input"
                Break
            }
            #=================================================
            #   Directory
            #=================================================
            if ($GetItemInput.PSIsContainer) {
                Write-Verbose "Directory was not expected"

                if (Test-WindowsImageMountPath -Path $GetItemInput.FullName) {
                    Write-Verbose "Windows Image is already mounted in this Directory"
                    Write-Verbose "Returning Mount-WindowsImage Object"
                    Get-WindowsImage -Mounted | Where-Object {($_.Path -eq $GetItemInput.FullName) -and ($_.ImageIndex -eq $Index)}
                    Continue
                } else {
                    Write-Warning "There isn't really anything that I can do with this directory.  Goodbye!"
                    Continue
                }
            }
            #=================================================
            #   Read Only
            #=================================================
            if ($GetItemInput.IsReadOnly) {
                Write-Warning "Cannot Mount this Read Only Image.  Goodbye!"
                Continue
            }
            #=================================================
            #   Already Mounted
            #=================================================
            if (Test-WindowsImageMounted -ImagePath $GetItemInput.FullName -Index $Index) {
                Write-Verbose "Windows Image is already mounted"
                Write-Verbose "Returning Mount-WindowsImage Object"
                Get-WindowsImage -Mounted | Where-Object {($_.ImagePath -eq $GetItemInput.FullName) -and ($_.ImageIndex -eq $Index)}
                Continue
            }
            #=================================================
            #   Not a Windows Image
            #=================================================
            if (-Not (Test-WindowsImage -ImagePath $GetItemInput.FullName)) {
                Write-Warning "Does not appear to be a Windows Image.  Goodbye!"
                Continue
            }
            #=================================================
            #   Set Mount Path
            #=================================================
            $MyWindowsImageMountPath = $env:Temp + '\Mount' + (Get-Random)
            if (-NOT (Test-Path $MyWindowsImageMountPath)) {
                New-Item $MyWindowsImageMountPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
            $Path = (Get-Item $MyWindowsImageMountPath).FullName
            #=================================================
            #   Mount-WindowsImage
            #=================================================
            $Params = @{
                Path        = $Path
                ImagePath   = $GetItemInput.FullName
                Index       = $Index
                ReadOnly    = $ReadOnly
            }
            Mount-WindowsImage @Params | Out-Null
            #=================================================
            #   Explorer
            #=================================================
            if ($Explorer.IsPresent) {explorer $Path}
            #=================================================
            #   Return for PassThru
            #=================================================
            Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $Path}
        }
    }
    end {}
}