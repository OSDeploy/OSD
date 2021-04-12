function Get-PartitionWinRE {
    [CmdletBinding()]
    param ()

    $WinrePartitionOffset = (Get-ReAgentXml).WinreLocationOffset

    $Results = Get-Partition | Where-Object {$_.Offset -match $WinrePartitionOffset}
    $Results
}

function Copy-WinRE.wim {
    [CmdletBinding()]
    param (
        [string]$DestinationDirectory =$env:TEMP,

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

        New-PSDrive -Name WinRE -PSProvider FileSystem -Root $GetPartitionWinRE.AccessPaths[0] -ErrorAction Stop | Out-Null

        $WinreDirectory = Join-Path 'WinRE:' $WinreLocationPath
        Write-Verbose "WinreDirectory: $WinreDirectory"

        if (Test-Path $WinreDirectory) {
            $WinreSource = Join-Path $WinreDirectory 'winre.wim'
            Write-Verbose "WinreSource: $WinreSource"

            if (!(Test-Path $DestinationDirectory)) {
                New-Item $DestinationDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }

            $WinreDestination = Join-Path $DestinationDirectory $DestinationFileName
            Write-Verbose "WinreDestination: $WinreDestination"


            $GetItemWinre = Get-Item -Path $WinreSource -Force
            Copy-Item -Path $GetItemWinre.FullName -Destination $WinreDestination -Force
        }
        Get-PSDrive -Name WinRE | Remove-PSDrive -Force

        if (Test-Path $WinreDestination) {
            (Get-Item -Path $WinreDestination -Force).Attributes = 'Archive'
            Get-Item -Path $WinreDestination
        }
    }
}