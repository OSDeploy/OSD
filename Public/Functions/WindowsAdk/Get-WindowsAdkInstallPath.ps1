function Get-WindowsAdkInstallPath {
    <#
    .SYNOPSIS
    Retrieves the installation path of the Windows Assessment and Deployment Kit (Windows ADK) from the registry.

    .DESCRIPTION
    Retrieves the installation path of the Windows Assessment and Deployment Kit (Windows ADK) from the registry.

    .NOTES
    Author: David Segura
    #>
    [CmdletBinding()]
    param ()

    $WindowsKitsInstallPath = Get-WindowsKitsInstallPath

    if ($WindowsKitsInstallPath) {
        $WindowsAdkInstallPath = Join-Path $WindowsKitsInstallPath 'Assessment and Deployment Kit'

        if (Test-Path "$WindowsAdkInstallPath") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))] Windows Assessment and Deployment Kit install path is $WindowsAdkInstallPath"
            return $WindowsAdkInstallPath
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] Windows Assessment and Deployment Kit is not installed"
            return $null
        }

    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] Windows Assessment and Deployment Kit is not installed"
        return $null
    }
}