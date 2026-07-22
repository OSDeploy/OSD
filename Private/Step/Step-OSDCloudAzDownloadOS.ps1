function Step-OSDCloudAzDownloadOS {
    <#
    .SYNOPSIS
    Downloads the selected Azure Storage Windows image to the local OSDCloud cache.

    .DESCRIPTION
    Uses the current $Global:OSDCloud.AzOSDCloudImage object to build a destination path,
    exports blob metadata to logs, and downloads the image when needed. If a local copy
    already exists and matches the Azure blob length, the download is skipped.

    .EXAMPLE
    Step-OSDCloudAzDownloadOS
    Downloads the Azure OSDCloud image to C:\OSDCloud\Azure and updates ImageFileDestination.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Extracted Azure Storage OS image download step from Invoke-RecastOSDCloud
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    if ($env:SystemDrive -ne 'X:') {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    if ($Global:OSDCloud.AzOSDCloudImage) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCloud Azure Storage Windows Image Download"

        $Global:OSDCloud.DownloadDirectory = "C:\OSDCloud\Azure\$($Global:OSDCloud.AzOSDCloudImage.BlobClient.AccountName)\$($Global:OSDCloud.AzOSDCloudImage.BlobClient.BlobContainerName)"
        $Global:OSDCloud.DownloadName = Split-Path $Global:OSDCloud.AzOSDCloudImage.Name -Leaf
        $Global:OSDCloud.DownloadFullName = "$($Global:OSDCloud.DownloadDirectory)\$($Global:OSDCloud.DownloadName)"

        # Export image metadata for troubleshooting and audit history.
        $Global:OSDCloud.AzOSDCloudImage | ConvertTo-Json | Out-File -FilePath 'C:\OSDCloud\Logs\AzOSDCloudImage.json' -Encoding ascii -Width 2000

        $ParamGetAzStorageBlobContent = @{
            CloudBlob = $Global:OSDCloud.AzOSDCloudImage.ICloudBlob
            Context = $Global:OSDCloud.AzOSDCloudImage.Context
            Destination = $Global:OSDCloud.DownloadFullName
            Force = $true
            ErrorAction = 'Stop'
        }

        $ParamGetItem = @{
            Path = $Global:OSDCloud.DownloadFullName
            ErrorAction = 'Stop'
        }

        $ParamNewItem = @{
            Path = $Global:OSDCloud.DownloadDirectory
            ItemType = 'Directory'
            Force = $true
            ErrorAction = 'Stop'
        }

        if (Test-Path $Global:OSDCloud.DownloadFullName) {
            Write-DarkGrayHost -Message "$($Global:OSDCloud.DownloadFullName) already exists"

            $Global:OSDCloud.ImageFileDestination = Get-Item @ParamGetItem | Select-Object -First 1 | Select-Object -First 1

            if ($Global:OSDCloud.AzOSDCloudImage.Length -eq $Global:OSDCloud.ImageFileDestination.Length) {
                Write-DarkGrayHost -Message 'Destination file size matches Azure Storage, skipping previous download'
            }
            else {
                Write-DarkGrayHost -Message 'Existing file does not match Azure Storage, downloading updated file'

                try {
                    Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
                }
                catch {
                    Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
                }
            }
        }
        else {
            if (-not (Test-Path "$($Global:OSDCloud.DownloadDirectory)")) {
                Write-DarkGrayHost -Message "Creating directory $($Global:OSDCloud.DownloadDirectory)"
                $null = New-Item @ParamNewItem
            }

            try {
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
            catch {
                Get-AzStorageBlobContent @ParamGetAzStorageBlobContent
            }
        }

        $Global:OSDCloud.ImageFileDestination = Get-Item @ParamGetItem | Select-Object -First 1 | Select-Object -First 1
    }
    #=================================================
}
