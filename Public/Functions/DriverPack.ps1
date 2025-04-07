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
    #=================================================
    #	Block
    #=================================================
    Block-WinOS
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5  
    #=================================================
    #	Set Unattend in the Registry
    #   HKEY_LOCAL_MACHINE\System\Setup\UnattendFile
    #   Specifies a pointer in the registry to an answer file
    #   The answer file is not required to be named Unattend.xml
    #   https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-automation-overview
    #=================================================  
    reg load HKLM\TempSYSTEM "C:\Windows\System32\Config\SYSTEM"
    reg add HKLM\TempSYSTEM\Setup /v UnattendFile /d "C:\Windows\Panther\Expand-StagedDriverPack.xml" /f
    reg unload HKLM\TempSYSTEM
    #=================================================
    #	Set Unattend
    #=================================================
    $UnattendXml | Out-File -FilePath "C:\Windows\Panther\Expand-StagedDriverPack.xml" -Encoding utf8 -Width 2000 -Force
    #=================================================
}
function Expand-StagedDriverPack {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Apply
    )
    #=================================================
    #   Specialize
    #=================================================
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {
        $Apply = $true
        reg delete HKLM\System\Setup /v UnattendFile /f
    }
    #=================================================
    #   Specialize
    #=================================================
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
            #   Dell
            #=================================================
            if ($Item.Extension -eq '.exe') {
                if ($Item.VersionInfo.FileDescription -match 'Dell') {
                    Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                    Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"

                    $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                    if (-NOT (Test-Path "$DestinationPath")) {
                        Write-Verbose -Verbose "Expanding Dell Driver Pack to $DestinationPath"
                        $null = New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
                        Start-Process -FilePath $ExpandFile -ArgumentList "/s /e=`"$DestinationPath`"" -Wait

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
                if (($Item.VersionInfo.FileDescription -match 'Lenovo') -or ($Item.Name -match 'tc_') -or ($Item.Name -match 'tp_') -or ($Item.Name -match 'ts_') -or ($Item.Name -match '500w') -or ($Item.Name -match 'sccm_') -or ($Item.Name -match 'm710e') -or ($Item.Name -match 'tp10') -or ($Item.Name -match 'tp8') -or ($Item.Name -match 'yoga')) {
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
            #   Everything Else
            #=================================================
            Write-Warning "Unable to expand $ExpandFile"
            Write-Verbose -Verbose ""
            #=================================================
        }
    }
}
function Expand-ZTIDriverPack {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Set some Variables
    #=================================================
    $OSDiskDrivers = 'C:\Drivers'
    #=================================================
    #	Create $OSDiskDrivers
    #=================================================
    if (-NOT (Test-Path -Path $OSDiskDrivers)) {
        Write-Warning "Could not find $OSDiskDrivers"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	Start-Transcript
    #=================================================
    Start-Transcript -OutputDirectory $OSDiskDrivers
    #=================================================
    #   Expand
    #=================================================
    $DriverPacks = Get-ChildItem -Path $OSDiskDrivers -File

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

                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                pnpunattend.exe AuditSystem /L
                Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
            }
            Continue
        }
        #=================================================
        #   Dell
        #=================================================
        if ($Item.Extension -eq '.exe') {
            if ($Item.VersionInfo.FileDescription -match 'Dell') {
                Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"

                $DestinationPath = Join-Path $Item.Directory $Item.BaseName

                if (-NOT (Test-Path "$DestinationPath")) {
                    Write-Verbose -Verbose "Expanding Dell Driver Pack to $DestinationPath"
                    $null = New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
                    Start-Process -FilePath $ExpandFile -ArgumentList "/s /e=`"$DestinationPath`"" -Wait

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

                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                    pnpunattend.exe AuditSystem /L
                    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
                }
                Continue
            }
        }
        #=================================================
        #   Lenovo
        #=================================================
        if ($Item.Extension -eq '.exe') {
            if (($Item.VersionInfo.FileDescription -match 'Lenovo') -or ($Item.Name -match 'tc_') -or ($Item.Name -match 'tp_') -or ($Item.Name -match 'ts_') -or ($Item.Name -match '500w') -or ($Item.Name -match 'sccm_') -or ($Item.Name -match 'm710e') -or ($Item.Name -match 'tp10') -or ($Item.Name -match 'tp8') -or ($Item.Name -match 'yoga')) {
                Write-Verbose -Verbose "FileDescription: $($Item.VersionInfo.FileDescription)"
                Write-Verbose -Verbose "ProductVersion: $($Item.VersionInfo.ProductVersion)"

                $DestinationPath = Join-Path $Item.Directory 'SCCM'

                if (-NOT (Test-Path "$DestinationPath")) {
                    Write-Verbose -Verbose "Expanding Lenovo Driver Pack to $DestinationPath"
                    Start-Process -FilePath $ExpandFile -ArgumentList "/SILENT /SUPPRESSMSGBOXES" -Wait

                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                    pnpunattend.exe AuditSystem /L
                    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
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
            
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths" -Name 1 -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Name Path -Value $DestinationPath -Force
                pnpunattend.exe AuditSystem /L
                Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" -Recurse -Force
            }
            Continue
        }
        #=================================================
        #   Everything Else
        #=================================================
        Write-Warning "Unable to expand $ExpandFile"
        #=================================================
    }
}
function Get-MyDriverPack {
    [CmdletBinding()]
    param (
        [System.String]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [System.String]$Product = (Get-MyComputerProduct)
    )
    #=================================================
    #   Set ErrorActionPreference
    #=================================================
    $ErrorActionPreference = 'SilentlyContinue'
    #=================================================
    #   Action
    #=================================================
    $Results = Get-OSDCloudDriverPacks | Where-Object {($_.Product -contains $Product)}
    #=================================================
    #   Results
    #=================================================
    if ($Results) {
        $Results = $Results | Sort-Object -Property Name -Descending
        $Results[0]
    }
    else {
        Write-Verbose "$Manufacturer $Product is not supported"
    }
    #=================================================
}
function Save-MyDriverPack {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.String]$DownloadPath = 'C:\Drivers',
        [System.Management.Automation.SwitchParameter]$Expand,
        [System.String]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [System.String]$Product = (Get-MyComputerProduct),
        [System.String]
        $Guid
    )
    Write-Verbose "Manufacturer: $Manufacturer"
    Write-Verbose "Product: $Product"
    #=================================================
    #   Block
    #=================================================
    if ($Expand) {
        Block-StandardUser
    }
    Block-WindowsVersionNe10
    #=================================================
    #   Get-MyDriverPack
    #=================================================
    if ($Guid) {
        $GetMyDriverPack = Get-OSDCloudDriverPacks | Where-Object {$_.Guid -eq $Guid} | Select-Object -First 1
    }
    else {
        $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Manufacturer -Product $Product
    }

    if ($GetMyDriverPack) {
        $OutFile = Join-Path $DownloadPath $GetMyDriverPack.FileName
        #=================================================
        #   Save-WebFile
        #=================================================
        if (-NOT (Test-Path "$DownloadPath")) {
            New-Item $DownloadPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        Write-Verbose -Message "CatalogVersion: $($GetMyDriverPack.CatalogVersion)"
        Write-Verbose -Message "Name: $($GetMyDriverPack.Name)"
        Write-Verbose -Message "Product: $($GetMyDriverPack.Product)"
        Write-Verbose -Message "Url: $($GetMyDriverPack.Url)"
        Write-Verbose -Message "OutFile: $OutFile"
        
        Save-WebFile -SourceUrl $GetMyDriverPack.Url -DestinationDirectory $DownloadPath -DestinationName $GetMyDriverPack.FileName

        if (! (Test-Path $OutFile)) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Driver Pack failed to download"
        }
        else {
            $GetItemOutFile = Get-Item $OutFile
        }
        $GetMyDriverPack | ConvertTo-Json | Out-File "$OutFile.json" -Encoding ascii -Width 2000 -Force
        #=================================================
        #   Expand
        #=================================================
        if ($GetItemOutFile) {
            if ($PSBoundParameters.ContainsKey('Expand')) {
    
                $ExpandFile = $GetItemOutFile.FullName
                Write-Verbose -Message "DriverPack: $ExpandFile"
                #=================================================
                #   Cab
                #=================================================
                if ($GetItemOutFile.Extension -eq '.cab') {
                    $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
        
                    if (-NOT (Test-Path "$DestinationPath")) {
                        New-Item $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    
                        Write-Verbose -Verbose "Expanding CAB Driver Pack to $DestinationPath"
                        Expand -R "$ExpandFile" -F:* "$DestinationPath" | Out-Null
                    }
                }
                #=================================================
                #   Dell
                #=================================================
                if ($GetItemOutFile.Extension -eq '.exe') {
                    if ($GetItemOutFile.VersionInfo.FileDescription -match 'Dell') {
                        Write-Verbose -Verbose "FileDescription: $($GetItemOutFile.VersionInfo.FileDescription)"
                        Write-Verbose -Verbose "ProductVersion: $($GetItemOutFile.VersionInfo.ProductVersion)"
    
                        $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
    
                        if (-NOT (Test-Path "$DestinationPath")) {
                            Write-Verbose -Verbose "Expanding Dell Driver Pack to $DestinationPath"
                            $null = New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
                            Start-Process -FilePath $ExpandFile -ArgumentList "/s /e=`"$DestinationPath`"" -Wait
                        }
                    }
                }
                #=================================================
                #   HP
                #=================================================
                if (($GetItemOutFile.Extension -eq '.exe') -and ($env:SystemDrive -ne 'X:')) {
                    if (($GetItemOutFile.VersionInfo.InternalName -match 'hpsoftpaqwrapper') -or ($GetItemOutFile.VersionInfo.OriginalFilename -match 'hpsoftpaqwrapper.exe') -or ($GetItemOutFile.VersionInfo.FileDescription -like "HP *")) {
                        Write-Verbose -Message "FileDescription: $($GetItemOutFile.VersionInfo.FileDescription)"
                        Write-Verbose -Message "InternalName: $($GetItemOutFile.VersionInfo.InternalName)"
                        Write-Verbose -Message "OriginalFilename: $($GetItemOutFile.VersionInfo.OriginalFilename)"
                        Write-Verbose -Message "ProductVersion: $($GetItemOutFile.VersionInfo.ProductVersion)"
                        
                        $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
    
                        if (-NOT (Test-Path "$DestinationPath")) {
                            Write-Verbose -Verbose "Expanding HP Driver Pack to $DestinationPath"
                            Start-Process -FilePath $ExpandFile -ArgumentList "/s /e /f `"$DestinationPath`"" -Wait
                        }
                    }
                }
                #=================================================
                #   Lenovo
                #=================================================
                if (($GetItemOutFile.Extension -eq '.exe') -and ($env:SystemDrive -ne 'X:')) {
                    if (($GetItemOutFile.VersionInfo.FileDescription -match 'Lenovo') -or ($GetItemOutFile.Name -match 'tc_') -or ($GetItemOutFile.Name -match 'tp_') -or ($GetItemOutFile.Name -match 'ts_') -or ($GetItemOutFile.Name -match '500w') -or ($GetItemOutFile.Name -match 'sccm_') -or ($GetItemOutFile.Name -match 'm710e') -or ($GetItemOutFile.Name -match 'tp10') -or ($GetItemOutFile.Name -match 'tp8') -or ($GetItemOutFile.Name -match 'yoga')) {
                        Write-Verbose -Message "FileDescription: $($GetItemOutFile.VersionInfo.FileDescription)"
                        Write-Verbose -Message "ProductVersion: $($GetItemOutFile.VersionInfo.ProductVersion)"
    
                        $DestinationPath = Join-Path $GetItemOutFile.Directory 'SCCM'
    
                        if (-NOT (Test-Path "$DestinationPath")) {
                            Write-Verbose -Verbose "Expanding Lenovo Driver Pack to $DestinationPath"
                            Start-Process -FilePath $ExpandFile -ArgumentList "/SILENT /SUPPRESSMSGBOXES" -Wait
                        }
                    }
                }
                #=================================================
                #   MSI
                #=================================================
                if (($GetItemOutFile.Extension -eq '.msi') -and ($env:SystemDrive -ne 'X:')) {
                    $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
    
                    if (-NOT (Test-Path "$DestinationPath")) {
                        #Need to sort out what to do here
                    }
                }
                #=================================================
                #   Zip
                #=================================================
                if ($GetItemOutFile.Extension -eq '.zip') {
                    $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
    
                    if (-NOT (Test-Path "$DestinationPath")) {
                        Write-Verbose -Verbose "Expanding ZIP Driver Pack to $DestinationPath"
                        Expand-Archive -Path $ExpandFile -DestinationPath $DestinationPath -Force
                    }
                }
                #=================================================
                #   Everything Else
                #=================================================
                #Write-Warning "Unable to expand $ExpandFile"
            }
        }
    }
}
function Save-ZTIDriverPack {
    [CmdletBinding()]
    param (
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )
    #=================================================
    #	Make sure we are running in a Task Sequence first
    #=================================================
    try {
        $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    }
    catch {
        $TSEnv = $false
    }

    if ($TSEnv -eq $false) {
        Write-Warning "This functions requires a running Task Sequence"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	Get some Task Sequence variables
    #=================================================
    $DEPLOYROOT = $TSEnv.Value("DEPLOYROOT")
    $DEPLOYDRIVE = $TSEnv.Value("DEPLOYDRIVE") # Z:
    $OSVERSION = $TSEnv.Value("OSVERSION") # WinPE
    $RESOURCEDRIVE = $TSEnv.Value("RESOURCEDRIVE") # Z:
    $OSDISK = $TSEnv.Value("OSDISK") # E:
    $OSDANSWERFILEPATH = $TSEnv.Value("OSDANSWERFILEPATH") # E:\MININT\Unattend.xml
    $TARGETPARTITIONIDENTIFIER = $TSEnv.Value("TARGETPARTITIONIDENTIFIER") # [SELECT * FROM Win32_LogicalDisk WHERE Size = '134343553024' and VolumeName = 'Windows' and VolumeSerialNumber = '90D39B87']
    #=================================================
    #	Set some Variables
    #   DeployRootDriverPacks are where DriverPacks must be staged
    #   This is not working out so great at the moment, so I would suggest
    #   not doing this yet
    #=================================================
    $DeployRootDriverPacks = Join-Path $DEPLOYROOT 'DriverPacks'
    $OSDiskDrivers = Join-Path $OSDISK 'Drivers'
    #=================================================
    #	Create $OSDiskDrivers
    #=================================================
    if (-NOT (Test-Path -Path $OSDiskDrivers)) {
        New-Item -Path $OSDiskDrivers -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }
    if (-NOT (Test-Path -Path $OSDiskDrivers)) {
        Write-Warning "Could not create $OSDiskDrivers"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	Start-Transcript
    #=================================================
    Start-Transcript -OutputDirectory $OSDiskDrivers
    #=================================================
    #	Copy-PSModuleToFolder
    #   The OSD Module needs to be available on the next boot for Specialize
    #   Drivers to work
    #=================================================
    if ($env:SystemDrive -eq 'X:') {
        Copy-PSModuleToFolder -Name OSD -Destination "$OSDISK\Program Files\WindowsPowerShell\Modules"
        Copy-PSModuleToFolder -Name OSD.Catalogs -Destination "$OSDISK\Program Files\WindowsPowerShell\Modules"
    }
    #=================================================
    #	Get-MyDriverPack
    #=================================================
    Write-Verbose -Verbose "Processing function Get-MyDriverPack"
    if ($Manufacturer -in ('Dell','HP','Lenovo','Microsoft')) {
        $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Manufacturer -Product $Product
    }
    else {
        $GetMyDriverPack = Get-MyDriverPack -Product $Product
    }
    if (-NOT ($GetMyDriverPack)) {
        Write-Warning "There are no DriverPacks for this computer"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	Get-MyDriverPack
    #=================================================
    Write-Verbose -Verbose "Name: $($GetMyDriverPack.Name)"
    Write-Verbose -Verbose "Product: $($GetMyDriverPack.Product)"
    Write-Verbose -Verbose "FileName: $($GetMyDriverPack.FileName)"
    Write-Verbose -Verbose "Url: $($GetMyDriverPack.Url)"
    $OSDiskDriversFile = Join-Path $OSDiskDrivers $GetMyDriverPack.FileName
    #=================================================
    #	MDT DeployRoot DriverPacks
    #   See if the DriverPack we need exists in $DeployRootDriverPacks
    #=================================================
    $DeployRootDriverPack = @()
    $DeployRootDriverPack = Get-ChildItem "$DeployRootDriverPacks\" -Include $GetMyDriverPack.FileName -File -Recurse -Force -ErrorAction Ignore | Select-Object -First 1
    if ($DeployRootDriverPack) {
        Write-Verbose -Verbose "Source: $($DeployRootDriverPack.FullName)"
        Write-Verbose -Verbose "Destination: $OSDiskDriversFile"
        Copy-Item -Path $($DeployRootDriverPack.FullName) -Destination $OSDiskDrivers -Force
    }

    if (Test-Path $OSDiskDriversFile) {
        Write-Verbose -Verbose "DriverPack is in place and ready to go"
        Stop-Transcript
        Continue
    }
    #=================================================
    #	Curl
    #   Make sure Curl is available
    #=================================================
    if ((-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) -and (-NOT (Test-Path "$OSDISK\Windows\System32\curl.exe"))) {
        Write-Warning "Curl is required for this to function"
        Start-Sleep -Seconds 5
        Continue
    }
    if ((-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) -and (Test-Path "$OSDISK\Windows\System32\curl.exe")) {
        Copy-Item -Path "$OSDISK\Windows\System32\curl.exe" -Destination "$env:SystemRoot\System32\curl.exe" -Force
    }

    if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
        Write-Warning "Curl is required for this to function"
        Start-Sleep -Seconds 5
        Continue
    }
    #=================================================
    #	OSDCloud DriverPacks
    #   Finally, let's download the file and see where this goes
    #=================================================
    Save-WebFile -SourceUrl $GetMyDriverPack.Url -DestinationDirectory $OSDiskDrivers -DestinationName $GetMyDriverPack.FileName

    if (Test-Path $OSDiskDriversFile) {
        Write-Verbose -Verbose "DriverPack is in place and ready to go"
        Stop-Transcript
    }
    else {
        Write-Warning "Could not download the DriverPack.  Sorry!"
        Stop-Transcript
    }
    #=================================================
}
