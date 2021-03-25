function Save-MyDriverPack {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$DownloadPath = 'C:\Drivers',
        [switch]$Expand,
        [ValidateSet('Dell','HP','Lenovo')]
        [string]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [string]$Product = (Get-MyComputerProduct)
    )
    #=======================================================================
    #   Block
    #=======================================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    #=======================================================================
    #   Get-MyDriverPack
    #=======================================================================
    $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Manufacturer -Product $Product

    if ($GetMyDriverPack) {
        $GetMyDriverPack

        $DriverPackModel = $GetMyDriverPack.Model
        $DriverPackUrl = $GetMyDriverPack.DriverPackUrl
        $DriverPackFile = $DriverPackUrl | Split-Path -Leaf

        $Source = $DriverPackUrl
        $Destination = $DownloadPath
        $OutFile = Join-Path $Destination $DriverPackFile
        #=======================================================================
        #   Save-WebFile
        #=======================================================================
        if (-NOT (Test-Path "$Destination")) {
            New-Item $Destination -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        Write-Verbose -Verbose "Source: $Source"
        Write-Verbose -Verbose "Destination: $Destination"
        Write-Verbose -Verbose "OutFile: $OutFile"
        
        Save-WebFile -SourceUrl $DriverPackUrl -DestinationDirectory $DownloadPath -DestinationName $DriverPackFile
#=======================================================================
#	Set-DriverUnattend
#=======================================================================
#https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-deployment-runsynchronous
#https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-pnpcustomizationsnonwinpe-driverpaths-pathandcredentials
$DriverUnattend = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>OSDCloud Drivers</Description>
                    <Path>C:\Windows\Setup\Scripts\Drivers.cmd</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
    </settings>
</unattend>
'@
        #=======================================================================
        #   Expand
        #=======================================================================
        if (Test-Path $OutFile) {
            $GetItemOutFile = Get-Item $OutFile

            if ($PSBoundParameters.ContainsKey('Expand')) {
                if (($env:SystemDrive -eq 'X:') -and ($DownloadPath -eq 'C:\Drivers')) {
                    #=======================================================================
                    #	Set-DriverUnattend
                    #=======================================================================
                    if (-NOT (Test-Path 'C:\Windows\Panther')) {
                        New-Item -Path 'C:\Windows\Panther'-ItemType Directory -Force -ErrorAction Stop | Out-Null
                    }
                    if (-NOT (Test-Path 'C:\Windows\Setup\Scripts')) {
                        New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force -ErrorAction Stop | Out-Null
                    }
                    New-Item -Path 'C:\Windows\Setup\Scripts\Drivers.cmd' -Force
                    Add-Content -Path 'C:\Windows\Setup\Scripts\Drivers.cmd' -Value "@echo off" -Encoding ascii -Force
                    Add-Content -Path 'C:\Windows\Setup\Scripts\Drivers.cmd' -Value "echo OSDCloud C:\Windows\Setup\Scripts\Drivers.cmd" -Encoding ascii -Force
                    Add-Content -Path 'C:\Windows\Setup\Scripts\Drivers.cmd' -Value "@echo on" -Encoding ascii -Force

                    Write-Verbose -Verbose "Setting Driver Unattend at C:\Windows\Panther\Unattend.xml"
                    $DriverUnattend | Out-File -FilePath 'C:\Windows\Panther\Unattend.xml' -Encoding utf8
                    #=======================================================================
                }
                #=======================================================================
                #   Dell
                #=======================================================================
                if ($Manufacturer -match 'Dell') {
                    $ExpandPath = Join-Path $Destination $DriverPackModel
                    Write-Verbose -Verbose "Expanding $DriverPackFile to $ExpandPath"

                    if (Test-Path "$ExpandPath") {
                        Write-Verbose -Verbose "Removing existing $ExpandPath"
                        Remove-Item -Path $ExpandPath -Force -Recurse | Out-Null
                    }

                    if (-NOT (Test-Path "$ExpandPath")) {
                        New-Item $ExpandPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
                    }
                    
                    Expand -R "$($GetItemOutFile.FullName)" -F:* "$ExpandPath" | Out-Null
                }
                #=======================================================================
                #   HP
                #=======================================================================
                elseif ($Manufacturer -match 'HP') {
                    $ExpandPath = Join-Path $Destination $GetItemOutFile.BaseName

                    if (Test-Path "$ExpandPath") {
                        Write-Verbose -Verbose "Removing existing $ExpandPath"
                        Remove-Item -Path $ExpandPath -Force -Recurse | Out-Null
                    }

                    if (($env:SystemDrive -eq 'X:') -and ($DownloadPath -eq 'C:\Drivers')) {
                        Write-Warning "HP made the stupid decision to compress their Drivers in an EXE"
                        Write-Warning "Unfortunately the EXE requires a 32-Bit subsystem"
                        Write-Warning "At least they made it ZIP compatible, unlike Lenovo"
                        Write-Warning "i.e. The Driver will be installed in the Specialize Phase of Windows Setup"
                        Start-Sleep -Seconds 5
                        Add-Content -Path 'C:\Windows\Setup\Scripts\Drivers.cmd' -Value "`"$($GetItemOutFile.FullName)`" /s /e /f `"$ExpandPath`"" -Encoding ascii -Force
                    }
                    else {
                        Write-Verbose -Verbose "Expanding $DriverPackFile to $ExpandPath"
                        Start-Process -FilePath $GetItemOutFile.FullName -ArgumentList "/s /e /f `"$ExpandPath`"" -Wait
                    }
                }
                #=======================================================================
                #   Lenovo
                #=======================================================================
                elseif ($Manufacturer -match 'Lenovo') {
                    $ExpandPath = Join-Path $Destination 'SCCM'

                    if (Test-Path "$ExpandPath") {
                        Write-Verbose -Verbose "Removing existing $ExpandPath"
                        Remove-Item -Path $ExpandPath -Force -Recurse | Out-Null
                    }

                    if (($env:SystemDrive -eq 'X:') -and ($DownloadPath -eq 'C:\Drivers')) {
                        Write-Warning "Lenovo made the stupid decision to compress their Drivers in an EXE"
                        Write-Warning "The EXE is compressed with Inno Setup, which requires a 32-Bit subsystem"
                        Write-Warning "i.e. The Driver will be installed in the Specialize Phase of Windows Setup"
                        Start-Sleep -Seconds 5
                        Add-Content -Path 'C:\Windows\Setup\Scripts\Drivers.cmd' -Value "`"$($GetItemOutFile.FullName)`" /SILENT /SUPPRESSMSGBOXES" -Encoding ascii -Force
                    }
                    else {
                        Write-Verbose -Verbose "Expanding $DriverPackFile to $ExpandPath"
                        Start-Process -FilePath $GetItemOutFile.FullName -ArgumentList "/SILENT /SUPPRESSMSGBOXES" -Wait
                    }
                }
                #=======================================================================
                #   Unknown
                #=======================================================================
                else {
                    Write-Warning "I know you asked me to Expand this Driver Pack, but I'm not sure how"
                    Start-Sleep -Seconds 5
                }
                #=======================================================================
                #   WinPE
                #=======================================================================
                if (($env:SystemDrive -eq 'X:') -and ($DownloadPath -eq 'C:\Drivers')) {
                    #https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/pnpunattend
                    Add-Content -Path 'C:\Windows\Setup\Scripts\Drivers.cmd' -Value "reg add `"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1`" /v Path /t REG_SZ /d `"C:\Drivers`"" -Encoding ascii -Force
                    Add-Content -Path 'C:\Windows\Setup\Scripts\Drivers.cmd' -Value "C:\Windows\System32\pnpunattend.exe AuditSystem /L" -Encoding ascii -Force
                    Add-Content -Path 'C:\Windows\Setup\Scripts\Drivers.cmd' -Value "exit 0" -Encoding ascii -Force
                }
            }
        }
        else {
            Write-Warning "Unable to download the Driver Cab"
            $null
        }
    }
}