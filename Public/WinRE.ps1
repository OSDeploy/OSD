function Copy-WinRE.wim {
    [CmdletBinding()]
    param (
        [string]$DestinationDirectory = $env:TEMP,

        [string]$DestinationFileName = 'winre.wim'
    )
    #=======================================================================
    #	Block
    #=======================================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=======================================================================
    #	Get WinRE
    #=======================================================================
    Write-Verbose "Get-PartitionWinRE"
    $GetPartitionWinRE = Get-PartitionWinRE
    
    if ($GetPartitionWinRE) {
        $WinreLocationPath = (Get-ReAgentXml).WinreLocationPath
        Write-Verbose "WinreLocationPath: $WinreLocationPath"

        try {
            New-PSDrive -Name WinRE -PSProvider FileSystem -Root $GetPartitionWinRE.AccessPaths[0] -ErrorAction Stop
        }
        catch {
            Write-Warning "Error connecting PSDrive to WinRE.wim"
        }

        $WinreDirectory = Join-Path 'WinRE:' -ChildPath $WinreLocationPath
        Write-Verbose "WinreDirectory: $WinreDirectory"

        if (Test-Path "$WinreDirectory" -PathType Container -ErrorAction Ignore) {
            $WinreSource = Join-Path $WinreDirectory -ChildPath 'winre.wim'
            Write-Verbose "WinreSource: $WinreSource"

            if (!(Test-Path $DestinationDirectory -ErrorAction Ignore)) {
                New-Item $DestinationDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }

            $WinreDestination = Join-Path $DestinationDirectory -ChildPath $DestinationFileName
            Write-Verbose "WinreDestination: $WinreDestination"


            $GetItemWinre = Get-Item -Path 'WinRE:\Recovery\WindowsRE\winre.wim' -Force
            Copy-Item -Path $GetItemWinre.FullName -Destination $WinreDestination -Force
        }
        #Get-PSDrive -Name WinRE | Remove-PSDrive -Force

        if (Test-Path $WinreDestination -ErrorAction Ignore) {
            (Get-Item -Path $WinreDestination -Force).Attributes = 'Archive'
            Get-Item -Path $WinreDestination
        }
    }
}
function Get-PartitionWinRE {
    [CmdletBinding()]
    param ()

    $WinrePartitionOffset = (Get-ReAgentXml).WinreLocationOffset

    $Results = Get-Partition | Where-Object {$_.Offset -match $WinrePartitionOffset}
    $Results
}
<#
.SYNOPSIS
Gathers information about from Get-ReAgentXml

.Description
Gathers information about from Get-ReAgentXml

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-ReAgentXml {
    [CmdletBinding()]
    param ()

    if (-NOT (Test-Path "$env:SystemRoot\System32\Recovery\ReAgent.xml")) {
        Write-Warning "Unable to find $env:SystemRoot\System32\Recovery\ReAgent.xml"
    }
    else {
        [xml]$XmlDocument = Get-content -Path "$env:SystemRoot\System32\Recovery\ReAgent.xml" -Raw

        $XmlDocument.SelectNodes('WindowsRE') | ForEach-Object {

            
            $WinreLocationGuid = $_.WinreLocation.guid
            $WinreLocationId = $_.WinreLocation.id
            $WinreLocationOffset = $_.WinreLocation.offset
            $WinreLocationPath = $_.WinreLocation.path

            $WinreLocationPartition = (Get-Disk -Number $WinreLocationId | Get-Partition | Where-Object {$_.Offset -eq $WinreLocationOffset}).PartitionNumber

            $WinreBCD = $_.WinreBCD.id -replace ('{','') -replace ('}','')

            $ReAgentInfo = [PSCustomObject]@{
                CustomImageAvailable = $_.CustomImageAvailable.state
                DownlevelWinreLocationGuid = $_.DownlevelWinreLocation.guid
                DownlevelWinreLocationId = $_.DownlevelWinreLocation.id
                DownlevelWinreLocationOffset = $_.DownlevelWinreLocation.offset
                DownlevelWinreLocationPath = $_.DownlevelWinreLocation.path
                ImageLocationGuid = $_.ImageLocation.guid
                ImageLocationId = $_.ImageLocation.id
                ImageLocationOffset = $_.ImageLocation.offset
                ImageLocationPath = $_.ImageLocation.path
                InstallState = $_.InstallState.state
                IsAutoRepairOn = $_.IsAutoRepairOn.state
                IsServer = $_.IsServer.state
                IsWimBoot = $_.IsWimBoot.state
                NarratorScheduled = $_.NarratorScheduled.state
                OemTool = $_.OemTool.state
                OperationParam = $_.OperationParam.path
                OperationPermanent = $_.OperationPermanent.state
                OsBuildVersion = $_.OsBuildVersion.path
                OsInstallAvailable = $_.OsInstallAvailable.state
                PBRCustomImageLocationGuid = $_.PBRCustomImageLocation.guid
                PBRCustomImageLocationId = $_.PBRCustomImageLocation.id
                PBRCustomImageLocationOffset = $_.PBRCustomImageLocation.offset
                PBRCustomImageLocationPath = $_.PBRCustomImageLocation.path
                PBRImageLocationGuid = $_.PBRImageLocation.guid
                PBRImageLocationId = $_.PBRImageLocation.id
                PBRImageLocationOffset = $_.PBRImageLocation.offset
                PBRImageLocationPath = $_.PBRImageLocation.path
                ScheduledOperation = $_.ScheduledOperation.state
                WinREStaged = $_.WinREStaged.state
                WinreBCD = $_.WinreBCD.id
                WinreLocationGuid = $WinreLocationGuid
                WinreLocationId = $WinreLocationId
                WinreLocationOffset = $WinreLocationOffset
                WinreLocationPath = $WinreLocationPath
                WindowsRElocation = '\\?\GLOBALROOT\device\harddisk' + $WinreLocationId + '\partition' + $WinreLocationPartition + $WinreLocationPath
                BootConfigurationDataBCD = $WinreBCD
            }
        }
        $ReAgentInfo
    }
}
