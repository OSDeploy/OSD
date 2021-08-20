function Use-WinPEContent {
    [CmdletBinding()]
    param (
        [ValidateSet('*','Drivers','Files','Modules','Registry','Scripts')]
        [string[]]$Content = '*'
    )
    #=================================================
    #	Blocks
    #=================================================
    Block-WinOS
    #=================================================
    #	PSDrive
    #=================================================
    $GetPSDrive = Get-PSDrive -PSProvider 'FileSystem'

    foreach ($Item in $Content) {
        #=================================================
        #	Drivers
        #=================================================
        if ($Item -eq '*' -or $Item -eq 'Drivers') {
            foreach ($PSDrive in $GetPSDrive) {
                $ContentPath = @("$($PSDrive.Root)Content\Drivers","$($PSDrive.Root)WinPE\Drivers")
                foreach ($ContentItem in $ContentPath) {
                    if (Test-Path "$ContentItem") {
                        Get-ChildItem "$ContentItem" *.inf -Recurse | `
                        ForEach-Object {
                            Write-Verbose "Importing Driver $($_.FullName)"
                            PNPUtil.exe /add-driver "$($_.FullName)" /install
                        }
                    }
                }
            }
        }
        #=================================================
        #	Files
        #=================================================
        if ($Item -eq '*' -or $Item -eq 'Files') {
            foreach ($PSDrive in $GetPSDrive) {
                $ContentPath = @("$($PSDrive.Root)Content\Files","$($PSDrive.Root)WinPE\Files")
                foreach ($ContentItem in $ContentPath) {
                    if (Test-Path "$ContentItem") {
                        Write-Verbose "Copying Files at $ContentItem to X:\"
                        robocopy "$ContentItem" X:\ *.* /e /ndl /b
                    }
                }
            }
        }
        #=================================================
        #	Modules
        #=================================================
        if ($Item -eq '*' -or $Item -eq 'Modules') {
            foreach ($PSDrive in $GetPSDrive) {
                $ContentPath = @("$($PSDrive.Root)Content\Modules","$($PSDrive.Root)WinPE\Modules")
                foreach ($ContentItem in $ContentPath) {
                    if (Test-Path "$ContentItem") {
                        Get-ChildItem "$ContentItem" | `
                        Where-Object {$_.PSIsContainer} | `
                        ForEach-Object {
                            Write-Verbose "Copying Module at $($_.FullName) to X:\Program Files\WindowsPowerShell\Modules"
                            Copy-Item -Path "$($_.FullName)" -Destination "X:\Program Files\WindowsPowerShell\Modules" -Recurse -Force -ErrorAction SilentlyContinue
                            Import-Module -Name "$($_.Name)" -Force -ErrorAction SilentlyContinue
                        }
                    }
                }
            }
        }
        #=================================================
        #	Registry
        #=================================================
        if ($Item -eq '*' -or $Item -eq 'Registry') {
            foreach ($PSDrive in $GetPSDrive) {
                $ContentPath = @("$($PSDrive.Root)Content\Registry","$($PSDrive.Root)WinPE\Registry")
                foreach ($ContentItem in $ContentPath) {
                    if (Test-Path "$ContentItem") {
                        Get-ChildItem "$ContentItem" *.reg -Recurse | `
                        ForEach-Object {
                            Write-Verbose "Importing Registry File $($_.FullName)"
                            reg import "$($_.FullName)"
                        }
                    }
                }
            }
        }
        #=================================================
        #	Scripts
        #=================================================
        if ($Item -eq '*' -or $Item -eq 'Scripts') {
            foreach ($PSDrive in $GetPSDrive) {
                $ContentPath = @("$($PSDrive.Root)Content\Scripts","$($PSDrive.Root)WinPE\Scripts")
                foreach ($ContentItem in $ContentPath) {
                    if (Test-Path "$ContentItem") {
                        Get-ChildItem "$ContentItem" *.ps1 -Recurse | `
                        ForEach-Object {
                            Write-Verbose "Executing PowerShell Script $($_.FullName)"
                            & "$($_.FullName)" -ErrorAction SilentlyContinue
                        }
                    }
                }
            }
        }
    }
}