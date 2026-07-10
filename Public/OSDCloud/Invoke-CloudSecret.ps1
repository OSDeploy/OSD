function Invoke-CloudSecret
{
    <#
    .SYNOPSIS
    Invoke a secret retrieved from Azure Key Vault.

    .DESCRIPTION
    Loads the named secret with Get-CloudSecret and either invokes it directly, writes it to a
    temporary file, or runs it elevated depending on the selected invoke mode.

    .PARAMETER VaultName
    Name of the Key Vault that contains the secret.

    .PARAMETER Name
    Name of the secret to read.

    .PARAMETER Invoke
    Choose how to run the secret content: Command, File, or FileRunas.

    .EXAMPLE
    Invoke-CloudSecret -VaultName contoso -Name Script
    Invokes the retrieved secret in the current session.

    .EXAMPLE
    Invoke-CloudSecret -VaultName contoso -Name Script -Invoke FileRunas
    Writes the secret to a temporary file and runs it elevated.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
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
    [System.String]$GetCloudSecret = Get-CloudSecret -VaultName $VaultName -Name $Name
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
