function Update-OSDCloud.usb {
    [CmdletBinding()]
    param (
        [switch]$Mirror
    )
    #=================================================
    #	Block
    #=================================================
    Block-PowerShellVersionLt5
    Block-StandardUser
    #=================================================
    #	Build
    #=================================================
    $OSDCloudWorkspace = Get-OSDCloud.workspace

    if ($OSDCloudWorkspace){
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor DarkGray  "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace: $OSDCloudWorkspace"
        #=================================================
        #	Set Boot Labels
        #=================================================
        $UpdateBootLabel = Get-Volume.usb | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT')}
    
        foreach ($Item in $UpdateBootLabel) {
            Write-Host -ForegroundColor DarkGray "Setting NewFileSystemLabel to WinPE"
            Set-Volume -DriveLetter $Item.DriveLetter -NewFileSystemLabel 'WinPE' -ErrorAction Ignore
        }
        #=================================================
        #	WinPE
        #=================================================
        $WinpeVolume = (Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'WinPE'}).DriveLetter
    
        if ($WinpeVolume) {            
            if ($PSBoundParameters.ContainsKey('Mirror')) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring $OSDCloudWorkspace\Media to $($WinpeVolume):\"
                robocopy "$OSDCloudWorkspace\Media" "$($WinpeVolume):\" *.* /mir /ndl /np /njh /njs /b /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
            }
            else {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudWorkspace\Media to $($WinpeVolume):\"
                robocopy "$OSDCloudWorkspace\Media" "$($WinpeVolume):\" *.* /e /ndl /np /njh /njs /b /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
            }
        }
        #=================================================
        #	OSDCloud
        #=================================================
        $OSDCloud = (Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'}).DriveLetter
    
        if ($OSDCloud) {
            if ($PSBoundParameters.ContainsKey('Mirror')) {
                if (Test-Path "$OSDCloudWorkspace\Config") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring $OSDCloudWorkspace\Config to $($OSDCloud):\OSDCloud\Config"
                    robocopy "$OSDCloudWorkspace\Config" "$($OSDCloud):\OSDCloud\Config" *.* /mir /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
                
                if (Test-Path "$OSDCloudWorkspace\DriverPacks") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring $OSDCloudWorkspace\DriverPacks to $($OSDCloud):\OSDCloud\DriverPacks"
                    robocopy "$OSDCloudWorkspace\DriverPacks" "$($OSDCloud):\OSDCloud\DriverPacks" *.* /mir /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
                
                if (Test-Path "$OSDCloudWorkspace\OS") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring $OSDCloudWorkspace\OS to $($OSDCloud):\OSDCloud\OS"
                    robocopy "$OSDCloudWorkspace\OS" "$($OSDCloud):\OSDCloud\OS" *.* /mir /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
                
                if (Test-Path "$OSDCloudWorkspace\PowerShell") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring $OSDCloudWorkspace\PowerShell to $($OSDCloud):\OSDCloud\PowerShell"
                    robocopy "$OSDCloudWorkspace\PowerShell" "$($OSDCloud):\OSDCloud\PowerShell" *.* /mir /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }
            else {
                if (Test-Path "$OSDCloudWorkspace\Config") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudWorkspace\Config to $($OSDCloud):\OSDCloud\Config"
                    robocopy "$OSDCloudWorkspace\Config" "$($OSDCloud):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
                
                if (Test-Path "$OSDCloudWorkspace\DriverPacks") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudWorkspace\DriverPacks to $($OSDCloud):\OSDCloud\DriverPacks"
                    robocopy "$OSDCloudWorkspace\DriverPacks" "$($OSDCloud):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
                
                if (Test-Path (Join-Path $OSDCloudWorkspace 'OS')) {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudWorkspace\OS to $($OSDCloud):\OSDCloud\OS"
                    robocopy "$OSDCloudWorkspace\OS" "$($OSDCloud):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
                
                if (Test-Path "$OSDCloudWorkspace\PowerShell") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudWorkspace\PowerShell to $($OSDCloud):\OSDCloud\PowerShell"
                    robocopy "$OSDCloudWorkspace\PowerShell" "$($OSDCloud):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }
        }
        #=================================================
    }
    else {
        Write-Warning "Could not find the path to OSDCloud.workspace"
    }
    #=================================================
}