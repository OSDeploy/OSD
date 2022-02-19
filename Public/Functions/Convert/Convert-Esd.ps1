function Convert-EsdToFolder {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]$esdFullName,
        [string]$folderFullName = $null
    )
    #=================================================
    #	Blocks
    #=================================================
    Block-StandardUser
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
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]$esdFullName,

        [string]$isoFullName = $null,

        [ValidateLength(1,16)]
        [string]$isoLabel = 'EsdToIso',

        [switch]$noPrompt,

        [switch]$Demo
    )
    #=================================================
    #	Blocks
    #=================================================
    Block-StandardUser
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
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]$esdFullName,
        [string]$wimFullName
    )
    #=================================================
    #	Blocks
    #=================================================
    Block-StandardUser
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