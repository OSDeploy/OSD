$Classes = @(Get-ChildItem -Path "$PSScriptRoot\Classes\*.ps1")
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue)

#Determine the current state of the OS
$ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState

#Can't load these functions in Specialize Phase
if ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {
    $Public  = @(Get-ChildItem -Path ("$PSScriptRoot\Public\*.ps1") -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Name -notmatch 'ScreenPNG'} | Where-Object {$_.Name -notmatch 'Clipboard'})

    foreach ($Import in @($Public + $Private)) {
        Try {. $Import.FullName}
        Catch {Write-Error -Message "Failed to import function $($Import.FullName): $_"}
    }
}
else {
    #MSCatalog
    try {
        if (!([System.Management.Automation.PSTypeName]'HtmlAgilityPack.HtmlDocument').Type) {
            if ($PSVersionTable.PSEdition -eq "Desktop") {
                Add-Type -Path "$PSScriptRoot\Types\Net45\HtmlAgilityPack.dll"
            } else {
                Add-Type -Path "$PSScriptRoot\Types\netstandard2.0\HtmlAgilityPack.dll"
            }
        }
    } catch {
        $Err = $_
        throw $Err
    }
    
    $Public = @(Get-ChildItem -Path ("$PSScriptRoot\Public\*.ps1") -Recurse -ErrorAction SilentlyContinue)

    foreach ($Import in @($Public + $Private + $Classes)) {
        Try {. $Import.FullName}
        Catch {Write-Error -Message "Failed to import function $($Import.FullName): $_"}
    }
}
Export-ModuleMember -Function $Public.BaseName
#=================================================
#WinPE
if ($env:SystemDrive -eq 'X:') {
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
#=================================================
# 25.2.26
# New-Alias -Name New-AdkISO -Value New-WindowsAdkISO -Force -ErrorAction SilentlyContinue
# 25.1.26
New-Alias -Name Get-AdkPaths -Value Get-WindowsAdkPaths -Force -ErrorAction SilentlyContinue
#Alias
New-Alias -Name Copy-ModuleToFolder -Value Copy-PSModuleToFolder -Force -ErrorAction SilentlyContinue
New-Alias -Name Dismount-WindowsImageOSD -Value Dismount-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Edit-ADKwinpe.wim -Value Edit-AdkWinPEWIM -Force -ErrorAction SilentlyContinue
New-Alias -Name Edit-WindowsImageOSD -Value Edit-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Find-InOSDModule -Value Find-TextInModule -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-OSDSessions -Value Get-SessionsXml -Force -ErrorAction SilentlyContinue
New-Alias -Name Mount-OSDWindowsImage -Value Mount-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Mount-WindowsImageOSD -Value Mount-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Update-OSDWindowsImage -Value Update-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Update-WindowsImageOSD -Value Update-MyWindowsImage -Force -ErrorAction SilentlyContinue
New-Alias -Name Clear-Disk.usb -Value Clear-USBDisk -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-Disk.fixed -Value Get-LocalDisk -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-Partition.fixed -Value Get-LocalDiskPartition -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-Partition.osd -Value Get-OSDPartition -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-Disk.osd -Value Get-OSDDisk -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-Volume.fixed -Value Get-LocalDiskVolume -Force -ErrorAction SilentlyContinue
New-Alias -Name Clear-Disk.fixed -Value Clear-LocalDisk -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-Volume.osd -Value Get-OSDVolume -Force -ErrorAction SilentlyContinue
New-Alias -Name New-Bootable.usb -Value New-BootableUSBDrive -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-Partition.usb -Value Get-USBPartition -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-Volume.usb -Value Get-USBVolume -Force -ErrorAction SilentlyContinue
New-Alias -Name Get-Disk.usb -Value Get-USBDisk -Force -ErrorAction SilentlyContinue
New-Alias -Name Select-Disk.usb -Value Invoke-SelectUSBDisk -Force -ErrorAction SilentlyContinue
New-Alias -Name Select-Volume.usb -Value Invoke-SelectUSBVolume -Force -ErrorAction SilentlyContinue
#=================================================
#Export-ModuleMember
Export-ModuleMember -Function * -Alias *

# Get module strings
$Global:OSDModuleResource = Get-ModuleResource