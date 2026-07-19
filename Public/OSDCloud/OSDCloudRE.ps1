function Get-OSDCloudREAzureResources {
    <#
    .SYNOPSIS
    OSDCloudRE: Discovers Azure storage resources used for OSDCloudRE boot images.

    .DESCRIPTION
    OSDCloudRE: Queries Azure storage accounts tagged for OSDCloud, discovers BootImage containers,
    and stores matching ISO blob metadata in global variables for downstream OSDCloudRE workflows.

    .EXAMPLE
    Get-OSDCloudREAzureResources
    Connects to Azure and populates OSDCloudRE Azure storage and boot image variables.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added in-function comment-based help block.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Get-OSDCloudREAzureResources"

    if ($env:SystemDrive -eq 'X:') {
        $OSDCloudLogs = "$env:SystemDrive\OSDCloud\Logs"
        if (-not (Test-Path $OSDCloudLogs)) {
            New-Item $OSDCloudLogs -ItemType Directory -Force | Out-Null
        }
    }

    if ($Global:AzContext) {
        #Write-Host -ForegroundColor DarkGray    'Storage Accounts:          $Global:AzStorageAccounts'
        $Global:AzStorageAccounts = Get-AzStorageAccount
        if ($OSDCloudLogs) {
            #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $OSDCloudLogs\AzStorageAccounts.json"
            $Global:AzStorageAccounts | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageAccounts.json" -Encoding ascii -Width 2000 -Force
        }

        #Write-Host -ForegroundColor DarkGray    'OSDCloud Storage Accounts: $Global:AzOSDCloudStorageAccounts'
        $Global:AzOSDCloudStorageAccounts = Get-AzStorageAccount | Where-Object {$_.Tags.ContainsKey('OSDCloud')}
        #$Global:AzOSDCloudStorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts'
        #$Global:AzOSDCloudStorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' | Where-Object {$_.Tags.ContainsKey('OSDCloud')}
        if ($OSDCloudLogs) {
            #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $OSDCloudLogs\AzOSDCloudStorageAccounts.json"
            $Global:AzOSDCloudStorageAccounts | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudStorageAccounts.json" -Encoding ascii -Width 2000 -Force
        }

        $Global:AzStorageContext = @{}
        $Global:AzOSDCloudBlobBootImage = @()
        $Global:AzOSDCloudBootImage = @()

        if ($Global:AzOSDCloudStorageAccounts) {
            #Write-Host -ForegroundColor DarkGray    'Storage Contexts:          $Global:AzStorageContext'
            #Write-Host -ForegroundColor DarkGray    'Blob Windows Images:       $Global:AzOSDCloudBlobImage'
            #Write-Host ''
            Write-Host -ForegroundColor Cyan "Searching Azure Storage for OSDCloudRE Resources"
            foreach ($Item in $Global:AzOSDCloudStorageAccounts) {
                $Global:AzCurrentStorageContext = New-AzStorageContext -StorageAccountName $Item.StorageAccountName
                $Global:AzStorageContext."$($Item.StorageAccountName)" = $Global:AzCurrentStorageContext
                #Get-AzStorageBlobByTag -TagFilterSqlExpression ""osdcloudimage""=""win10ltsc"" -Context $StorageContext
                #Get-AzStorageBlobByTag -Context $Global:AzCurrentStorageContext

                $AzOSDCloudStorageContainers = Get-AzStorageContainer -Context $Global:AzCurrentStorageContext
                if ($OSDCloudLogs) {
                    #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $OSDCloudLogs\AzOSDCloudStorageContainers.json"
                    $Global:AzOSDCloudStorageContainers | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudStorageContainers.json" -Encoding ascii -Width 2000 -Force
                }

                if ($AzOSDCloudStorageContainers) {
                    foreach ($Container in $AzOSDCloudStorageContainers) {
                        if ($Container.Name -eq 'BootImage') {
                            Write-Host -ForegroundColor DarkGray "BootImage Container: $($Item.StorageAccountName)/$($Container.Name)"
                            $Global:AzOSDCloudBlobBootImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.iso -ErrorAction Ignore

                        }
                    }
                }
            }
            if ($OSDCloudLogs) {
                $Global:AzStorageContext | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageContext.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobBootImage| ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobDriverPack.json" -Encoding ascii -Width 2000 -Force
            }
            if ($null -eq $Global:AzOSDCloudBlobBootImage) {
                Write-Warning 'Unable to find a Boot Image on any of the OSDCloud Azure Storage Containers'
                Write-Warning 'Make sure you have a ISO Boot Image in the OSDCloud Azure Storage Container named BootImage'
                Write-Warning 'Make sure this user has the Azure Storage Blob Data Reader role to the OSDCloud Container'
                Write-Warning 'You may need to execute Get-OSDCloudAzureResources then Start-OSDCloudAzure'
                Break
            }
        }
        else {
            Write-Warning 'Unable to find any Azure Storage Accounts'
            Write-Warning 'Make sure the OSDCloud Azure Storage Account has an OSDCloud Tag'
            Write-Warning 'Make sure this user has the Azure Reader role on the OSDCloud Azure Storage Account'
            Break
        }
    }
    else {
        Write-Warning 'Unable to connect to AzureAD'
        Write-Warning 'You may need to execute Connect-OSDCloudAzure then Start-OSDCloudAzure'
        Break
    }
}
function Get-OSDCloudREPartition {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE Partition object

    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE Partition object

    .EXAMPLE
    Get-OSDCloudREPartition

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Partition')]
    param ()
    Write-Verbose $MyInvocation.MyCommand

    Get-OSDCloudREVolume | Get-Partition
}
function Get-OSDCloudREPSDrive {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE PSDrive object

    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE PSDrive object

    .EXAMPLE
    Get-OSDCloudREPSDrive

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSDriveInfo])]
    param ()
    Write-Verbose $MyInvocation.MyCommand

    Get-PSDrive | Where-Object {$_.Description -eq 'OSDCloudRE'}
}
function Get-OSDCloudREVolume {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE Volume object

    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE Volume object

    .EXAMPLE
    Get-OSDCloudREVolume

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Volume')]
    param ()
    Write-Verbose $MyInvocation.MyCommand

    Get-Volume | Where-Object {$_.FileSystemLabel -match 'OSDCloudRE'}
}
function Hide-OSDCloudREDrive {
    <#
    .SYNOPSIS
    OSDCloudRE: Hides the OSDCloudRE Drive

    .DESCRIPTION
    OSDCloudRE: Hides the OSDCloudRE Drive

    .EXAMPLE
    Hide-OSDCloudREDrive

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    [OutputType([System.Void])]
    param ()
    Write-Verbose $MyInvocation.MyCommand

    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
        return
    }
    $OSDCloudREPartition = Get-OSDCloudREPartition

    if ($OSDCloudREPartition) {
$null = @"
select disk $($OSDCloudREPartition.DiskNumber)
select partition $($OSDCloudREPartition.PartitionNumber)
remove
set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
gpt attributes=0x8000000000000001
exit
"@ | diskpart.exe
    }
    else {
        Write-Warning "[$(Get-Date -format s)] Unable to find an OSDCloudRE partition"
    }
}
function Invoke-OSDCloudRE {
    <#
    .SYNOPSIS
    This is the master OSDCloudRE Task Sequence

    .DESCRIPTION
    This is the master OSDCloudRE Task Sequence

    .EXAMPLE
    Invoke-OSDCloudRE
    Runs the full OSDCloudRE provisioning sequence using current global configuration.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES and EXAMPLE to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
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

    if ($Global:OSDCloudRE.AzOSDCloudBootImage -eq $false) {
        Write-Warning "[$(Get-Date -format s)] A Boot Image is required to fun this function"
        Break
    }

    $Global:OSDCloudRE.DownloadDirectory = "$env:SystemDrive\OSDCloud\Azure\$($Global:OSDCloudRE.AzOSDCloudBootImage.BlobClient.AccountName)\$($Global:OSDCloudRE.AzOSDCloudBootImage.BlobClient.BlobContainerName)"
    $Global:OSDCloudRE.DownloadName = $(Split-Path $Global:OSDCloudRE.AzOSDCloudBootImage.Name -Leaf)
    $Global:OSDCloudRE.DownloadFullName = "$($Global:OSDCloudRE.DownloadDirectory)\$($Global:OSDCloudRE.DownloadName)"
    #endregion
    #=================================================
    #region Test Admin Rights
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Test Admin Rights"
    if ($Global:OSDCloudRE.IsAdmin -eq $false) {
        Write-Warning "[$(Get-Date -format s)] OSDCloudRE requires elevated Admin Rights"
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
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Test PowerShell Execution Policy"
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
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers -Force -SkipPublisherCheck
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

        $GetAzStorageBlobContentParam = @{
            CloudBlob = $Global:OSDCloudRE.AzOSDCloudBootImage.ICloudBlob
            Context = $Global:OSDCloudRE.AzOSDCloudBootImage.Context
            Destination = $Global:OSDCloudRE.DownloadFullName
            Force = $true
        }

        $NewItemParam = @{
            Force = $true
            ItemType = 'Directory'
            Path = $Global:OSDCloudRE.DownloadDirectory
        }

        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "[$(Get-Date -format s)] OSDCloud Azure Storage Boot Image Download"

        $Global:OSDCloudRE.AzOSDCloudBootImage | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBootImage.json" -Encoding ascii -Width 2000 -Force

        if (Test-Path $Global:OSDCloudRE.DownloadFullName) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($Global:OSDCloudRE.DownloadFullName) already exists"

            $Global:OSDCloudRE.BootImage = Get-Item -Path $Global:OSDCloudRE.DownloadFullName -ErrorAction Stop | Select-Object -First 1 | Select-Object -First 1

            if ($Global:OSDCloudRE.AzOSDCloudBootImage.Length -eq ($Global:OSDCloudRE.BootImage.Length)) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Destination file size matches Azure Storage, skipping previous download"
            }
            else {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Existing file does not match Azure Storage, downloading updated file"
                try {
                    Get-AzStorageBlobContent @GetAzStorageBlobContentParam -ErrorAction Stop
                }
                catch {
                    Get-AzStorageBlobContent @GetAzStorageBlobContentParam -ErrorAction Stop
                }
            }
        }
        else {
            if (-not (Test-Path "$($Global:OSDCloudRE.DownloadDirectory)")) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Creating directory $($Global:OSDCloudRE.DownloadDirectory)"
                $null = New-Item @NewItemParam -ErrorAction Ignore
            }
            try {
                Get-AzStorageBlobContent @GetAzStorageBlobContentParam -ErrorAction Stop
            }
            catch {
                Get-AzStorageBlobContent @GetAzStorageBlobContentParam -ErrorAction Stop
            }
        }

        $Global:OSDCloudRE.BootImage = Get-Item -Path $Global:OSDCloudRE.DownloadFullName -ErrorAction Stop | Select-Object -First 1 | Select-Object -First 1
    }

    if (! $Global:OSDCloudRE.BootImage) {
        Break
    }
    #endregion
    #=================================================
    #region OSDCloudISO downloaded
    if ($Global:OSDCloudRE.BootImage -and $Global:OSDCloudRE.BootImage.Extension -eq '.iso') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCloudISO downloaded to $($Global:OSDCloudRE.BootImage.FullName)"
    }
    else {
        Write-Warning "[$(Get-Date -format s)] Unable to download OSDCloudISO"
        Break
    }

    #endregion
    #============================================
    #region Mounting OSDCloudISO
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Mounting OSDCloudISO"
    $Global:OSDCloudRE.MountDiskImage = Mount-DiskImage -ImagePath $Global:OSDCloudRE.BootImage.FullName

    Start-Sleep -Seconds 5

    $Global:OSDCloudRE.MountDiskImageDriveLetter = (Compare-Object -ReferenceObject $Global:OSDCloudRE.Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject

    if ($Global:OSDCloudRE.MountDiskImageDriveLetter) {
        $Global:OSDCloudRE.MountDiskImagePath = "$($Global:OSDCloudRE.MountDiskImageDriveLetter):\"
    }
    else {
        Write-Warning "[$(Get-Date -format s)] Unable to mount $($Global:OSDCloudRE.BootImage.FullName)"
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
            Write-Warning "[$(Get-Date -format s)] Unable to suspend BitLocker for next boot"
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] BitLocker is suspended for the next boot"
        }
    }
    #endregion
    #============================================
    #region Creating a new OSDCloudRE volume
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Creating a new OSDCloudRE volume"
    $Global:OSDCloudRE.Volume = New-OSDCloudREVolume -IsoSize $Global:OSDCloudRE.AzOSDCloudBootImage.Length -ErrorAction Stop
    #endregion
    #============================================
    #region Test OSDCloudRE PSDrive
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Test OSDCloudRE PSDrive"
    $Global:OSDCloudRE.PSDrive = Get-OSDCloudREPSDrive

    if (! $Global:OSDCloudRE.PSDrive) {
       Write-Error "[$(Get-Date -format s)] Unable to find OSDCloudRE PSDrive"
        Break
    }
    #endregion
    #============================================
    #region Test OSDCloudRE Root
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Test OSDCloudRE Root"
    $Global:OSDCloudRE.PSDriveRoot = ($Global:OSDCloudRE.PSDrive).Root
    if (-NOT (Test-Path $Global:OSDCloudRE.PSDriveRoot)) {
       Write-Error "[$(Get-Date -format s)] Unable to find OSDCloudRE Root at $($Global:OSDCloudRE.PSDriveRoot)"
        Break
    }
    #endregion
    #============================================
    #region Update WinPE Volume
    if ((Test-Path -Path $Global:OSDCloudRE.MountDiskImagePath) -and (Test-Path -Path $Global:OSDCloudRE.PSDriveRoot)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Copying $($Global:OSDCloudRE.MountDiskImagePath) to OSDCloud WinPE partition at $($Global:OSDCloudRE.PSDriveRoot)"
        $null = robocopy "$($Global:OSDCloudRE.MountDiskImagePath)" "$($Global:OSDCloudRE.PSDriveRoot)" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
    }
    else {
       Write-Error "[$(Get-Date -format s)] Unable to copy Media to OSDCloudRE"
        Break
    }
    #endregion
    #============================================
    #region Remove Read-Only Attribute
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing Read Only attributes in $($Global:OSDCloudRE.PSDriveRoot)"
    Get-ChildItem -Path $Global:OSDCloudRE.PSDriveRoot -File -Recurse -Force -ErrorAction Ignore | foreach {
        Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -Force -ErrorAction Ignore
    }
    #endregion
    #============================================
    #region Dismounting ISO
    if ($Global:OSDCloudRE.MountDiskImage.ImagePath) {
        Start-Sleep -Seconds 3
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Dismounting ISO at $($Global:OSDCloudRE.MountDiskImage.ImagePath)"
        $null = Dismount-DiskImage -ImagePath $Global:OSDCloudRE.MountDiskImage.ImagePath
    }
    #endregion
    #============================================
    #region Get-OSDCloudREVolume
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Testing OSDCloudRE Volume"
    if (! (Get-OSDCloudREVolume)) {
        Write-Warning "[$(Get-Date -format s)] Could not create OSDCloudRE"
        Break
    }
    #endregion
    #============================================
    #region Set-OSDCloudREBCD
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Set OSDCloudRE Ramdisk: Set-OSDCloudREBootmgr -SetRamdisk"
    Set-OSDCloudREBootmgr -SetRamdisk
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Set OSDCloudRE OSLoader: Set-OSDCloudREBootmgr -SetOSloader"
    Set-OSDCloudREBootmgr -SetOSloader
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Hiding OSDCloudRE volume"
    Hide-OSDCloudREDrive
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Set OSDCloudRE to restart on next boot: Set-OSDCloudREBootmgr -BootToOSDCloudRE"
    Set-OSDCloudREBootmgr -BootToOSDCloudRE
    Write-Host -ForegroundColor Cyan "[$(Get-Date -format s)] OSDCloudRE setup is complete"
    if ($Global:OSDCloudRE.Restart) {
        Write-Warning "Windows is restarting in 10 seconds"
        Write-Warning "Press CTRL + C to cancel"
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
    #endregion
    #============================================
}
function New-OSDCloudREVolume {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE Partition object

    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE Partition object

    .EXAMPLE
    New-OSDCloudREVolume

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Volume')]
    param (
        [int32]$IsoSize = 1038090240
    )
    Write-Verbose $MyInvocation.MyCommand

    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
        return
    }

    $WindowsPartition = Get-Partition | Where-Object {$env:SystemDrive -match $_.DriveLetter}
    $WindowsDiskNumber = $WindowsPartition.DiskNumber
    $WindowsSizeMax = $WindowsPartition | Get-PartitionSupportedSize | Select-Object -ExpandProperty SizeMax
    $WindowsShrinkSize = $WindowsSizeMax - $IsoSize - 200MB
    $OSDCloudREVolume = Get-OSDCloudREVolume
    #============================================
    #	Test WindowsPartition
    #============================================
    if ($WindowsPartition) {
        #============================================
        #	Test UEFI
        #============================================
        if ((Get-OSDGather -Property IsUEFI)) {
            #============================================
            #	Test if OSDCloudRE already exists
            #============================================
            if (! $OSDCloudREVolume) {
                #============================================
                #	Shrink Windows Partition
                #============================================
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Shrinking Windows partition"
                $WindowsPartition | Resize-Partition -Size $WindowsShrinkSize
                #============================================
                #	Test WindowsPartition
                #   Get Results
                #============================================
                if ($WindowsPartition) {
                    #============================================
                    #   Create NewPartition
                    #============================================
                    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Creating OSDCloudRE Partition"
                    $Global:NewPartition = New-Partition -DiskNumber $WindowsDiskNumber -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -UseMaximumSize
                    #============================================
                    #   Test NewPartition
                    #============================================
                    if ($Global:NewPartition) {
                        #============================================
                        #	Test NewPartitionNumber
                        #============================================
                        $Global:NewPartitionNumber = $Global:NewPartition.PartitionNumber
                        #============================================
                        #	Format Partition
                        #============================================
                        if ($Global:NewPartitionNumber) {

                            $Global:FormatVolume = Format-Volume -Partition $Global:NewPartition -FileSystem NTFS -NewFileSystemLabel 'OSDCloudRE' -Force
                            $Global:PartitionAccessPath = Add-PartitionAccessPath -AccessPath O: -DiskNumber $Global:NewPartition.DiskNumber -PartitionNumber $Global:NewPartition.PartitionNumber

                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Testing OSDCloudRE Volume"
                            #============================================
                            #	Return Results
                            #============================================
                            if (Get-OSDCloudREVolume) {
                                Get-OSDCloudREVolume
                            }
                            else {
                               Write-Error "[$(Get-Date -format s)] Could not create OSDCloudRE volume"
                            }
                        }
                        else {
                           Write-Error "[$(Get-Date -format s)] Unable to get OSDCloudRE partition DiskNumber"
                        }
                    }
                    else {
                       Write-Error "[$(Get-Date -format s)] Unable to create an OSDCloudRE partition"
                    }
                }
                else {
                   Write-Error "[$(Get-Date -format s)] Unable to shink Windows partition"
                }
            }
            else {
               Write-Error "[$(Get-Date -format s)] Cannot create a second OSDCloudRE instance"
            }
        }
        else {
           Write-Error "[$(Get-Date -format s)] OSDCloudRE requires UEFI"
        }
    }
    else {
       Write-Error "[$(Get-Date -format s)] Unable to find the Windows Partition"
    }
}
function Set-OSDCloudREBootmgr {
    <#
    .SYNOPSIS
    OSDCloudRE: Configures OSDCloudRE Boot Manager options

    .DESCRIPTION
    OSDCloudRE: Configures OSDCloudRE Boot Manager options. Requires ADMIN righs

    .EXAMPLE
    Set-OSDCloudREBootmgr -SetRamdisk -SetOSloader
    Creates or updates the OSDCloudRE Ramdisk and OSLoader
    Requires boot content in O:\

    .EXAMPLE
    Set-OSDCloudREBootmgr -OSMenuAdd
    Adds OSDCloudRE to the Boot Manager Operating System selection

    .EXAMPLE
    Set-OSDCloudREBootmgr -OSMenuRemove
    Removes OSDCloudRE from the Boot Manager Operating System selection

    .EXAMPLE
    Set-OSDCloudREBootmgr -BootToOSDCloudRE
    Boots to OSDCloudRE on the next reboot

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [System.Management.Automation.SwitchParameter]
        #Creates or updates the OSDCloudRE Ramdisk
        $SetRamdisk,

        [System.Management.Automation.SwitchParameter]
        #Creates or updates the OSDCloudRE OSLoader
        $SetOSloader,

        [System.Management.Automation.SwitchParameter]
        #Adds OSDCloudRE to the Boot Manager Operating System selection
        $OSMenuAdd,

        [System.Management.Automation.SwitchParameter]
        #Removes OSDCloudRE from the Boot Manager Operating System selection
        $OSMenuRemove,

        [System.Management.Automation.SwitchParameter]
        #Boots to OSDCloudRE on the next reboot
        $BootToOSDCloudRE
    )
    Write-Verbose $MyInvocation.MyCommand

    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
        return
    }

    if ($SetRamdisk -or $SetOSloader) {
        $OSDCloudREPartition = Get-OSDCloudREPartition
        if (! $OSDCloudREPartition) {
            Write-Warning "[$(Get-Date -format s)] Unable to find OSDCloudRE Partition"
        }
    }

    if ($SetRamdisk) {
        if ($OSDCloudREPartition) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /create '{4f534452-616d-6469-736b-536567757261}' /d OSDRamdisk /device"
            $null = bcdedit /create '{4f534452-616d-6469-736b-536567757261}' /d "OSDRamdisk" /device
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /set '{4f534452-616d-6469-736b-536567757261}' ramdisksdidevice partition=O:"
            $null = bcdedit /set '{4f534452-616d-6469-736b-536567757261}' ramdisksdidevice partition=O:
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /set '{4f534452-616d-6469-736b-536567757261}' ramdisksdipath \boot\boot.sdi"
            $null = bcdedit /set '{4f534452-616d-6469-736b-536567757261}' ramdisksdipath \boot\boot.sdi
        }
    }

    if ($SetOSloader) {
        if ($OSDCloudREPartition) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /create '{4f534443-6c6f-7564-5245-536567757261}' /d OSDCloudRE /application osloader"
            $null = bcdedit /create '{4f534443-6c6f-7564-5245-536567757261}' /d "OSDCloudRE" /application osloader
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' device ramdisk=[O:]\sources\boot.wim,'{4f534452-616d-6469-736b-536567757261}'"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' device ramdisk=[O:]\sources\boot.wim,'{4f534452-616d-6469-736b-536567757261}'
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' osdevice ramdisk=[O:]\sources\boot.wim,'{4f534452-616d-6469-736b-536567757261}'"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' osdevice ramdisk=[O:]\sources\boot.wim,'{4f534452-616d-6469-736b-536567757261}'
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' path \windows\system32\winload.efi"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' path \windows\system32\winload.efi
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' systemroot \Windows"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' systemroot \Windows
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' detecthal Yes"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' detecthal Yes
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' winpe Yes"
            $null = bcdedit /set '{4f534443-6c6f-7564-5245-536567757261}' winpe Yes
        }
    }

    if ($OSMenuAdd) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /displayorder '{4f534443-6c6f-7564-5245-536567757261}' /addlast"
        $null = bcdedit /displayorder '{4f534443-6c6f-7564-5245-536567757261}' /addlast
    }

    if ($OSMenuRemove) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /displayorder '{4f534443-6c6f-7564-5245-536567757261}' /remove"
        $null = bcdedit /displayorder '{4f534443-6c6f-7564-5245-536567757261}' /remove
    }

    if ($BootToOSDCloudRE) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] bcdedit /bootsequence '{4f534443-6c6f-7564-5245-536567757261}'"
        try {
            $null = bcdedit /bootsequence '{4f534443-6c6f-7564-5245-536567757261}'
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCloudRE set for next boot"
        }
        catch {
            Write-Warning "[$(Get-Date -format s)] OSDCloudRE could not be set for next boot"
        }
    }
}
function Show-OSDCloudREDrive {
    <#
    .SYNOPSIS
    OSDCloudRE: Shows the OSDCloudRE Drive

    .DESCRIPTION
    OSDCloudRE: Shows the OSDCloudRE Drive

    .EXAMPLE
    Show-OSDCloudREDrive

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    [OutputType([System.Void])]
    param ()
    Write-Verbose $MyInvocation.MyCommand

    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required"
        return
    }
    $OSDCloudREPartition = Get-OSDCloudREPartition

    if ($OSDCloudREPartition) {
$null = @"
select disk $($OSDCloudREPartition.DiskNumber)
select partition $($OSDCloudREPartition.PartitionNumber)
set id="ebd0a0a2-b9e5-4433-87c0-68b6b72699c7"
gpt attributes=0x0000000000000000
assign letter=o
rescan
exit
"@ | diskpart.exe
    }
    else {
        Write-Warning "[$(Get-Date -format s)] Unable to find an OSDCloudRE partition"
    }
}
function Start-OSDCloudREAzure {
    <#
    .SYNOPSIS
    OSDCloudRE: Creates a new OSDCloudRE Volume from Azure

    .DESCRIPTION
    OSDCloudRE: Creates a new OSDCloudRE Volume from Azure

    .EXAMPLE
    Start-OSDCloudREAzure

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added NOTES to align with OSD help standards.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        #Clears previous variables
        $Force
    )
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OSDCloudREAzure"

    if ($env:SystemDrive -ne 'X:') {
        if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
            Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)

            Connect-OSDCloudAzure
            Get-OSDCloudREAzureResources

            if ($Global:AzOSDCloudBlobBootImage) {
                & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudREAzure\MainWindow.ps1"
                Start-Sleep -Seconds 2

                if ($Global:StartOSDCloudRE.AzOSDCloudBootImage) {
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                    Write-Host -ForegroundColor Green "Invoke-OSDCloudRE"
                    Invoke-OSDCloudRE
                }
                else {
                    Write-Warning "Unable to get an ISO Boot Image from Start-OSDCloudREAzure"
                }
            }
            else {
                Write-Warning 'Start-OSDCloudREAzure could not find any Boot Images in Azure'
                Break
            }
        }
        else {
            Write-Warning 'Start-OSDCloudREAzure must be run with Admin Rights'
            Break
        }
    }
    else {
        Write-Warning "Start-OSDCloudREAzure must be run from Windows"
        Break
    }
}
