<#
.SYNOPSIS
Captures a PowerShell Screenshot

.DESCRIPTION
Captures a PowerShell Screenshot and saves the image in the -Directory $Env:TEMP\Screenshot by default

.LINK
https://osd.osdeploy.com/module/functions/general/get-screenpng

.NOTES
21.1.23 Initial Release

#>
function Get-ScreenPNG {
    [CmdletBinding()]
    param (
        #Directory where the Screenshots will be saved
        #Default = $Env:TEMP\Screenshots
        [string]$Directory = $null,

        #Saved files will have a Screenshot prefix in the filename
        [string]$Prefix = $null,

        #Delay before taking a Screenshot in seconds
        #Default: 0 (1 Count)
        #Default: 1 (>1 Count)
        [uint32]$Delay = 0,

        #Total number of Screenshots to capture
        #Default = 1
        [uint32]$Count = 1,

        #Additionally copies the Screenshot to the Clipboard
        [switch]$Clipboard = $false,

        #Screenshot of the Primary Display only
        [switch]$Primary = $false
    )
    begin {
        #=================================================
        #	Gather
        #=================================================
        $GetCommandNoun = Get-Command -Name Get-ScreenPNG | Select-Object -ExpandProperty Noun
        $GetCommandVersion = Get-Command -Name Get-ScreenPNG | Select-Object -ExpandProperty Version
        $GetCommandHelpUri = Get-Command -Name Get-ScreenPNG | Select-Object -ExpandProperty HelpUri
        $GetCommandModule = Get-Command -Name Get-ScreenPNG | Select-Object -ExpandProperty Module
        $GetModuleDescription = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty Description
        $GetModuleProjectUri = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty ProjectUri
        $GetModulePath = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty Path
        $MyPictures = (New-Object -ComObject Shell.Application).NameSpace('shell:My Pictures').Self.Path
        #=================================================
        #	Adjust Delay
        #=================================================
        if ($Count -gt '1') {if ($Delay -eq 0) {$Delay = 1}}
        #=================================================
        #	Determine Task Sequence
        #=================================================
        $LogPath = ''
        $SMSTSLogPath = ''
        try {
            $TSEnv = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction SilentlyContinue
            $IsTaskSequence = $true
            $LogPath = $TSEnv.Value('LogPath')
            $SMSTSLogPath = $TSEnv.Value('_SMSTSLogPath')
        }
        catch [System.Exception] {
            $IsTaskSequence = $false
            $LogPath = ''
            $SMSTSLogPath = ''
        }
        #=================================================
        #	Set AutoPath
        #=================================================
        if ($Directory -eq '') {
            if ($IsTaskSequence -and (Test-Path $LogPath)) {
                $AutoPath = Join-Path -Path $LogPath -ChildPath "Screenshots"
            } elseif ($IsTaskSequence -and (Test-Path $SMSTSLogPath)) {
                $AutoPath = Join-Path -Path $SMSTSLogPath -ChildPath "Screenshots"
            } elseif ($env:SystemDrive -eq 'X:') {
                $AutoPath = 'X:\Screenshots'
            } elseif (Test-Path $MyPictures) {
                $AutoPath = Join-Path -Path $MyPictures -ChildPath "Screenshots"
            } else {
                $AutoPath = "$Env:TEMP\Screenshots"
            }
        } else {
            $AutoPath = $Directory
        }
        #=================================================
        #	Usage
        #=================================================
        Write-Verbose '======================================================================================================'
        Write-Verbose "$GetCommandNoun $GetCommandVersion $GetCommandHelpUri"
        Write-Verbose $GetModuleDescription
        Write-Verbose "Module Path: $GetModulePath"
        Write-Verbose '======================================================================================================'
        Write-Verbose 'Get-ScreenPNG [[-Directory] <String>] [[-Prefix] <String>] [[-Delay] <UInt32>] [[-Count] <UInt32>] [-Clipboard] [-Primary]'
        Write-Verbose ''
        Write-Verbose '-Directory   Directory where the Screenshots will be saved'
        Write-Verbose '             If this value is not set, Path will be automatically set between the following:'
        Write-Verbose '             Defaults = [LogPath\Screenshots] [_SMSTSLogPath\Screenshots] [My Pictures\Screenshots] [$Env:TEMP\Screenshots]'
        Write-Verbose "             Value = $AutoPath"
        Write-Verbose ''
        $DateString = (Get-Date).ToString('yyyyMMdd_HHmmss')
        Write-Verbose "-Prefix      Pattern in the file name $($Prefix)_$($DateString).png"
        Write-Verbose "             Default = Screenshot"
        Write-Verbose "             Value = $Prefix"
        Write-Verbose ''
        Write-Verbose '-Count       Total number of Screenshots to capture'
        Write-Verbose '             Default = 1'
        Write-Verbose "             Value = $Count"
        Write-Verbose ''
        Write-Verbose '-Delay       Delay before capturing the Screenshots in seconds'
        Write-Verbose '             Default = 0 (Count = 1) | Default = 1 (Count > 1)'
        Write-Verbose "             Value = $Delay"
        Write-Verbose ''
        Write-Verbose '-Clipboard   Additionally copies the Screenshot to the Clipboard'
        Write-Verbose "             Value = $Clipboard"
        Write-Verbose ''
        Write-Verbose '-Primary     Captures Screenshot from the Primary Display only for Multiple Displays'
        Write-Verbose "             Value = $Primary"
        Write-Verbose '======================================================================================================'
        #=================================================
        #	Load Assemblies
        #=================================================
        Add-Type -Assembly System.Drawing
        Add-Type -Assembly System.Windows.Forms
        #=================================================
    }
    process {
        foreach ($i in 1..$Count) {
            #=================================================
            #	Determine Task Sequence (Process Block)
            #=================================================
            $LogPath = ''
            $SMSTSLogPath = ''
            try {
                $TSEnv = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction SilentlyContinue
                $IsTaskSequence = $true
                $LogPath = $TSEnv.Value('LogPath')
                $SMSTSLogPath = $TSEnv.Value('_SMSTSLogPath')
            }
            catch [System.Exception] {
                $IsTaskSequence = $false
                $LogPath = ''
                $SMSTSLogPath = ''
            }
            #=================================================
            #	Set AutoPath (Process Block)
            #=================================================
            $AutoPathBackup = $AutoPath
            if ($Directory -eq '') {
                if ($IsTaskSequence -and (Test-Path $LogPath)) {
                    $AutoPath = Join-Path -Path $LogPath -ChildPath "Screenshots"
                } elseif ($IsTaskSequence -and (Test-Path $SMSTSLogPath)) {
                    $AutoPath = Join-Path -Path $SMSTSLogPath -ChildPath "Screenshots"
                } elseif ($env:SystemDrive -eq 'X:') {
                    $AutoPath = 'X:\Screenshots'
                } elseif (Test-Path $MyPictures) {
                    $AutoPath = Join-Path -Path $MyPictures -ChildPath "Screenshots"
                } else {
                    $AutoPath = "$Env:TEMP\Screenshots"
                }
            } else {
                $AutoPath = $Directory
            }
            Write-Verbose "AutoPath is set to $AutoPath"
            #=================================================
            #	AutoPathBackup
            #=================================================
            if ($AutoPathBackup -ne $AutoPath) {
                #Path changed, so need to move the content from the previous AutoPath
            }
            #=================================================
            #	Determine AutoPath
            #=================================================
            if (!(Test-Path "$AutoPath")) {
                Write-Verbose "Creating snaScreenshot directory at $AutoPath"
                New-Item -Path "$AutoPath" -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
            #=================================================
            #	Delay
            #=================================================
            Write-Verbose "Delay $Delay Seconds"
            Start-Sleep -Seconds $Delay
            #=================================================
            #	Display Information
            #=================================================
            $GetDisplayAllScreens = @(Get-DisplayAllScreens)
            $GetDisplayVirtualScreen = Get-DisplayVirtualScreen
            #=================================================
            #	Display Number
            #=================================================
            foreach ($Device in $GetDisplayAllScreens) {
                #DateString
                $DateString = (Get-Date).ToString('yyyyMMdd_HHmmss')
                
                #DisplayNumber
                $DisplayNumber = $Device.DeviceName -Replace "[^0-9]"
                Write-Verbose "DisplayNumber: $DisplayNumber"

                #FileName
                if ($Prefix) {
                    $FileName = "$($Prefix)_$($DateString)"
                } else {
                    $FileName = "$($DateString)"
                }

                if ($GetDisplayAllScreens.Count -eq 1) {
                    $FileName = "$($FileName).png"
                } else {
                    $FileName = "$($FileName)_$($DisplayNumber).png"
                }

                if ($Device.Primary -eq $true) {
                    $GetDisplayPrimaryBitmapSize = Get-DisplayPrimaryBitmapSize
                    #Write-Verbose "Width: $($GetDisplayPrimaryBitmapSize.Width)" -Verbose
                    #Write-Verbose "Height: $($GetDisplayPrimaryBitmapSize.Height)" -Verbose
                    $ScreenshotBitmap = New-Object System.Drawing.Bitmap $GetDisplayPrimaryBitmapSize.Width, $GetDisplayPrimaryBitmapSize.Height
                    $ScreenshotGraphics = [System.Drawing.Graphics]::FromImage($ScreenShotBitmap)
                    #Write-Verbose "X: $($GetDisplayVirtualScreen.X)" -Verbose
                    #Write-Verbose "Y: $($GetDisplayVirtualScreen.Y)" -Verbose
                    #Write-Verbose "Size: $($GetDisplayVirtualScreen.Size)" -Verbose
                    $ScreenshotGraphics.CopyFromScreen($GetDisplayVirtualScreen.X, $GetDisplayVirtualScreen.Y, $GetDisplayVirtualScreen.X, $GetDisplayVirtualScreen.Y, $GetDisplayVirtualScreen.Size)
                    Write-Verbose "Saving Primary Screenshot $i of $Count to to $AutoPath\$FileName"
                }
                
                if ($Device.Primary -eq $false) {
                    if ($Primary -eq $true) {Continue}
                    Write-Verbose "Width: $($Device.Bounds.Width)" -Verbose
                    Write-Verbose "Height: $($Device.Bounds.Height)" -Verbose
                    $ScreenshotBitmap = New-Object System.Drawing.Bitmap $Device.Bounds.Width, $Device.Bounds.Height
                    $ScreenshotGraphics = [System.Drawing.Graphics]::FromImage($ScreenShotBitmap)
                    Write-Verbose "X: $($Device.Bounds.X)" -Verbose
                    Write-Verbose "Y: $($Device.Bounds.Y)" -Verbose
                    Write-Verbose "Size: $($GetDisplayVirtualScreen.Size)" -Verbose
                    $ScreenshotGraphics.CopyFromScreen($Device.Bounds.X, $Device.Bounds.Y, 0, 0, $GetDisplayVirtualScreen.Size)
                    Write-Verbose "Saving Secondary Screenshot $i of $Count to to $AutoPath\$FileName"
                }

                #=================================================
                #	Save the Screenshot to File
                #   https://docs.microsoft.com/en-us/dotnet/api/system.drawing.image.tag?view=dotnet-plat-ext-5.0
                #=================================================
                $ScreenshotBitmap.Save("$AutoPath\$FileName")

                #=================================================
                #	Copy the Screenshot to the Clipboard
                #   https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.clipboard.setimage?view=net-5.0
                #=================================================
                if ($Device.Primary -eq $true) {
                    if ($Clipboard) {
                        Write-Verbose "Copying Screenshot to the Clipboard"
                        #Add-Type -Assembly System.Drawing
                        #Add-Type -Assembly System.Windows.Forms
                        [System.Windows.Forms.Clipboard]::SetImage($ScreenshotBitmap)
                    }
                }
            }
            #=================================================
            #	Close
            #=================================================
            $ScreenshotGraphics.Dispose()
            $ScreenshotBitmap.Dispose()
            #=================================================
            #	Return Get-Item
            #=================================================
            Get-Item "$AutoPath\$FileName"
            #=================================================
        }
    }
    end {}
}
function Start-ScreenPNGProcess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory,

        [uint32]$Delay = 2,

        [uint32]$Count = 9999
    )

    $StartInfo = new-object System.Diagnostics.ProcessStartInfo
    $StartInfo.FileName = 'powershell.exe'
    $StartInfo.Arguments = "-NoExit -WindowStyle Hidden -Command Get-ScreenPNG -Directory $Directory -Count $Count -Delay $Delay"
    $Global:ScreenPNGPath = $Directory
    $Global:ScreenPNGProcess = ([System.Diagnostics.Process]::Start($StartInfo)).Id
}
function Stop-ScreenPNGProcess {
    [CmdletBinding()]
    param ()

    Stop-Process -Id $Global:ScreenPNGProcess -Force -ErrorAction SilentlyContinue
    $Global:ScreenPNGPath = $null
    $Global:ScreenPNGProcess = $null
}