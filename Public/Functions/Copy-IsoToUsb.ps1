function Copy-IsoToUsb {
    <#
    .SYNOPSIS
    Creates a bootable USB drive from a Windows ISO.

    .DESCRIPTION
    Formats a selected USB disk, mounts the ISO, and copies installation files
    to the USB volume. Supports FAT32 or NTFS, optional bootsect execution, and
    optional splitting of large install.wim files.

    .PARAMETER ISOFile
    Full path to the ISO file to mount and copy.

    .PARAMETER MakeBootable
    Runs bootsect.exe against the USB drive after formatting.

    .PARAMETER NTFS
    Formats the USB drive as NTFS instead of FAT32.

    .PARAMETER SplitWim
    Forces splitting install.wim into .swm files during copy.

    .PARAMETER USBLabel
    File system label assigned to the USB drive.

    .EXAMPLE
    Copy-IsoToUsb -ISOFile 'C:\Temp\Win11.iso' -MakeBootable -USBLabel WIN11
    Creates a bootable USB and copies the ISO contents.

    .EXAMPLE
    Copy-IsoToUsb -ISOFile 'C:\Temp\Win11.iso' -NTFS -USBLabel WIN11NTFS
    Creates an NTFS-formatted USB and copies the ISO contents.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Updated comment-based help
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq '.iso')})]
        [System.String]$ISOFile,
        [System.Management.Automation.SwitchParameter]$MakeBootable,
        [System.Management.Automation.SwitchParameter]$NTFS,
        [System.Management.Automation.SwitchParameter]$SplitWim,
        [System.String]$USBLabel
    )
    begin {
        #=================================================
        Write-Verbose "Validating Elevated Permissions ..."
        #=================================================
        $Elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if ( -not $Elevated ) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]This Function requires Elevation"
        }
    }
    
    process {
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
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]No USB Driver was Found or Selected"
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
    end {
        #=================================================
        Write-Verbose "Complete"
        #=================================================
    }
}
