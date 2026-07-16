function Set-LatestUpdatesASAPEnabled {
    Write-Host "Enable 'Get the latest updates as soon as they’re available' Reg Value" -ForegroundColor DarkGray
    if ($env:SystemDrive -eq 'X:') {
        $WindowsPhase = 'WinPE'
    }
    if ($WindowsPhase -eq 'WinPE'){
        Invoke-Exe reg load HKLM\TempSOFTWARE "C:\Windows\System32\Config\SOFTWARE"
        Invoke-Exe reg add HKLM\TempSOFTWARE\Microsoft\WindowsUpdate\UX\Settings /V IsContinuousInnovationOptedIn /T REG_DWORD /D 1 /F
        Invoke-Exe reg unload HKLM\TempSOFTWARE
    }
    else {
        Invoke-Exe reg add HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings /V IsContinuousInnovationOptedIn /T REG_DWORD /D 1 /F
    }
}
