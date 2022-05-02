<#
.SYNOPSIS
Development function to get the contents of a PSCloudScript. Optionally allows for execution by command or file
.DESCRIPTION
Development function to get the contents of a PSCloudScript. Optionally allows for execution by command or file
.LINK
https://osd.osdeploy.com
#>
function Invoke-CloudSecret
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $VaultName,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the secret to get the content to use as a PSCloudScript
        $Name,

        [ValidateSet('Command','File','FileRunas')]
        [System.String]
        $Invoke = 'Command'
    )
    #=================================================
    #	Get-CloudSecret
    #=================================================
    $GetCloudSecret = Get-CloudSecret -VaultName $VaultName -Name $Name
    #=================================================
    #	Invoke
    #=================================================
    if ($GetCloudSecret) {
        if ($Invoke -eq 'Command') {
            Invoke-Expression -Command $GetCloudSecret
        }
        if ($Invoke -eq 'File') {
            $GetCloudSecret | Out-File -FilePath "$env:TEMP\CloudSecret.ps1"
            & "$env:TEMP\CloudSecret.ps1"
            Remove-Item -Path "$env:TEMP\CloudSecret.ps1" -Force -ErrorAction Ignore | Out-Null
        }
        if ($Invoke -eq 'FileRunas') {
            $GetCloudSecret | Out-File -FilePath "$env:TEMP\CloudSecret.ps1"
            Start-Process powershell.exe -Verb Runas "& $env:TEMP\CloudSecret.ps1" -Wait
            Remove-Item -Path "$env:TEMP\CloudSecret.ps1" -Force -ErrorAction Ignore | Out-Null
        }
    }
}