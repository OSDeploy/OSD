<#
.LINK
    https://www.osdeploy.com
.SYNOPSIS
    Creates a Bootable FAT32 USB (32GB or smaller) and copies a Mounted ISO.
.DESCRIPTION
    Creates a Bootable FAT32 USB (32GB or smaller) and copies a Mounted ISO.
.PARAMETER ISOFile
    Full path to the ISO file to Mount
.PARAMETER MakeBootable
    Uses Bootsect to make the USB Bootable
.PARAMETER USBDriveLabel
    USB Drive Label (no spaces)
.EXAMPLE
    Copy-IsoToUsb -ISOFile "C:\Temp\SW_DVD5_Win_Pro_Ent_Edu_N_10_1709_64BIT_English_MLF_X21-50143.ISO" -MakeBootable -USBDriveLabel WIN10X64
    You will be prompted to select a USB Drive in GridView
.NOTES
    NAME:	Copy-IsoToUsb.ps1
    AUTHOR:	David Segura, david@segura.org
    BLOG:	http://www.osdeploy.com
    VERSION:	18.9.4
            
    Original credit to Mike Robbins
    http://mikefrobbins.com/2018/01/18/use-powershell-to-create-a-bootable-usb-drive-from-a-windows-10-or-windows-server-2016-iso/
    
    Additional credit to Sergey Tkachenko
    https://winaero.com/blog/powershell-windows-10-bootable-usb/
#>

function Copy-IsoToUsb {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq '.iso')})]
        [string]$ISOFile,
        [System.Management.Automation.SwitchParameter]$MakeBootable,
        [System.Management.Automation.SwitchParameter]$NTFS,
        [System.Management.Automation.SwitchParameter]$SplitWim,
        [string]$USBLabel
    )
    BEGIN {
        #=================================================
        Write-Verbose "Validating Elevated Permissions ..."
        #=================================================
        $Elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if ( -not $Elevated ) {
            Throw "This Function requires Elevation"
        }
    }
    
    PROCESS {
        #=================================================
        Write-Verbose "Selecting USB Drive ..."
        #=================================================
        if ($NTFS) {
            $Results = Get-Disk | Where-Object {$_.Size/1GB -lt 33 -and $_.BusType -eq 'USB'} | Out-GridView -Title 'Select USB Drive to Format' -OutputMode Single | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false -PassThru | New-Partition -UseMaximumSize -IsActive -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel $USBLabel
        } else {
            $Results = Get-Disk | Where-Object {$_.Size/1GB -lt 33 -and $_.BusType -eq 'USB'} | Out-GridView -Title 'Select USB Drive to Format' -OutputMode Single | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false -PassThru | New-Partition -UseMaximumSize -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel $USBLabel
        }
        
        #=================================================
        Write-Verbose "Validating a USB Drive was Selected ..."
        #=================================================
        if($null -eq $Results) {
            Throw "No USB Driver was Found or Selected"
        }

        #=================================================
        Write-Verbose "Getting Volumes ..."
        #=================================================
        $Volumes = (Get-Volume).Where({$_.DriveLetter}).DriveLetter
        
        #=================================================
        Write-Verbose "Mounting the ISO ..."
        #=================================================
        Mount-DiskImage -ImagePath $ISOFile
        
        #=================================================
        Write-Verbose "Waiting 5 Seconds ..."
        #=================================================
        Start-Sleep -s 5
        
        #=================================================
        Write-Verbose "Detemrining the Drive Letter of the Mounted ISO ..."
        #=================================================
        $ISO = (Compare-Object -ReferenceObject $Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject
        
        #=================================================
        Write-Verbose "Making the USB Drive Botoable ..."
        #=================================================
        if ($MakeBootable.IsPresent) {
            Set-Location -Path "$($ISO):\boot"
            bootsect.exe /nt60 "$($Results.DriveLetter):"	
        }
        
        #=================================================
        Write-Verbose "Set SplitWim"
        #=================================================
        if (! ($NTFS.IsPresent)) {
            if (Test-Path "$($ISO):\sources\install.wim") {
                if ((Get-Item "$($ISO):\sources\install.wim").length -gt 4gb) {
                    Write-Verbose "Split-WindowsImage: True"
                    $SplitWim = $true
                }
            }
        }

        #=================================================
        Write-Verbose "Copying Files ..."
        #=================================================
        if ($SplitWim.IsPresent) {
            Copy-Item -Path "$($ISO):\*" -Exclude install.wim -Destination "$($Results.DriveLetter):" -Recurse -Verbose

            if (Test-Path "$($ISO):\sources\install.wim") {
                $WimTemp = "$((Get-Date).ToString('HHmmss'))"

                if (Test-Path "$env:TEMP\$WimTemp") {Remove-Item -Path "$env:TEMP\$WimTemp" -Force | Out-Null}
                New-Item -Path "$env:TEMP\$WimTemp" -ItemType Directory -Force | Out-Null

                Write-Host "Copying $($ISO):\sources\install.wim to $env:TEMP\$WimTemp\install.wim" -ForegroundColor Green
                Copy-Item -Path "$($ISO):\sources\install.wim" -Destination "$env:TEMP\$WimTemp\install.wim" -Verbose

                Set-ItemProperty -Path "$env:TEMP\$WimTemp\install.wim" -Name IsReadOnly -Value $false | Out-Null
                
                Write-Host "Splitting install.wim to $env:TEMP\$WimTemp\install*.swm" -ForegroundColor Green
                Split-WindowsImage -FileSize 500 -ImagePath "$env:TEMP\$WimTemp\install.wim" -SplitImagePath "$env:TEMP\$WimTemp\install.swm" | Out-Null
                
                Write-Host "Copying install*.swm to $($Results.DriveLetter):\sources" -ForegroundColor Green
                Copy-Item -Path "$env:TEMP\$WimTemp\*" -Exclude install.wim -Destination "$($Results.DriveLetter):\sources" -Recurse -Verbose
            }
        } else {
            Copy-Item -Path "$($ISO):\*" -Destination "$($Results.DriveLetter):" -Recurse -Verbose
        }

        #=================================================
        Write-Verbose "Dismounting Disk Image ..."
        #=================================================
        Dismount-DiskImage -ImagePath $ISOFile
    }
    END {
        #=================================================
        Write-Verbose "Complete"
        #=================================================
    }
}