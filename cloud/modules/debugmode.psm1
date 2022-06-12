<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module is designed to work in WinPE or Full
    This module is for Dell Devices and leveraged HP Tools
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/debugmode.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/debugmode.psm1')
#>
#=================================================
#region Functions

function osdcloud-addcmtrace {
    [CmdletBinding()]
    param ()
    $CMTraceURL = "https://github.com/gwblok/garytown/raw/master/OSD/CloudOSD/CMTrace.exe"
    Invoke-WebRequest -UseBasicParsing -Uri $CMTraceURL -OutFile "$env:TEMP\CMTrace.exe"
    if (Test-Path -Path "$env:TEMP\CMTrace.exe"){
        Write-Output "Running Command: Copy-Item .\CMTrace.exe $($env:windir)\system32\CMTrace.exe -Force -Verbose"
        Copy-Item "$env:TEMP\CMTrace.exe" "$env:windir\system32\CMTrace.exe" -Force
        if ($WindowsPhase -eq 'WinPE') {
            if (Test-Path c:\windows\system32){
                Copy-Item "$env:TEMP\CMTrace.exe" "C:\Windows\system32\CMTrace.exe" -Force 
            }
        }
    }
}

function osdcloud-addserviceui {
    [CmdletBinding()]
    param ()
    $EXEName = "ServiceUI.exe"
    $EXEURL = "https://github.com/gwblok/garytown/raw/master/OSD/CloudOSD/$EXEName"
    Invoke-WebRequest -UseBasicParsing -Uri $EXEURL -OutFile "$env:TEMP\$EXEName"
}

function osdcloud-addmouseoobe {
    #cmd.exe /c reg load HKLM\Offline c:\windows\system32\config\software & cmd.exe /c REG ADD "HKLM\Offline\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableCursorSuppression /t REG_DWORD /d 0 /f & cmd.exe /c reg unload HKLM\Offline
    Invoke-Exe cmd.exe -Arguments "/c reg load HKLM\Offline c:\windows\system32\config\software"
    New-ItemProperty -Path HKLM:\Offline\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableCursorSuppression -Value 0 -Force
    #Invoke-Exe cmd.exe -Arguments "/c REG ADD 'HKLM\Offline\Microsoft\Windows\CurrentVersion\Policies\System' /v EnableCursorSuppression /t REG_DWORD /d 0 /f "
    Invoke-Exe cmd.exe -Arguments "/c reg unload HKLM\Offline"
}


#endregion
#=================================================
