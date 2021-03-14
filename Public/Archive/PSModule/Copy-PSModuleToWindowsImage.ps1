<#
.SYNOPSIS
Copies the latest installed named PowerShell Module to a mounted Windows Image

.DESCRIPTION
Copies the latest installed named PowerShell Module to a mounted Windows Image

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
https://osd.osdeploy.com/module/functions/psmodule/copy-psmoduletowindowsimage

.NOTES
21.3.8  Resolved issue where Name parameter was missing
21.2.9  Initial Release#>
function Copy-PSModuleToWindowsImage {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [SupportsWildcards()]
        [String[]]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Restricted','AllSigned','RemoteSigned','Unrestricted','Bypass','Undefined')]
        [string]$ExecutionPolicy,

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
            #===============================================================================================
            #   Copy-PSoduleToFolder
            #===============================================================================================
            Copy-PSModuleToFolder -Name $Name -Destination "$MountPath\Program Files\WindowsPowerShell\Modules" -RemoveOldVersions
            #===============================================================================================
            #   Set-WindowsImageExecutionPolicy
            #===============================================================================================
            if ($ExecutionPolicy) {
                Set-WindowsImageExecutionPolicy -ExecutionPolicy $ExecutionPolicy -Path $MountPath
            }
            #===================================================================================================
            #   Return for PassThru
            #===================================================================================================
            Return Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
            #===================================================================================================
        }
    }
    end {}
}