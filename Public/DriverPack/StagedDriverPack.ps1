function Enable-SpecializeDriverPack {
    [CmdletBinding()]
    param ()
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>Expand-StagedDriverPack</Description>
                    <Path>Powershell -ExecutionPolicy Bypass -Command Expand-StagedDriverPack</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
    </settings>
</unattend>
'@
    #=======================================================================
    #	Block
    #=======================================================================
    Block-WinOS
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5  
    #=======================================================================
    #	Set Unattend in the Registry
    #   HKEY_LOCAL_MACHINE\System\Setup\UnattendFile
    #   Specifies a pointer in the registry to an answer file
    #   The answer file is not required to be named Unattend.xml
    #   https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-automation-overview
    #=======================================================================  
    reg load HKLM\TempSYSTEM "C:\Windows\System32\Config\SYSTEM"
    reg add HKLM\TempSYSTEM\Setup /v UnattendFile /d "C:\Windows\Panther\Expand-StagedDriverPack.xml" /f
    reg unload HKLM\TempSYSTEM
    #=======================================================================
    #	Set Unattend
    #=======================================================================
    $UnattendXml | Out-File -FilePath "C:\Windows\Panther\Expand-StagedDriverPack.xml" -Encoding utf8 -Force
    #=======================================================================
}
function Expand-StagedDriverPack {
    [CmdletBinding()]
    param (
        [switch]$Apply
    )
    #=======================================================================
    #   Specialize
    #=======================================================================
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {
        $Apply = $true
        reg delete HKLM\System\Setup /v UnattendFile /f
    }
    #=======================================================================
    #   Specialize
    #=======================================================================
    if (Test-Path 'C:\Drivers') {
        $DriverPacks = Get-ChildItem -Path 'C:\Drivers' -File

        foreach ($Item in $DriverPacks) {
            $ExpandFile = $Item.FullName
            Write-Verbose -Verbose "DriverPack: $ExpandFile"
            #=======================================================================
            #   Cab
            #=======================================================================
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
            #=======================================================================
            #   HP
            #=======================================================================
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
            #=======================================================================
            #   Lenovo
            #=======================================================================
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
            #=======================================================================
            #   MSI
            #=======================================================================
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
            #=======================================================================
            #   Zip
            #=======================================================================
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
            #=======================================================================
            #   Everything Else
            #=======================================================================
            Write-Warning "Unable to expand $ExpandFile"
            Write-Verbose -Verbose ""
            #=======================================================================
        }
    }
}