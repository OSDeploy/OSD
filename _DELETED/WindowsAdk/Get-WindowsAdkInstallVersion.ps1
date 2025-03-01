function Get-WindowsAdkInstallVersion {
    <#
    .SYNOPSIS
    Retrieves the installed version of the Windows Assessment and Deployment Kit (Windows ADK) from the registry.

    .DESCRIPTION
    Retrieves the installed version of the Windows Assessment and Deployment Kit (Windows ADK) from the registry.

    .NOTES
    Author: David Segura
    #>
    [CmdletBinding()]
    param ()

    $Result = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | `
    Where-Object { $_.DisplayName -eq 'Windows Assessment and Deployment Kit' } | Select-Object -ExpandProperty DisplayVersion -First 1

    return $Result
}