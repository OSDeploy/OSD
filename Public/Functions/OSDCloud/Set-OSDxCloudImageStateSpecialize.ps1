function Set-OSDxCloudUnattendSpecialize {
    [CmdletBinding()]
    param ()
#=================================================
#	UnattendXml
#=================================================
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
	<settings pass="specialize">
		<component name="Microsoft-Windows-Deployment"
		           processorArchitecture="amd64"
		           publicKeyToken="31bf3856ad364e35"
		           language="neutral"
		           versionScope="nonSxS"
		           xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
		           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<RunSynchronous>
				<RunSynchronousCommand wcm:action="add">
					<Order>1</Order>
					<Description>OSDCloud Specialize</Description>
					<Path>Powershell -ExecutionPolicy Bypass -File C:\Windows\Panther\OSDCloudSpecialize.ps1</Path>
				</RunSynchronousCommand>
			</RunSynchronous>
		</component>
	</settings>
</unattend>
'@
#=================================================
#	Script
#=================================================
$OSDCloudSpecializeScript = @'
#=================================================
#   Specialize DriverPacks
#=================================================
Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Specialize Driver Pack Integration"
if (Test-Path 'C:\Drivers') {
    $DriverPacks = Get-ChildItem -Path 'C:\Drivers' -File

    foreach ($Item in $DriverPacks) {
        $ExpandFile = $Item.FullName
        Write-Verbose -Verbose "DriverPack: $ExpandFile"
        #=================================================
        #   Cab
        #=================================================
        if ($Item.Extension -eq '.cab') {
            $DestinationPath = Join-Path $Item.Directory $Item.BaseName

            if (-NOT (Test-Path "$DestinationPath")) {
                New-Item $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null

                Write-Verbose -Verbose "Expanding CAB Driver Pack to $DestinationPath"
                Expand -R "$ExpandFile" -F:* "$DestinationPath" | Out-Null

                if ($Apply) {
                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                    pnpunattend.exe AuditSystem /L
                    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                }
            }
            Continue
        }
        #=================================================
        #   HP
        #=================================================
        if ($Item.Extension -eq '.exe') {
            if (($Item.VersionInfo.InternalName -match 'hpsoftpaqwrapper') -or ($Item.VersionInfo.OriginalFilename -match 'hpsoftpaqwrapper.exe') -or ($Item.VersionInfo.FileDescription -like "HP *")) {
                Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                Write-Verbose -Verbose "InternalName: $($Item.VersionInfo.InternalName)"
                Write-Verbose -Verbose "OriginalFilename: $($Item.VersionInfo.OriginalFilename)"
                Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"
                
                $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                if (-NOT (Test-Path "$DestinationPath")) {
                    Write-Verbose -Verbose "Expanding HP Driver Pack to $DestinationPath"
                    Start-Process -FilePath $ExpandFile -ArgumentList "/s /e /f `"$DestinationPath`"" -Wait

                    if ($Apply) {
                        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                        pnpunattend.exe AuditSystem /L
                        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                    }
                }
                Continue
            }
        }
        #=================================================
        #   Lenovo
        #=================================================
        if ($Item.Extension -eq '.exe') {
            if ($Item.VersionInfo.FileDescription -match 'Lenovo') {
                Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"

                $DestinationPath = Join-Path $Item.Directory 'SCCM'

                if (-NOT (Test-Path "$DestinationPath")) {
                    Write-Verbose -Verbose "Expanding Lenovo Driver Pack to $DestinationPath"
                    Start-Process -FilePath $ExpandFile -ArgumentList "/SILENT /SUPPRESSMSGBOXES" -Wait

                    if ($Apply) {
                        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                        pnpunattend.exe AuditSystem /L
                        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                    }
                }
                Continue
            }
        }
        #=================================================
        #   MSI
        #=================================================
        if ($Item.Extension -eq '.msi') {
            $DateStamp = Get-Date -Format yyyyMMddTHHmmss
            $logFile = '{0}-{1}.log' -f $ExpandFile,$DateStamp
            $MSIArguments = @(
                "/i"
                ('"{0}"' -f $ExpandFile)
                "/qb"
                "/norestart"
                "/L*v"
                $logFile
            )
            Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
            Continue
        }
        #=================================================
        #   Zip
        #=================================================
        if ($Item.Extension -eq '.zip') {
            $DestinationPath = Join-Path $Item.Directory $Item.BaseName

            if (-NOT (Test-Path "$DestinationPath")) {
                Write-Verbose -Verbose "Expanding ZIP Driver Pack to $DestinationPath"
                Expand-Archive -Path $ExpandFile -DestinationPath $DestinationPath -Force
            
                if ($Apply) {
                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                    pnpunattend.exe AuditSystem /L
                    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                }
            }
            Continue
        }
        #=================================================
        #   Json
        #=================================================
        if ($Item.Extension -eq '.json') {
            #Do Nothing
            Continue
        }
        #=================================================
        #   TXT
        #=================================================
        if ($Item.Extension -eq '.txt') {
            #Do Nothing
            Continue
        }
        #=================================================
        #   Everything Else
        #=================================================
        Write-Warning "File cannot be expanded $ExpandFile"
        Write-Verbose -Verbose ""
        #=================================================
    }
}
#=================================================
#   Complete
#   Give a fair amount of time to display errors
#=================================================
Start-Sleep -Seconds 10
#=================================================
'@
    #=================================================
    #	Block
    #=================================================
    Block-WinOS
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #	Set Unattend
    #=================================================
    $Panther = 'C:\Windows\Panther'
    if (-NOT (Test-Path "$Panther\Unattend")) {
        New-Item -Path "$Panther\Unattend" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    $UnattendPath = "$Panther\Unattend\Unattend.xml"
    Write-Verbose "Setting $UnattendPath"
    $UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force
    #=================================================
    #	Set Script
    #=================================================
    $SpecializeScriptPath = "$Panther\OSDCloudSpecialize.ps1"
    Write-Verbose "Setting $SpecializeScriptPath"
    $OSDCloudSpecializeScript | Out-File -FilePath $SpecializeScriptPath -Encoding utf8 -Width 2000 -Force
    #=================================================
}