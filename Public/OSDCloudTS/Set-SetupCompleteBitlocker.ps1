function Set-SetupCompleteBitlocker {

    #Create Script to Backup Bitlocker Key to AAD
    Write-Host -ForegroundColor Cyan "Creating Bitlocker Script File"
<# This is original, testing more complicated script now.
    $BitlockerFile = @'
$BitlockerVol = Get-BitLockerVolume -MountPoint $env:SystemDrive
$KPID=""
foreach($KP in $BitlockerVol.KeyProtector){
    if($KP.KeyProtectorType -eq "RecoveryPassword"){
        $KPID=$KP.KeyProtectorId
        Write-Output $KPID
        $output = BackupToAAD-BitLockerKeyProtector -MountPoint "$($env:SystemDrive)" -KeyProtectorId $KPID
    }
}
Start-Sleep -Seconds 10
Unregister-ScheduledTask -TaskName "Register Bitlocker in AAD" -Confirm:$False
'@
#>
$BitlockerFile = @'
$date = Get-Date -Format yyyy-MM-dd-hhmmss
Start-Transcript -Path "C:\OSDCloud\Logs\$($date)-SetupCompleteBitlocker.log" -ErrorAction Ignore

$Users = (Get-Process -IncludeUserName).UserName | Select-Object -Unique
$Users

$ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
if ($env:UserName -eq 'defaultuser0') {$WindowsPhase = 'OOBE'}
elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {$WindowsPhase = 'Specialize'}
elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') {$WindowsPhase = 'AuditMode'}
else {$WindowsPhase = 'Windows'}
write-output "Windows Phase = $WindowsPhase"
#Get-Process -IncludeUserName | Out-File "C:\osdcloud\Logs\$($date)-SetupCompleteBitlocker-RunningProcess.txt"
#Test for AAD
$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo" -ErrorAction SilentlyContinue

#Test for AD

$regexa = '.+Domain="(.+)",Name="(.+)"$' 
$regexd = '.+LogonId="(\d+)"$' 
$logon_sessions = @(gwmi win32_logonsession -ComputerName $env:COMPUTERNAME) 
$logon_users = @(gwmi win32_loggedonuser -ComputerName $env:COMPUTERNAME) 
$session_user = @{} 
$logon_users |% { $_.antecedent -match $regexa > $nul ;$username = $matches[2] ;$_.dependent -match $regexd > $nul ;$session = $matches[1] ;$session_user[$session] += $username } 
$currentUser = $logon_sessions |%{ 
    $loggedonuser = New-Object -TypeName psobject 
    $loggedonuser | Add-Member -MemberType NoteProperty -Name "User" -Value $session_user[$_.logonid] 
    $loggedonuser | Add-Member -MemberType NoteProperty -Name "Type" -Value $_.logontype
    $loggedonuser | Add-Member -MemberType NoteProperty -Name "Auth" -Value $_.authenticationpackage 
    ($loggedonuser  | where {$_.Type -eq "2" -and $_.Auth -eq "Kerberos"}).User 
    } 
$currentUser = $currentUser | select -Unique

if (($currentUser -eq $null) -and ($subKey -eq $null)) {Write-Output "No AAD or AD info found"}

else {
    $BitlockerVol = Get-BitLockerVolume -MountPoint $env:SystemDrive
    $KPID=""
    if($subKey -ne $null){
        Write-Output "Device Determined to be AAD Joined"
        foreach($KP in $BitlockerVol.KeyProtector){
            if($KP.KeyProtectorType -eq "RecoveryPassword"){
                $KPID=$KP.KeyProtectorId
                Write-Output $KPID
                BackupToAAD-BitLockerKeyProtector -MountPoint "$($env:SystemDrive)" -KeyProtectorId $KPID
            }
        }
    }
    if($currentUser -ne $null){
        Write-Output "Device Determined to be On-Prem AD Joined"
        foreach($KP in $BitlockerVol.KeyProtector){
            if($KP.KeyProtectorType -eq "RecoveryPassword"){
                $KPID=$KP.KeyProtectorId
                Write-Output $KPID
                Backup-BitLockerKeyProtector -MountPoint "$($env:SystemDrive)" -KeyProtectorId $KPID
            }
        }
    }
}
Start-Sleep -Seconds 10
if (!($Users -match "defaultuser")){Unregister-ScheduledTask -TaskName "Register Bitlocker in AAD" -Confirm:$False}
Stop-Transcript
'@

    if (!(Test-Path -Path "C:\OSDCloud\configs")){New-Item -Path "C:\osdcloud\configs" -ItemType Directory -Force | Out-Null}
    $BitlockerFile | Out-File "C:\OSDCloud\configs\BackupToAAD.ps1" -Force -Verbose
    
    $ScriptsPath = "C:\Windows\Setup\Scripts"
    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (!(Test-Path -Path $ScriptsPath)){
        Set-SetupCompleteInitialize
    }

    Write-Output "Appending $($RunScript.Script) Files"
    Add-Content -Path $PSFilePath "Write-OutPut 'Enabling Bitlocker'"
    Add-Content -Path $PSFilePath "Enable-TpmAutoProvisioning"
    Add-Content -Path $PSFilePath "Initialize-Tpm"
    Add-Content -Path $PSFilePath 'Enable-BitLocker -MountPoint c:\ -EncryptionMethod XtsAes256 -RecoveryPasswordProtector -UsedSpaceOnly:$false'
    #Create Scheduled Task
    Add-Content -Path $PSFilePath '$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument  "-NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File C:\OSDCloud\configs\BackupToAAD.ps1"'
    Add-Content -Path $PSFilePath '$trigger = New-ScheduledTaskTrigger -AtLogon'
    Add-Content -Path $PSFilePath '$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount'
    Add-Content -Path $PSFilePath '$settings = New-ScheduledTaskSettingsSet'
    Add-Content -Path $PSFilePath '$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings'
    Add-Content -Path $PSFilePath 'Register-ScheduledTask "Register Bitlocker in AAD" -InputObject $task'
}