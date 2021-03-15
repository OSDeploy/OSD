function New-OSDCloudWinPE {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$BuildDirectory = (Join-Path $env:TEMP (Get-Random))
    )
    begin {
        #======================================================================================================
        #	Require WinOS
        #======================================================================================================
        if ((Get-OSDGather -Property IsWinPE)) {
            Write-Warning "$($MyInvocation.MyCommand) cannot be run from WinPE"
            Break
        }
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #===================================================================================================
        #   Require cURL
        #===================================================================================================
        if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
            Write-Warning "$($MyInvocation.MyCommand) could not find $env:SystemRoot\System32\curl.exe"
            Write-Warning "Get a newer Windows version!"
            Break
        }
        #===================================================================================================
        #   Get Variables
        #===================================================================================================
        $WinPEArch = 'amd64'
        $GetMyAdk = Get-MyAdk -Arch $WinPEArch

        if ($null -eq $GetMyAdk) {
            Write-Warning "Could not get ADK going, sorry"
            Break
        }
        #===================================================================================================
    }
    process {
        $ADKWinpeWim = Join-Path $GetMyAdk.PathWinPE 'en-us\winpe.wim'
        if (-NOT (Test-Path $ADKWinpeWim)) {
            Write-Warning "Could not find $ADKWinpeWim, sorry"
            Break
        }

        $ADKMedia = $GetMyAdk.PathWinPEMedia
        $DestinationMedia = Join-Path $BuildDirectory 'Media'
        Write-Verbose "Copying ADK Media to $DestinationMedia" -Verbose
        robocopy "$ADKMedia" "$DestinationMedia" *.* /e /ndl /xj /ndl /np /nfl /njh /njs

        $DestinationSources = Join-Path $DestinationMedia 'sources'
        if (-NOT (Test-Path "$DestinationSources")) {
            New-Item -Path "$DestinationSources" -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        $BootWim = Join-Path $DestinationSources 'boot.wim'
        Write-Verbose "Copying ADK Boot.wim to $BootWim" -Verbose
        Copy-Item -Path $ADKWinpeWim -Destination $BootWim -Force

        Write-Verbose "Mounting $BootWim" -Verbose
        $MountMyWindowsImage = Mount-MyWindowsImage $BootWim
        $MountPath = $MountMyWindowsImage.Path
        
        Write-Verbose "Adding ADK Packages to Mounted boot.wim at $MountPath" -Verbose
        $ADKPackages = Join-Path $GetMyAdk.PathWinPE 'WinPE_OCs'

        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-WMI.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-WMI_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-HTA.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-HTA_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-NetFx.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-NetFx_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-Scripting.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-Scripting_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-PowerShell.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-PowerShell_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-SecureStartup.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-SecureStartup_en-us.cab"

        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-DismCmdlets.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-DismCmdlets_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-Dot3Svc.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-Dot3Svc_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-EnhancedStorage.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-EnhancedStorage_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-FMAPI.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-GamingPeripherals.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-PPPoE.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-PPPoE_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-PlatformId.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-PmemCmdlets.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-PmemCmdlets_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-RNDIS.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-RNDIS_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-SecureBootCmdlets.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-StorageWMI.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-StorageWMI_en-us.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\WinPE-WDS-Tools.cab"
        Add-WindowsPackage -Path $MountPath -PackagePath "$ADKPackages\en-us\WinPE-WDS-Tools_en-us.cab"

        Write-Verbose "Adding curl.exe and tar.exe to $MountPath" -Verbose
        if (Test-Path "$env:SystemRoot\System32\curl.exe") {
            robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" curl.exe /ndl /nfl /njh /njs /b
            robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" tar.exe /ndl /nfl /njh /njs /b
        } else {
            Write-Warning "Could not find $env:SystemRoot\System32\curl.exe"
            Write-Warning "You must be using an old version of Windows"
            Write-Warning "OSDCloud won't work without curl.exe so you have been warned!"
        }

        Write-Verbose "Setting PowerShell ExecutionPolicy to Bypass in $MountPath" -Verbose
        Set-WindowsImageExecutionPolicy -Path $MountPath -ExecutionPolicy Bypass
        
        Write-Verbose "Enabling PowerShell Gallery support in $MountPath" -Verbose
        Enable-PEWindowsImagePSGallery -Path $MountPath

        Write-Verbose "Adding PowerShell.exe to Startnet.cmd" -Verbose
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start powershell.exe' -Force

        Write-Verbose "Saving Boot.wim" -Verbose
        $MountMyWindowsImage | Dismount-MyWindowsImage -Save

        $ISOLabel = '-l"{0}"' -f "OSDCloud"

        $ISOFile = Join-Path $BuildDirectory 'OSDCloud.iso'
        Write-Verbose "ISOFile: $ISOFile"

        $OSCDIMG = $GetMyAdk.PathOscdimg
        Write-Verbose "OSCDIMG: $OSCDIMG"

        $OSCDIMGexe = Join-Path $OSCDIMG 'oscdimg.exe'
        Write-Verbose "OSCDIMGexe: $OSCDIMGexe"

        robocopy "$OSCDIMG" "$DestinationMedia\boot" etfsboot.com /ndl /nfl /njh /njs /b
        $etfsboot = "$DestinationMedia\boot\etfsboot.com"
        Write-Verbose "etfsboot: $etfsboot"

        robocopy "$OSCDIMG" "$DestinationMedia\efi\microsoft\boot" efisys.bin /ndl /nfl /njh /njs /b
        $efisys = "$DestinationMedia\efi\microsoft\boot\efisys.bin"
        Write-Verbose "efisys: $efisys"
        #$efisys = "$DestinationMedia\efi\microsoft\boot\efisys.bin"

        $data = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f $etfsboot, $efisys
        Write-Verbose "data: $data"

        Write-Verbose "Creating ISO at $ISOFile" -Verbose
        Start-Process $OSCDIMGexe -args @("-m","-o","-u2","-bootdata:$data",'-u2','-udfver102',$ISOLabel,"`"$DestinationMedia`"", "`"$ISOFile`"") -Wait
        explorer $BuildDirectory
    }
    end {}
}