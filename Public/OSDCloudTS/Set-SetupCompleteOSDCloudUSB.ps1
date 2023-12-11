Function Get-SetupCompleteOSDCloudUSB {

    $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Select-Object -First 1
    $SetupCompletePath = "$($OSDCloudUSB.DriveLetter):\OSDCloud\Config\Scripts\SetupComplete"
    if (Test-Path $SetupCompletePath){$SetupComplete = Get-ChildItem $SetupCompletePath}
    if ($SetupComplete){
        return $true
    }
    else {
        return $false
    }
}

function Set-SetupCompleteOSDCloudUSB {

    $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Select-Object -First 1
    $SetupCompletePath = "$($OSDCloudUSB.DriveLetter):\OSDCloud\Config\Scripts\SetupComplete"
    if (Test-Path $SetupCompletePath){$SetupComplete = Get-ChildItem $SetupCompletePath}
    if ($SetupComplete){
        try {
            [void][System.IO.Directory]::CreateDirectory("C:\OSDCloud\Scripts")
            [void][System.IO.Directory]::CreateDirectory("C:\OSDCloud\Scripts\SetupComplete")
        }
        catch {throw}
        Write-Host " Found SetupComplete Files on OSDCloudUSB, Copying Local and Setting up for SetupComplete Phase" -ForegroundColor Gray
        Copy-Item -Path $SetupCompletePath\* -Destination "C:\OSDCloud\Scripts\SetupComplete" -Recurse -Force
        
        $ScriptsPath = "C:\Windows\Setup\scripts"
        $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
        $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"
    
        if (Test-Path -Path $PSFilePath){
            Add-Content -Path $PSFilePath "Write-OutPut 'Running Scripts in Custom OSDCloud SetupComplete Folder'"
            Add-Content -Path $PSFilePath '$SetupCompletePath = "C:\OSDCloud\Scripts\SetupComplete\SetupComplete.cmd"'
            Add-Content -Path $PSFilePath 'if (Test-Path $SetupCompletePath){$SetupComplete = Get-ChildItem $SetupCompletePath -Filter SetupComplete.cmd}'
            Add-Content -Path $PSFilePath 'if ($SetupComplete){cmd.exe /start /wait /c $SetupComplete.FullName}'
        }
        else {
        Write-Output "$PSFilePath - Not Found"
        }
    }
}
