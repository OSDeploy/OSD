Function Install-BuildUpdatesFromOSCloudUSB {
    ﻿Function Get-UBR {
        if ($env:SystemDrive -eq "X:"){
            $Info = DISM.exe /image:c:\ /Get-CurrentEdition
            $UBR = ($Info | Where-Object {$_ -match "Image Version"}).replace("Image Version: ","")
        }
        else {
            $Info = DISM.exe /online /Get-CurrentEdition
            $UBR = ($Info | Where-Object {$_ -match "Image Version"}).replace("Image Version: ","")
        }
        return $UBR
    }
    ﻿Function Install-Update {
        [CmdletBinding()]
        Param (
        [Parameter(Mandatory=$true)]
	    $UpdatePath
        )

        $scratchdir = 'C:\OSDCloud\Temp'
        if (!(Test-Path -Path $scratchdir)){
            new-item -Path $scratchdir | Out-Null
        }

        if ($env:SystemDrive -eq "X:"){
            $Process = "X:\Windows\system32\Dism.exe"
            $DISMArg = "/Image:C:\ /Add-Package /PackagePath:$UpdatePath /ScratchDir:$scratchdir /Quiet /NoRestart"
        }
        else {
            $Process = "C:\Windows\system32\Dism.exe"
            $DISMArg = "/Online /Add-Package /PackagePath:$UpdatePath /ScratchDir:$scratchdir /Quiet /NoRestart"
        }


        Write-Output "Starting Process of $Process -ArgumentList $DismArg -Wait"
        $DISM = Start-Process $Process -ArgumentList $DISMArg -Wait -PassThru
    
        return $DISM.ExitCode
    }
    $BuildNumber = (Get-UBR).split(".")[2]
    $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Select-Object -First 1
    $UpdatesPath = "$($OSDCloudUSB.DriveLetter):\OSDCloud\OS\Updates"
    $MSUUpdates = Get-ChildItem -Path $UpdatesPath -Recurse | Where-Object {$_.Name -match ".msu" -or $_.Name -match ".cab"}
    $BuildUpdates = $MSUUpdates | Where-Object {$_.fullname -match "$BuildNumber"}


    if ($BuildUpdates){
        Write-Output "Current OS UBR: $(Get-UBR)"
        Write-Host " Found thse Updates: "
        foreach ($Update in $BuildUpdates){
            $Update.FullName
        }
        Write-Host "Starting DISM Update Process"
        foreach ($Update in $BuildUpdates){
            Write-Host "Installing Update: $($Update.Name)"
            Install-Update -UpdatePath $Update.FullName
        }
        Write-Output "Current OS UBR: $(Get-UBR)"
    }
}
