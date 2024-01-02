function Set-SetupCompleteHPAppend {

    $ScriptsPath = "C:\Windows\Setup\scripts"
    if (!(Test-Path -Path $ScriptsPath)){New-Item -Path $ScriptsPath} 

    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (Test-Path -Path $PSFilePath){
        #Add-Content -Path $PSFilePath "Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')"
        Add-Content -Path $PSFilePath 'Write-Output "Running HP Tools in Setup Complete | Time: $($(Get-Date).ToString("hh:mm:ss"))"'
        if ($Global:OSDCloud.HPIADrivers -eq $true){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Drivers [Invoke-HPIA]" -ForegroundColor Magenta'
            if (Test-Path -path "C:\OSDCloud\HPIA\Repo"){Add-Content -Path $PSFilePath "Invoke-HPIA -OfflineMode True -Category Drivers"}
            else {Add-Content -Path $PSFilePath "Invoke-HPIA -Category Drivers"}
            Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
        }
        if (($Global:OSDCloud.HPIAFirmware -eq $true) -and ($Global:OSDCloud.HPIAAll  -ne $true)){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Firmware [Invoke-HPIA]" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "Invoke-HPIA -Category Firmware"
            Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
        } 
        if (($Global:OSDCloud.HPIASoftware -eq $true) -and ($Global:OSDCloud.HPIAAll  -ne $true)){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Software [Invoke-HPIA]" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "Invoke-HPIA -Category Software"
            Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
        } 
        if ($Global:OSDCloud.HPIAAll -eq $true){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for All Items [Invoke-HPIA]" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "Invoke-HPIA -Category All"
            Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
        }            
        if ($Global:OSDCloud.HPTPMUpdate -eq $true){
            Add-Content -Path $PSFilePath 'if (Get-HPTPMDetermine -ne "False"){Write-Host "Updating TPM Firmware" [Invoke-HPTPMEXEDownload and Invoke-HPTPMEXEInstall] -ForegroundColor Magenta}'
            Add-Content -Path $PSFilePath 'if (Get-HPTPMDetermine -ne "False"){Invoke-HPTPMEXEDownload}'
            Add-Content -Path $PSFilePath 'if (Get-HPTPMDetermine -ne "False"){Invoke-HPTPMEXEInstall}'
            Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
        } 
        if ($Global:OSDCloud.HPBIOSUpdate -eq $true){
            Add-Content -Path $PSFilePath 'Write-Host "Running HP System Firmware [Get-HPBIOSUpdates]" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "Get-HPBIOSUpdates -Flash -Yes -Offline -BitLocker Ignore"
            Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
        }
        Add-Content -Path $PSFilePath "Set-HPBIOSSetting -SettingName 'Virtualization Technology (VTx)' -Value 'Enable'"
        Add-Content -Path $PSFilePath 'Write-Output "Completed Section HP Enterprise Device Updates | Time: $($(Get-Date).ToString("hh:mm:ss"))"'
        Add-Content -Path $PSFilePath "Write-Output '-------------------------------------------------------------'"
    }
    else {
    Write-Output "$PSFilePath - Not Found"
    }
}
