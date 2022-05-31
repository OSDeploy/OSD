#This function is not exposed
function Invoke-OSDCloudRE {
    <#
    .SYNOPSIS
    This is the master OSDCloudRE Task Sequence
    
    .DESCRIPTION
    This is the master OSDCloudRE Task Sequence
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    #region Master Parameters
    $Global:OSDCloudRE = $null
    $Global:OSDCloudRE = [ordered]@{
        AzContext = $Global:AzContext
        AzOSDCloudBlobBootImage = $Global:AzOSDCloudBlobBootImage
        AzOSDCloudBootImage = $Global:AzOSDCloudBootImage
        AzStorageAccounts = $Global:AzStorageAccounts
        AzStorageContext = $Global:AzStorageContext
        BootImage = $null
        BuildName = 'OSDCloudRE'
        Debug = $false
        DownloadDirectory = $null
        DownloadName = $null
        DownloadFullName = $null
        Function = $MyInvocation.MyCommand.Name
        IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
        IsOnBattery = $(Get-OSDGather -Property IsOnBattery)
        IsVirtualMachine = $(Test-IsVM)
        MountDiskImage = $null
        MountDiskImageDriveLetter = $null
        MountDiskImagePath = $null
        PSDrive = $null
        PSDriveRoot = $null
        Restart = [bool]$false
        Shutdown = [bool]$false
        Test = [bool]$false
        TimeEnd = $null
        TimeSpan = $null
        TimeStart = Get-Date
        Transcript = $null
        Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
        Volume = $null
        Volumes = (Get-Volume).Where({$_.DriveLetter}).DriveLetter
    }
    #endregion
    #=================================================
    #region Merge Parameters
    if ($Global:StartOSDCloudRE) {
        foreach ($Key in $Global:StartOSDCloudRE.Keys) {
            $Global:OSDCloudRE.$Key = $Global:StartOSDCloudRE.$Key
        }
    }
    if ($Global:MyOSDCloudRE) {
        foreach ($Key in $Global:MyOSDCloudRE.Keys) {
            $Global:OSDCloudRE.$Key = $Global:MyOSDCloudRE.$Key
        }
    }
    #endregion
    #=================================================
    #region Set Post-Merge Defaults
    $Global:OSDCloudRE.Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version

    $Global:OSDCloudRE.DownloadDirectory = "$env:SystemDrive\OSDCloud\Azure\$($Global:OSDCloudRE.AzOSDCloudBootImage.BlobClient.AccountName)\$($Global:OSDCloudRE.AzOSDCloudBootImage.BlobClient.BlobContainerName)"
    $Global:OSDCloudRE.DownloadName = $(Split-Path $Global:OSDCloudRE.AzOSDCloudBootImage.Name -Leaf)
    $Global:OSDCloudRE.DownloadFullName = "$($Global:OSDCloudRE.DownloadDirectory)\$($Global:OSDCloudRE.DownloadName)"
    #endregion
    #=================================================
    if ($Global:OSDCloudRE.AzOSDCloudBootImage -eq $false) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) A Boot Image is required to fun this function"
        Break
    }
    #=================================================
    #region Test Admin Rights
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test Admin Rights"
    if ($Global:OSDCloudRE.IsAdmin -eq $false) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE requires elevated Admin Rights"
        Break
    }
    #endregion
    #=================================================
    #region OSDCloudLogs
    if ($env:SystemDrive -eq 'X:') {
        $OSDCloudLogs = "$env:SystemDrive\OSDCloud\Logs"
        if (-not (Test-Path $OSDCloudLogs)) {
            New-Item $OSDCloudLogs -ItemType Directory -Force | Out-Null
        }
    }
    #endregion
    #=================================================
    #region Test PowerShell Execution Policy
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test PowerShell Execution Policy"
    if ((Get-ExecutionPolicy) -ne 'RemoteSigned') {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
    }
    #endregion
    #=================================================
    #region OSD Module
    $InstallModule = $false
    $PSModuleName = 'OSD'
    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore -WarningAction Ignore

    if ($GalleryPSModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers -Force
            Import-Module $PSModuleName -Force
        }
    }
    #endregion
    #=================================================
    #region Final Warning
    Write-Warning "OSDCloudRE will be created in 10 seconds"
    Write-Warning "Press CTRL + C to cancel"
    Start-Sleep -Seconds 10
    #endregion
    #=================================================
    #region Azure Storage Image Download
    if ($Global:OSDCloudRE.AzOSDCloudBootImage) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Azure Storage Boot Image Download"
        $Global:OSDCloudRE.AzOSDCloudBootImage | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBootImage.json" -Encoding ascii -Width 2000

        $null = New-Item -Path $Global:OSDCloudRE.DownloadDirectory -ItemType Directory -Force -ErrorAction Ignore

        Get-AzStorageBlobContent -CloudBlob $Global:OSDCloudRE.AzOSDCloudBootImage.ICloudBlob -Context $Global:OSDCloudRE.AzOSDCloudBootImage.Context -Destination $Global:OSDCloudRE.DownloadFullName -ErrorAction Ignore
        $Global:OSDCloudRE.BootImage = Get-Item -Path $Global:OSDCloudRE.DownloadFullName -ErrorAction Ignore | Select-Object -First 1 | Select-Object -First 1
    }
    if (! $Global:OSDCloudRE.BootImage) {
        Break
    }
    #endregion
    #=================================================
    #region OSDCloudISO downloaded
    if ($Global:OSDCloudRE.BootImage -and $Global:OSDCloudRE.BootImage.Extension -eq '.iso') {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudISO downloaded to $($Global:OSDCloudRE.BootImage.FullName)"
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to download OSDCloudISO"
        Break
    }

    #endregion
    #============================================
    #region Mounting OSDCloudISO
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mounting OSDCloudISO"
    $Global:OSDCloudRE.MountDiskImage = Mount-DiskImage -ImagePath $Global:OSDCloudRE.BootImage.FullName

    Start-Sleep -Seconds 5
    
    $Global:OSDCloudRE.MountDiskImageDriveLetter = (Compare-Object -ReferenceObject $Global:OSDCloudRE.Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject
    
    if ($Global:OSDCloudRE.MountDiskImageDriveLetter) {
        $Global:OSDCloudRE.MountDiskImagePath = "$($Global:OSDCloudRE.MountDiskImageDriveLetter):\"
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to mount $($Global:OSDCloudRE.BootImage.FullName)"
        Break
    }
    #endregion
    #============================================
    #region Suspend BitLocker
    #https://docs.microsoft.com/en-us/windows/security/information-protection/bitlocker/bcd-settings-and-bitlocker
    $BitLockerVolumes = Get-BitLockerVolume | Where-Object {($_.ProtectionStatus -eq 'On') -and ($_.VolumeType -eq 'OperatingSystem')} -ErrorAction Ignore
    if ($BitLockerVolumes) {
        $BitLockerVolumes | Suspend-BitLocker -RebootCount 1 -ErrorAction Ignore
    
        if (Get-BitLockerVolume -MountPoint $BitLockerVolumes | Where-Object ProtectionStatus -eq "On") {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to suspend BitLocker for next boot"
        }
        else {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) BitLocker is suspended for the next boot"
        }
    }
    #endregion
    #============================================
    #region Creating a new OSDCloudRE volume
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating a new OSDCloudRE volume"
    $Global:OSDCloudRE.Volume = New-OSDCloudREVolume -Verbose -ErrorAction Stop
    #endregion
    #============================================
    #region Test OSDCloudRE PSDrive
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test OSDCloudRE PSDrive"
    $Global:OSDCloudRE.PSDrive = Get-OSDCloudREPSDrive
    
    if (! $Global:OSDCloudRE.PSDrive) {
        Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find OSDCloudRE PSDrive"
        Break
    }
    #endregion
    #============================================
    #region Test OSDCloudRE Root
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test OSDCloudRE Root"
    $Global:OSDCloudRE.PSDriveRoot = ($Global:OSDCloudRE.PSDrive).Root
    if (-NOT (Test-Path $Global:OSDCloudRE.PSDriveRoot)) {
        Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find OSDCloudRE Root at $($Global:OSDCloudRE.PSDriveRoot)"
        Break
    }
    #endregion
    #============================================
    #region Update WinPE Volume
    if ((Test-Path -Path $Global:OSDCloudRE.MountDiskImagePath) -and (Test-Path -Path $Global:OSDCloudRE.PSDriveRoot)) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($Global:OSDCloudRE.MountDiskImagePath) to OSDCloud WinPE partition at $($Global:OSDCloudRE.PSDriveRoot)"
        $null = robocopy "$($Global:OSDCloudRE.MountDiskImagePath)" "$($Global:OSDCloudRE.PSDriveRoot)" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
    }
    else {
        Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to copy Media to OSDCloudRE"
        Break
    }
    #endregion
    #============================================
    #region Remove Read-Only Attribute
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Removing Read Only attributes in ($Global:OSDCloudRE.PSDriveRoot)"
    Get-ChildItem -Path $Global:OSDCloudRE.PSDriveRoot -File -Recurse -Force -ErrorAction Ignore | foreach {
        Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -Force -ErrorAction Ignore
    }
    #endregion
    #============================================
    #region Dismounting ISO
    if ($Global:OSDCloudRE.MountDiskImage.ImagePath) {
        Start-Sleep -Seconds 3
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Dismounting ISO at $($Global:OSDCloudRE.MountDiskImage.ImagePath)"
        $null = Dismount-DiskImage -ImagePath $Global:OSDCloudRE.MountDiskImage.ImagePath
    }
    #endregion
    #============================================
    #region Get-OSDCloudREVolume
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Testing OSDCloudRE Volume"
    if (! (Get-OSDCloudREVolume)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not create OSDCloudRE"
        Break
    }
    #endregion
    #============================================
    #region Set-OSDCloudREBCD
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set OSDCloudRE Ramdisk: Set-OSDCloudREBootmgr -SetRamdisk"
    Set-OSDCloudREBootmgr -SetRamdisk
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set OSDCloudRE OSLoader: Set-OSDCloudREBootmgr -SetOSloader"
    Set-OSDCloudREBootmgr -SetOSloader
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Hiding OSDCloudRE volume"
    Hide-OSDCloudREDrive
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set OSDCloudRE to restart on next boot: Set-OSDCloudREBootmgr -BootToOSDCloudRE"
    Set-OSDCloudREBootmgr -BootToOSDCloudRE
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE setup is complete"
    if ($Global:OSDCloudRE.Restart) {
        Write-Warning "Windows is restarting in 10 seconds"
        Write-Warning "Press CTRL + C to cancel"
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
    #endregion
    #============================================
}