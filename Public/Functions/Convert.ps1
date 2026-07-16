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
    https://github.com/OSDeploy/OSD/tree/master/docs

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
    https://github.com/OSDeploy/OSD/tree/master/docs

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
    https://github.com/OSDeploy/OSD/tree/master/docs

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
function Convert-FolderToIso {
    <#
    .SYNOPSIS
    Creates an ISO file from a source folder.

    .DESCRIPTION
    Uses Windows ADK oscdimg to create a standard or bootable ISO from a folder.
    The function validates required boot files when present and supports optional
    no-prompt UEFI boot media generation.

    .PARAMETER folderFullName
    Source folder path to convert into an ISO.

    .PARAMETER isoFullName
    Destination ISO file path. If omitted, an ISO is created beside the source
    folder using the folder name.

    .PARAMETER isoLabel
    ISO volume label. Must be 1 to 16 characters.

    .PARAMETER noPrompt
    Uses efisys_noprompt.bin when available for UEFI boot media.

    .PARAMETER WindowsAdkRoot
    Optional Windows ADK root path used to resolve oscdimg.exe.

    .EXAMPLE
    Convert-FolderToIso -folderFullName 'C:\OSD\Media'
    Creates C:\OSD\Media.iso from the specified folder.

    .EXAMPLE
    Convert-FolderToIso -folderFullName 'C:\OSD\Media' -isoFullName 'C:\ISO\Custom.iso' -isoLabel 'CustomISO' -noPrompt
    Creates a bootable ISO at the specified destination with a custom label.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
                if (!($_ | Test-Path)) { throw "Path does not exist: $_" }
                if (!($_ | Test-Path -PathType Container)) { throw "Path must be a directory: $_" }
                return $true
            })]
        [Alias('FullName')]
        [string]$folderFullName,

        [string]$isoFullName = $null,

        [ValidateLength(1,16)]
        [string]$isoLabel = 'FolderToIso',

        [System.Management.Automation.SwitchParameter]$noPrompt,

        # Path to the Windows ADK root directory. Typically 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
        [ValidateScript({
            if (-NOT ($_ | Test-Path)) { throw "Path does not exist: $_" }
            if (-NOT ($_ | Test-Path -PathType Container)) { throw "Path must be a directory: $_" }
            if (-NOT (Test-Path "$($_.FullName)\Deployment Tools")) { throw "Path does not contain a Deployment Tools subfolder: $_"}
            # if (-NOT (Test-Path "$($_.FullName)\Windows Preinstallation Environment")) { throw "Path does not contain a Windows Preinstallation Environment directory: $_"}
            return $true
        })]
        [System.IO.FileInfo]
        $WindowsAdkRoot
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] Start"
    #=================================================
    #	Blocks
    #=================================================
    Block-WinPE
    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
        return
    }
    Block-PowerShellVersionLt5
    Block-WindowsVersionNe10
    Block-WindowsReleaseIdLt1703
    #=================================================
    #   isoFullName
    #=================================================
    $GetItem = Get-Item -Path $folderFullName
    if (! ($isoFullName)) {
        $isoFullName = Join-Path $($GetItem.Parent.FullName) $($GetItem.BaseName + '.iso')
    }
    #=================================================
    #	Variables
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName: $folderFullName"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] isoFullName: $isoFullName"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] isoLabel: $isoLabel"
    #=================================================
    #   Test if existing file exists and writable
    #=================================================
    if (Test-Path $isoFullName) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] Delete exiting file at $isoFullName"
        return
    }

    try {
        New-Item -Path $isoFullName -Force -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] isoFullName is not writable at $isoFullName"
        return
    }
    finally {
        if (Test-Path $isoFullName) {
            Remove-Item -Path $isoFullName -Force | Out-Null
        }
    }
    #=================================================
    #   Get Adk Paths
    #=================================================
    if ($WindowsAdkRoot) {
        $WindowsAdkPaths = Get-WindowsAdkPaths -WindowsAdkRoot $WindowsAdkRoot
    }
    else {
        $WindowsAdkPaths = Get-WindowsAdkPaths
    }
    #=================================================
    #   oscdimg.exe
    #=================================================
    $oscdimgexe = $WindowsAdkPaths.oscdimgexe
    Write-Verbose -Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] oscdimgexe: $oscdimgexe"
    #=================================================
    #   Bootable
    #=================================================
    $isBootable = $true
    $folderBoot = Join-Path $folderFullName 'boot'
    if (! (Test-Path $folderBoot)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName does not contain a Boot directory at $folderBoot"
        $isBootable = $false
    }
    $etfsbootcom = Join-Path $folderBoot 'etfsboot.com'
    if (! (Test-Path $etfsbootcom)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName is missing $etfsbootcom"
        $isBootable = $false
    }
    $folderEfiBoot = Join-Path $folderFullName 'efi\microsoft\boot'
    if (! (Test-Path $folderEfiBoot)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName does not contain a Boot directory at $folderEfiBoot"
        $isBootable = $false
    }
    $efisysbin = Join-Path $folderEfiBoot 'efisys.bin'
    if (! (Test-Path $efisysbin)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName is missing $efisysbin"
    }
    $efisysnopromptbin = Join-Path $folderEfiBoot 'efisys_noprompt.bin'
    if (! (Test-Path $efisysnopromptbin)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName is missing $efisysnopromptbin"
    }
    if ((Test-Path $efisysbin) -or (Test-Path $efisysnopromptbin)) {
        $isBootable = $true
    }
    else {
        $isBootable = $false
    }
    #=================================================
    #   Strings
    #=================================================
    $isoLabelString = '-l"{0}"' -f "$isoLabel"
    Write-Verbose -Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] isoLabelString: $isoLabelString"
    #=================================================
    #   Create ISO
    #=================================================
    if ($isBootable) {
        if (($noPrompt) -and (Test-Path $efisysnopromptbin)) {
            $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$etfsbootcom", "$efisysnopromptbin"
            Write-Verbose -Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] BootDataString: $BootDataString"
            $Process = Start-Process $oscdimgexe -args @('-m', '-o', '-u2', "-bootdata:$BootDataString", '-u2', '-udfver102', $isoLabelString, "`"$folderFullName`"", "`"$isoFullName`"") -PassThru -Wait -WindowStyle Hidden
        }
        else {
            $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$etfsbootcom", "$efisysbin"
            Write-Verbose -Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] BootDataString: $BootDataString"
            $Process = Start-Process $oscdimgexe -args @('-m', '-o', '-u2', "-bootdata:$BootDataString", '-u2', '-udfver102', $isoLabelString, "`"$folderFullName`"", "`"$isoFullName`"") -PassThru -Wait -WindowStyle Hidden
        }
    }
    else {
        $Process = Start-Process $oscdimgexe -args @('-m', '-o', '-u2', '-udfver102', $isoLabelString, "`"$folderFullName`"", "`"$isoFullName`"") -PassThru -Wait -WindowStyle Hidden
    }

    if (Test-Path $isoFullName) {
        Get-Item -Path $isoFullName
    }
    else {
        Write-Error "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] Something didn't work"
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] End"
    #=================================================
}
