function Step-OSDCloudWinpeDriverPackLenovo {
    [CmdletBinding()]
    param (
        [System.IO.FileInfo]$FileInfo
    )
    #=================================================
    # Start the step
    $Message = "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Debug -Message $Message; Write-Verbose -Message $Message
    #=================================================
    $ExpandPath = 'C:\Windows\Temp\osdcloud\drivers-driverpack'
    if (-not (Test-Path "$ExpandPath")) {
        New-Item $ExpandPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }

    $ScriptsPath = "C:\Windows\Setup\Scripts"
    if (-not (Test-Path $ScriptsPath)) {
        New-Item -Path $ScriptsPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }
    
    $LogPath = "C:\Windows\Temp\osdcloud-logs"
    if (-not (Test-Path -Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
    
    $SetupCompleteCmd = "$ScriptsPath\SetupComplete.cmd"
    $SetupSpecializeCmd = "C:\Windows\Temp\osdcloud\SetupSpecialize.cmd"
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] FileDescription: $($FileInfo.VersionInfo.FileDescription)"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ProductVersion: $($FileInfo.VersionInfo.ProductVersion)"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding Lenovo DriverPack to $SetupCompleteCmd"

$Content = @"
:: ========================================================
:: OSDCloud DriverPack Installation for Lenovo
:: ========================================================
$($FileInfo.FullName) /SILENT /SUPPRESSMSGBOXES
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" /v Path /t REG_SZ /d "C:\Drivers" /f
pnpunattend.exe AuditSystem /L
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\PnPUnattend\DriverPaths\1" /v Path /f
rd /s /q C:\Drivers
rd /s /q $ExpandPath
rd /s /q C:\Windows\Temp\osdcloud\drivers-driverpack-download
:: ========================================================
"@

    $Content | Out-File -FilePath $SetupSpecializeCmd -Append -Encoding ascii -Width 2000 -Force
    $ProvisioningPackage = Join-Path $(Get-OSDModulePath) "core\setupspecialize\setupspecialize.ppkg"

    if (Test-Path $ProvisioningPackage) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding Provisioning Package for SetupSpecialize"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] dism.exe /Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$ProvisioningPackage`""
        $ArgumentList = "/Image=C:\ /Add-ProvisioningPackage /PackagePath:`"$ProvisioningPackage`""
        $null = Start-Process -FilePath 'dism.exe' -ArgumentList $ArgumentList -Wait -NoNewWindow
    }
    #=================================================
    # End the function
    $Message = "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    Write-Verbose -Message $Message; Write-Debug -Message $Message
    #=================================================
}