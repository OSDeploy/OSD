function Step-OSDCloudWinpeCleanup {
    [CmdletBinding()]
    param (
        [System.IO.FileInfo]$FileInfo
    )
    #=================================================
    # Start the step
    $Message = "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Debug -Message $Message; Write-Verbose -Message $Message
    #=================================================
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)]"
    # Are we in WinPE
    if ($env:SystemDrive -ne 'X:') {
        return
    }

    # Always remove these items
    $FolderCleanup = @(
        'C:\OSDCloud\OS',
        'C:\OSDCloud\Temp'
    )
    foreach ($Item in $FolderCleanup) {
        try {
            Remove-Item -Path $Item -Recurse -Force -ErrorAction Stop
            # Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Removing $Item"
        }
        catch {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Unable to remove $Item"
        }
    }

    # Remove these folders if empty
    $EmptyFolderCleanup = @(
        'C:\Drivers'
        'C:\OSDCloud\Packages',
        'C:\OSDCloud\Scripts\SetupComplete',
        'C:\OSDCloud\Scripts',
        'C:\OSDCloud',
        'C:\Windows\Temp\osdcloud\drivers-disk',
        'C:\Windows\Temp\osdcloud\drivers-driverpack',
        'C:\Windows\Temp\osdcloud\drivers-driverpack-download'
        'C:\Windows\Temp\osdcloud\drivers-net',
        'C:\Windows\Temp\osdcloud\drivers-recast',
        'C:\Windows\Temp\osdcloud\drivers-scsi',
        'C:\Windows\Temp\osdcloud'
    )
    foreach ($Item in $EmptyFolderCleanup) {
        # Does the folder exist?
        if (-not (Test-Path $Item)) {
            Continue
        }

        # Does the folder have content?
        if (Get-ChildItem $Item) {
            Continue
        }

        # Cleanup folder
        try {
            Remove-Item -Path $Item -Recurse -Force -ErrorAction Stop
            # Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Removing $Item"
        }
        catch {
            # Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Unable to remove $Item"
        }
    }
    #=================================================
    # End the function
    $Message = "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    Write-Verbose -Message $Message; Write-Debug -Message $Message
    #=================================================
}