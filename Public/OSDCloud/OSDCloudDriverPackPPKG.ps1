function Invoke-OSDCloudDriverPackPPKG {
    <#
    .SYNOPSIS
    Uses DISM in WinPE to expand and apply Driver Packs

    .DESCRIPTION
    Uses DISM in WinPE to expand and apply Driver Packs

    .EXAMPLE
    Invoke-OSDCloudDriverPackPPKG
    Applies the packaged OSDCloud driver pack to the Windows image from WinPE.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES and EXAMPLE to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param ()
    $OSDCloudDriverPackPPKG = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Provisioning\Invoke-OSDCloudDriverPack.ppkg"

    if (Test-Path $OSDCloudDriverPackPPKG) {
        Write-Host -ForegroundColor DarkGray "dism.exe /Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$OSDCloudDriverPackPPKG`""
        $Dism = "dism.exe"
        $ArgumentList = "/Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$OSDCloudDriverPackPPKG`""
        $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
    }
}
