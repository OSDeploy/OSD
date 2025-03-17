function Copy-WinREWIM {
    <#
    .SYNOPSIS
    Copies the Windows Recovery Environment WIM to the specified DestinationDirectory

    .DESCRIPTION
    Copies the Windows Recovery Environment WIM to the specified DestinationDirectory
    This function must be run in Windows

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        [System.String]
        #Directory to save the Windows Recovery Environment WIM
        #Default: $env:Temp\sources
        $DestinationDirectory = "$env:Temp\sources",

        [System.String]
        #File Name of the Windows Recovery WIM
        #Default: winre.wim
        $DestinationFileName = 'winre.wim'
    )
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #	GetPartitionWinRE
    #=================================================
    $GetPartitionWinRE = Get-WinREPartition -ErrorAction Stop
    #$GetPartitionWinRE | Select-Object -Property * | Format-List
    
    if ($GetPartitionWinRE) {
        #=================================================
        #	Get WinrePartitionDriveLetter
        #=================================================
        if ($GetPartitionWinRE.DriveLetter) {
            $CreateNewDriveLetter = $false
            $WinrePartitionDriveLetter = $GetPartitionWinRE.DriveLetter
        }
        else {
            $CreateNewDriveLetter = $true
            $WinrePartitionDriveLetter = (68..90 | ForEach-Object {$L=[char]$_; if ((Get-PSDrive).Name -notContains $L) {$L}})[0]
            Get-WinREPartition | Set-Partition -NewDriveLetter $WinrePartitionDriveLetter -Verbose
        }
        Write-Verbose "WinrePartitionDriveLetter: $WinrePartitionDriveLetter"
        #=================================================
        #	Get WinreLocationPath
        #=================================================
        $WinreLocationPath = (Get-ReAgentXml).WinreLocationPath
        Write-Verbose "WinreLocationPath: $WinreLocationPath"
        #=================================================
        #	Get WinreDirectory
        #=================================================
        $WinreDirectory = Join-Path "$($WinrePartitionDriveLetter):" -ChildPath $WinreLocationPath
        Write-Verbose "WinreDirectory: $WinreDirectory"

        if (!(Test-Path $DestinationDirectory)) {
            $null = New-Item -Path $DestinationDirectory -ItemType Directory -Force -ErrorAction SilentlyContinue
        }

        if (Test-Path "$WinreDirectory" -PathType Container -ErrorAction Ignore) {
            $WinreSource = Join-Path $WinreDirectory -ChildPath 'winre.wim'
            Write-Verbose "WinreSource: $WinreSource"

            robocopy "$WinreDirectory" "$DestinationDirectory" winre.wim /np /ndl /nfl /njh /njs
        }

        $WinreDestination = Join-Path $DestinationDirectory -ChildPath $DestinationFileName

        if ($DestinationFileName -ne 'winre.wim') {
            if (Test-Path $WinreDestination) {
                Remove-Item -Path $WinreDestination -Force -Verbose
            }
            Rename-Item -Path (Join-Path $DestinationDirectory -ChildPath 'winre.wim') -NewName $DestinationFileName -Verbose
        }
        #=================================================
        #	Remove Drive Letter
        #=================================================
        if ($CreateNewDriveLetter) {
            Remove-PartitionAccessPath -DiskNumber $GetPartitionWinRE.DiskNumber -PartitionNumber $GetPartitionWinRE.PartitionNumber -AccessPath "$($WinrePartitionDriveLetter):"
        }
        #=================================================
        #	Return WinreDestination Get-Item
        #=================================================
        if (Test-Path $WinreDestination -ErrorAction Ignore) {
            (Get-Item -Path $WinreDestination -Force).Attributes = 'Archive'
            Get-Item -Path $WinreDestination
        }
    }
}
function Get-ReAgentXml {
    <#
    .SYNOPSIS
    Returns information from the Reagent XML file

    .DESCRIPTION
    Returns information from the Reagent XML file
    This function must be run in Windows

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #	ReAgent.xml
    #=================================================
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

            if ($WinreLocationId -gt 1000) {
                $WinreLocationPartition = (Get-Disk | Where-Object {$_.Signature -eq $WinreLocationId} | Get-Partition | Where-Object {$_.Offset -eq $WinreLocationOffset}).PartitionNumber
            }
            else {
                $WinreLocationPartition = (Get-Disk -Number $WinreLocationId | Get-Partition | Where-Object {$_.Offset -eq $WinreLocationOffset}).PartitionNumber
            }


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
function Get-WinREPartition {
    <#
    .SYNOPSIS
    Returns the Partition containing Windows Recovery Environment WIM

    .DESCRIPTION
    Returns the Partition containing Windows Recovery Environment WIM
    This function must be run in Windows

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Partition')]
    param ()

    $WinrePartitionOffset = (Get-ReAgentXml).WinreLocationOffset

    $Results = Get-Partition | Where-Object {$_.Offset -match $WinrePartitionOffset}
    $Results[0]
}
