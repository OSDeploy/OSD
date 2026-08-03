function Export-OSDCertificatesAsReg {
    <#
    .SYNOPSIS
    Exports selected LocalMachine certificates as .reg files.

    .DESCRIPTION
    Prompts for installed certificates and exports matching certificate registry keys from system certificate hives into .reg files under the temporary Certs folder.

    .EXAMPLE
    Export-OSDCertificatesAsReg
    Opens a selection grid and exports registry-backed certificate entries for selected certificates to $env:Temp\Certs.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param ()

    Write-Verbose "Export-OSDCertificatesAsReg: Export installed Certificates as REG files to $env:Temp\Certs"

    $Certs = Get-ChildItem -Path Cert:\LocalMachine -Recurse | Where-Object {$_.PSIsContainer -eq $false} | Select-Object -Property FriendlyName, Thumbprint, Issuer, Subject, Handle, PSPath | Sort-Object FriendlyName | Out-GridView -PassThru -Title 'Select Certificates to Convert to Reg'

    foreach ($Cert in $Certs) {
        $Reg = @()
        $Reg = Get-ChildItem -Path ('HKLM:\SOFTWARE\Microsoft\SystemCertificates','HKLM:\SOFTWARE\Policies\Microsoft\SystemCertificates','HKLM:\SOFTWARE\Microsoft\EnterpriseCertificates') -Recurse | Select-Object -Property * | Where-Object {$_.Name -like "*$($Cert.Thumbprint)*"}

        if (!(Test-Path "$env:Temp\Certs")) {New-Item "$env:Temp\Certs" -ItemType Directory -Force | Out-Null}

        Write-Verbose "$($Cert.FriendlyName)" -Verbose
        foreach ($R in $Reg) {
            Write-Host "$($R.Name)"
            $ver = Get-Random
            Write-Host "Exporting to $env:Temp\Certs\$($Cert.Thumbprint)-$($Cert.Handle)-$ver.reg" -ForegroundColor DarkGray
            reg export "$($R.Name)" "$env:Temp\Certs\$($Cert.Thumbprint)-$($Cert.Handle)-$ver.reg"
        }
    }
}
