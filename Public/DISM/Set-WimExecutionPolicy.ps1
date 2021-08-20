<#
.SYNOPSIS
Sets the PowerShell Execution Policy of a Windows Image .wim file (Mount | Set | Dismount -Save)

.DESCRIPTION
Sets the PowerShell Execution Policy of a Windows Image .wim file (Mount | Set | Dismount -Save)

.PARAMETER ExecutionPolicy
Specifies the new execution policy. The acceptable values for this parameter are:
- Restricted. Does not load configuration files or run scripts. Restricted is the default execution policy.
- AllSigned. Requires that all scripts and configuration files be signed by a trusted publisher, including scripts that you write on the local computer.
- RemoteSigned. Requires that all scripts and configuration files downloaded from the Internet be signed by a trusted publisher.
- Unrestricted. Loads all configuration files and runs all scripts. If you run an unsigned script that was downloaded from the Internet, you are prompted for permission before it runs.
- Bypass. Nothing is blocked and there are no warnings or prompts.
- Undefined. Removes the currently assigned execution policy from the current scope. This parameter will not remove an execution policy that is set in a Group Policy scope.

.PARAMETER ImagePath
Specifies the location of the WIM or VHD file containing the Windows image you want to mount.

.PARAMETER Index
Index of the WIM to Mount
Default is 1

.LINK
https://osd.osdeploy.com/module/functions/dism/set-wimexecutionpolicy

.NOTES
21.2.1  Initial Release
#>
function Set-WimExecutionPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Restricted','AllSigned','RemoteSigned','Unrestricted','Bypass','Undefined')]
        [string]$ExecutionPolicy,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$ImagePath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [UInt32]$Index = 1
    )

    begin {
		#=================================================
		#	Blocks
		#=================================================
		Block-WinPE
		Block-StandardUser
        #=================================================
    }
    process {
        foreach ($Input in $ImagePath) {
            #=================================================
            $MountMyWindowsImage = Mount-MyWindowsImage -ImagePath $Input -Index $Index
            $MountMyWindowsImage | Set-WindowsImageExecutionPolicy -ExecutionPolicy $ExecutionPolicy
            $MountMyWindowsImage | Dismount-MyWindowsImage -Save
            #=================================================
        }
    }
    end {}
}