function Set-PEWindowsImageEnvironment {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$Path
    )

    begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #===================================================================================================
        #   Get-WindowsImage Mounted
        #===================================================================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
        #===================================================================================================
    }
    process {
        foreach ($Input in $Path) {
            #===================================================================================================
            #   Path
            #===================================================================================================
            $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
            Write-Verbose "Path: $MountPath"
            #===================================================================================================
            #   Validate Mount Path
            #===================================================================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Unable to locate Mounted WindowsImage at $Input"
                Break
            }
            #===================================================================================================
            #   Driver
            #===================================================================================================
$InfContent = @'
[Version]
Signature   = "$WINDOWS NT$"
Class       = System
ClassGuid   = {4D36E97d-E325-11CE-BFC1-08002BE10318}
Provider    = OSDeploy
DriverVer   = 03/08/2021,2021.03.08.0

[DefaultInstall] 
AddReg      = AddReg 

[AddReg]
;rootkey,[subkey],[value],[flags],[data]
;0x00000    REG_SZ
;0x00001    REG_BINARY
;0x10000    REG_MULTI_SZ
;0x20000    REG_EXPAND_SZ
;0x10001    REG_DWORD
;0x20001    REG_NONE
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",APPDATA,0x00000,"X:\Windows\System32\Config\SystemProfile\AppData\Roaming"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",HOMEDRIVE,0x00000,"X:"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",HOMEPATH,0x00000,"Windows\System32\Config\SystemProfile"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",LOCALAPPDATA,0x00000,"X:\Windows\System32\Config\SystemProfile\AppData\Local"
'@
            #===================================================================================================
            #   Build Driver
            #===================================================================================================
            $InfFile = "$env:Temp\Set-WinPEEnvironment.inf"
            New-Item -Path $InfFile -Force
            Set-Content -Path $InfFile -Value $InfContent -Encoding Unicode -Force
            #===================================================================================================
            #   Add Driver
            #===================================================================================================
            Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned
            #===================================================================================================
            #   Return for PassThru
            #===================================================================================================
            Return Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
            #===================================================================================================
        }
    }
    end {}
}