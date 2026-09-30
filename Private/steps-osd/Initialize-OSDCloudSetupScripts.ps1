function Initialize-OSDCloudSetupScripts {
    <#
    .SYNOPSIS
    Initializes the Windows setup command files for an OSDCloud deployment.

    .DESCRIPTION
    Creates the Windows Setup Scripts directory when needed and appends an
    OSDCloud timestamp marker to SetupComplete.cmd and OOBE.cmd without
    replacing existing content.

    .PARAMETER WindowsPath
    Specifies the Windows directory containing the Setup\Scripts directory.

    .EXAMPLE
    Initialize-OSDCloudSetupScripts
    Initializes the setup command files under C:\Windows\Setup\Scripts.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-09-30 - Initial version
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$WindowsPath = 'C:\Windows'
    )

    $scriptsPath = Join-Path -Path $WindowsPath -ChildPath 'Setup\Scripts'
    if (-not (Test-Path -Path $scriptsPath -PathType Container -ErrorAction SilentlyContinue)) {
        New-Item -Path $scriptsPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $marker = ":: OSDCloud $(Get-Date -format s)"
    foreach ($fileName in @('SetupComplete.cmd', 'OOBE.cmd')) {
        $filePath = Join-Path -Path $scriptsPath -ChildPath $fileName
        $marker | Out-File -FilePath $filePath -Append -Encoding ascii -Width 2000 -Force -ErrorAction Stop
    }
}
