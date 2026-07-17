function Step-OSDCloudExportOSInformation {
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] $($MyInvocation.MyCommand.Name) is skipped when not running in WinPE (X:)"
        return
    }
    #=================================================
    # Ensure the shared log directory exists before writing final deployment logs.
    $logDirectory = 'C:\Windows\Temp\osdcloud-logs'
    if (-not (Test-Path -LiteralPath $logDirectory)) {
        New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
    }
    #=================================================
    # Grab Build from WinPE, as 24H2 has issues with some of these commands.
    $CurrentOSInfo = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $CurrentOSBuild = $($CurrentOSInfo.GetValue('CurrentBuild'))

    if (Get-Command Get-AppxProvisionedPackage -ErrorAction Ignore) {
        Write-SectionHeader "Export Operating System Information"

        Write-DarkGrayHost "Export WinPE PowerShell Commands to $logDirectory\Get-CommandWinPE.txt"
        $Report = Get-Command -ErrorAction Ignore | Where-Object {($_.CommandType -eq 'Cmdlet') -or ($_.CommandType -eq 'Function')} | Where-Object {$_.ModuleName -gt 0} | Sort-Object ModuleName, Name, Version
        $Report | Select-Object ModuleName, Name, Version | Out-File -FilePath (Join-Path $logDirectory 'Get-CommandWinPE.txt') -Force -Encoding ascii

        if (Get-Command Get-AppxProvisionedPackage -ErrorAction Ignore) {
            try {
                Write-DarkGrayHost "Export Appx Provisioned Packages to $logDirectory\Get-AppxProvisionedPackage.txt"
                $Report = Get-AppxProvisionedPackage -Path C:\ -ErrorAction Stop | Select-Object * | Sort-Object DisplayName
                $Report | Select-Object DisplayName | Out-File -FilePath (Join-Path $logDirectory 'Get-AppxProvisionedPackage.txt') -Force -Encoding ascii
            }
            catch {
            }
        }

        if (Get-Command Get-WindowsCapability -ErrorAction Ignore) {
            try {
                Write-DarkGrayHost "Export Windows Capability to $logDirectory\Get-WindowsCapability.txt"
                if ($CurrentOSBuild -eq "26100") {
                    $ArgumentList = "/Image=C:\ /Get-Capabilities"
                    $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow -RedirectStandardOutput (Join-Path $logDirectory 'Get-WindowsCapability.txt') -RedirectStandardError $null
                }
                else {
                    $Report = Get-WindowsCapability -Path C:\ -ErrorAction Stop | Select-Object * | Sort-Object Name
                    $Report | Select-Object Name, State | Out-File -FilePath (Join-Path $logDirectory 'Get-WindowsCapability.txt') -Force -Encoding ascii
                }
            }
            catch {
            }
        }

        if (Get-Command Get-WindowsEdition -ErrorAction Ignore) {
            try {
                Write-DarkGrayHost "Export Windows Edition to $logDirectory\Get-WindowsEdition.txt"
                $Report = Get-WindowsEdition -Path C:\ -ErrorAction Stop | Select-Object * | Sort-Object Edition
                $Report | Select-Object Edition | Out-File -FilePath (Join-Path $logDirectory 'Get-WindowsEdition.txt') -Force -Encoding ascii
            }
            catch {
            }
        }

        if (Get-Command Get-WindowsOptionalFeature -ErrorAction Ignore) {
            try {
                Write-DarkGrayHost "Export Windows Optional Features to $logDirectory\Get-WindowsOptionalFeature.txt"
                $Report = Get-WindowsOptionalFeature -Path C:\ -ErrorAction Stop | Select-Object * | Sort-Object FeatureName
                $Report | Select-Object FeatureName, State | Out-File -FilePath (Join-Path $logDirectory 'Get-WindowsOptionalFeature.txt') -Force -Encoding ascii
            }
            catch {
            }
        }

        if (Get-Command Get-WindowsPackage -ErrorAction Ignore) {
            try {
                Write-DarkGrayHost "Export Windows Packages to $logDirectory\Get-WindowsPackage.txt"
                if ($CurrentOSBuild -eq "26100") {
                    $ArgumentList = "/Image=C:\ /Get-Packages"
                    $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow -RedirectStandardOutput (Join-Path $logDirectory 'Get-WindowsPackage.txt') -RedirectStandardError $null
                }
                else {
                    $Report = Get-WindowsPackage -Path C:\ -ErrorAction Stop | Select-Object * | Sort-Object PackageName
                    $Report | Select-Object PackageName, PackageState, ReleaseType | Out-File -FilePath (Join-Path $logDirectory 'Get-WindowsPackage.txt') -Force -Encoding ascii
                }
            }
            catch {
            }
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
