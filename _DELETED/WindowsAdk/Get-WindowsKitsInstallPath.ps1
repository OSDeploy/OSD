function Get-WindowsKitsInstallPath {
    <#
    .SYNOPSIS
    Retrieves the installation path of the Windows Kit directory.

    .DESCRIPTION
    Retrieves the installation path of the Windows Kit directory.

    .NOTES
    Author: David Segura
    #>
    [CmdletBinding()]
    param ()

    # 32-bit Registry
    $InstalledRoots32 = 'HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots'
    # 64-bit Registry
    $InstalledRoots64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots'
    
    $RegistryValue = 'KitsRoot10'
    $KitsRoot10 = $null

    # Test for 64-bit Registry
    if (Test-Path -Path $InstalledRoots64) {
        $RegistryKey = Get-Item -Path $InstalledRoots64
        if ($null -ne $RegistryKey.GetValue($RegistryValue)) {
            $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots64 -Name $RegistryValue -ErrorAction SilentlyContinue
        }
    }

    if (-not ($KitsRoot10)) {
        if (Test-Path -Path $InstalledRoots32) {
            $RegistryKey = Get-Item -Path $InstalledRoots32
            if ($null -ne $RegistryKey.GetValue($RegistryValue)) {
                $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots32 -Name $RegistryValue -ErrorAction SilentlyContinue
            }
        }
    }


    if ($KitsRoot10) {
        if (Test-Path "$KitsRoot10") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))] Windows Kits install path is $KitsRoot10"
            return $KitsRoot10
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] Windows Kits install path from the registry does not exist at $KitsRoot10"
            return $null
        }
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] Windows Kits is not installed"
        return $null
    }
}
