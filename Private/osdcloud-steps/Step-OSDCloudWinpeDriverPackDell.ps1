function Step-OSDCloudWinpeDriverPackDell {
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
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Expand Dell DriverPack to $ExpandPath"

    $null = New-Item -Path $ExpandPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    Start-Process -FilePath $FileInfo.FullName -ArgumentList "/s /e=`"$ExpandPath`"" -Wait

    Add-WindowsDriver -Path "C:\" -Driver $ExpandPath -Recurse -ForceUnsigned -LogPath "$LogPath\drivers-driverpack.log" -ErrorAction SilentlyContinue | Out-Null
        
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Removing driverpack download and expanded drivers"
    Remove-Item -Path $ExpandPath -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Drivers" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\osdcloud\drivers-driverpack-download" -Recurse -Force -ErrorAction SilentlyContinue
    #=================================================
    # End the function
    $Message = "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    Write-Verbose -Message $Message; Write-Debug -Message $Message
    #=================================================
}