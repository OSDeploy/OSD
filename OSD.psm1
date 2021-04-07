#===================================================================================================
#Export Functions

$ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState

#Can't load these functions in Specialize
if ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {
    $OSDPublicFunctions  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Name -notmatch 'ScreenPNG'} | Where-Object {$_.Name -notmatch 'Clipboard'})
    $OSDPrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )
}
else {
    $OSDPublicFunctions  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
    $OSDPrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )
}

foreach ($Import in @($OSDPublicFunctions + $OSDPrivateFunctions)) {
    Try {. $Import.FullName}
    Catch {Write-Error -Message "Failed to import function $($Import.FullName): $_"}
}

Export-ModuleMember -Function $OSDPublicFunctions.BaseName

#===================================================================================================
#WinPE
if ($env:SystemDrive -eq 'X:') {
    $OSDPublicFunctions  = @( Get-ChildItem -Path ("$PSScriptRoot\Public\*.ps1","$PSScriptRoot\WinPE\*.ps1") -Recurse -ErrorAction SilentlyContinue )

    [System.Environment]::SetEnvironmentVariable('APPDATA', (Join-Path $env:USERPROFILE 'AppData\Roaming'),[System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('HOMEDRIVE', $env:SystemDrive,[System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('HOMEPATH', (($env:USERPROFILE) -split ":")[1],[System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA', (Join-Path $env:USERPROFILE 'AppData\Local'),[System.EnvironmentVariableTarget]::Machine)

    $VolatileEnvironment = "HKCU:\Volatile Environment"
    if (-NOT (Test-Path -Path $VolatileEnvironment)) {
        New-Item -Path $VolatileEnvironment -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "APPDATA" -Value (Join-Path $env:USERPROFILE 'AppData\Roaming') -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "HOMEDRIVE" -Value $env:SystemDrive -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "HOMEPATH" -Value (($env:USERPROFILE) -split ":")[1] -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "LOCALAPPDATA" -Value (Join-Path $env:USERPROFILE 'AppData\Local') -Force
    }
}

#===================================================================================================
#Alias
New-Alias -Name Clear-LocalDisk -Value Clear-Disk.fixed -Force -ErrorAction SilentlyContinue
New-Alias -Name Clear-USBDisk -Value Clear-Disk.usb -Force -ErrorAction SilentlyContinue
New-Alias -Name Copy-ModuleToFolder -Value Copy-PSModuleToFolder -Force -ErrorAction SilentlyContinue
New-Alias -Name Dismount-WindowsImageOSD -Value Dismount-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Edit-WindowsImageOSD -Value Edit-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Find-InOSDModule -Value Find-TextInModule -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-LocalDisk -Value Get-Disk.fixed -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-LocalPartition -Value Get-Partition.fixed -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-LocalVolume -Value Get-Volume.fixed -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-OSDDisk -Value Get-Disk.osd -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-OSDPartition -Value Get-Partition.osd -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-OSDSessions -Value Get-SessionsXml -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-OSDVolume -Value Get-Volume.osd -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-USBDisk -Value Get-Disk.usb -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-USBPartition -Value Get-Partition.usb -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-USBVolume -Value Get-Volume.usb -Force -ErrorAction SilentlyContinue
New-Alias -Name Mount-OSDWindowsImage -Value Mount-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Mount-WindowsImageOSD -Value Mount-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Mount-WindowsImageOSD -Value Mount-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name New-OSDBoot.usb -Value New-Bootable.usb -Force -ErrorAction SilentlyContinue
New-Alias -Name Select-USBDisk -Value Select-Disk.usb -Force -ErrorAction SilentlyContinue
New-Alias -Name Select-USBVolume -Value Select-Volume.usb -Force -ErrorAction SilentlyContinue
New-Alias -Name Update-OSDWindowsImage -Value Update-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Update-WindowsImageOSD -Value Update-MyWindowsImage -Force -ErrorAction SilentlyContinue
#===================================================================================================
#Export-ModuleMember
Export-ModuleMember -Function * -Alias *