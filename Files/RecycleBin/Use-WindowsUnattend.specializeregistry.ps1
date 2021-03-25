function Use-WindowsUnattend.specializeregistry {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Block
    #=======================================================================
    Block-WinOS
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=======================================================================
    #   Specialize.cmd
    #=======================================================================
    Write-Verbose "Creating C:\Windows\Setup\Scripts\Specialize.cmd"

    if (-NOT (Test-Path 'C:\Windows\Setup\Scripts')) {
        New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force | Out-Null
    }

$Specialize = @'
C:\Drivers\tp_l14gen1_mt20u1-20u2-l15gen1_mt20u3-20u4_w1064_20h2_202101.exe /VERYSILENT /SUPPRESSMSGBOXES
pause
'@

    $Specialize | Out-File -FilePath 'C:\Windows\Setup\Scripts\Specialize.cmd' -Force -Encoding ascii
    #=======================================================================
    #	Panther Unattend.xml
    #=======================================================================
    #Mount Registry
    reg load HKLM\mSOFTWARE "C:\Windows\System32\Config\SOFTWARE"
    reg add "HKLM\mSOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\Setup-Unattend-Settings\RunSynchronous\1" /v Description /d OSDWinSetup /f
    reg add "HKLM\mSOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\Setup-Unattend-Settings\RunSynchronous\1" /v Path /d cmd /c C:\Windows\Setup\Scripts\Specialize.cmd /f
    reg unload HKLM\mSOFTWARE

    Notepad 'C:\Windows\Setup\Scripts\Specialize.cmd'
    #=======================================================================
}