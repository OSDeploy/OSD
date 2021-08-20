<#
.SYNOPSIS
Sets the PowerShell Execution Policy of a mounted Windows Image

.DESCRIPTION
Sets the PowerShell Execution Policy of a mounted Windows Image

.PARAMETER ExecutionPolicy
Specifies the new execution policy. The acceptable values for this parameter are:
- Restricted. Does not load configuration files or run scripts. Restricted is the default execution policy.
- AllSigned. Requires that all scripts and configuration files be signed by a trusted publisher, including scripts that you write on the local computer.
- RemoteSigned. Requires that all scripts and configuration files downloaded from the Internet be signed by a trusted publisher.
- Unrestricted. Loads all configuration files and runs all scripts. If you run an unsigned script that was downloaded from the Internet, you are prompted for permission before it runs.
- Bypass. Nothing is blocked and there are no warnings or prompts.
- Undefined. Removes the currently assigned execution policy from the current scope. This parameter will not remove an execution policy that is set in a Group Policy scope.

.PARAMETER Path
Specifies the full path to the root directory of the offline Windows image that you will service
If a Path is not specified, all mounted Windows Images will be modified

.LINK
https://osd.osdeploy.com/module/functions/dism/set-windowsimageexecutionpolicy

.NOTES
21.2.1  Initial Release
#>
function Set-WindowsImageExecutionPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Restricted','AllSigned','RemoteSigned','Unrestricted','Bypass','Undefined')]
        [string]$ExecutionPolicy,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$Path
    )

    begin {
		#=================================================
		#	Blocks
		#=================================================
		#Block-WinPE
		Block-StandardUser
        #=================================================
        #   Get-WindowsImage Mounted
        #=================================================
        if ($null -eq $Path) {
            $Path = (Get-WindowsImage -Mounted | Select-Object -Property Path).Path
        }
        #=================================================
        #   Driver
        #=================================================
$InfHeader = @'
[Version]
Signature   = "$WINDOWS NT$"
Class       = System
ClassGuid   = {4D36E97d-E325-11CE-BFC1-08002BE10318}
Provider    = OSDeploy
DriverVer   = 2/1/2021,2021.2.1.0
'@
$InfMain = @"
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
HKLM,SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell,ExecutionPolicy,0x00000,"$ExecutionPolicy"
"@
        #=================================================
    }
    process {
        foreach ($Input in $Path) {
            #=================================================
            #   Path
            #=================================================
            $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
            Write-Verbose "Path: $MountPath"
            #=================================================
            #   Validate Mount Path
            #=================================================
            if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
                Write-Warning "Unable to locate Mounted WindowsImage at $Input"
                Break
            }
            #=================================================
            #   Build Driver
            #=================================================
            $InfFile = "$env:Temp\Set-ExecutionPolicy.inf"
            New-Item -Path $InfFile -Force
            Set-Content -Path $InfFile -Value $InfHeader -Encoding Unicode -Force
            Add-Content -Path $InfFile -Value $InfMain -Encoding Unicode -Force
            #=================================================
            #   Add Driver
            #=================================================
            Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned
            #=================================================
            #   Return for PassThru
            #=================================================
            Return Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
            #=================================================
        }
    }
    end {}
}