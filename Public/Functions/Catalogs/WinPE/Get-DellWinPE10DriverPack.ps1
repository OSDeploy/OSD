<#
.SYNOPSIS
Returns the URL of the latest Dell WinPE 10 Driver Pack 

.DESCRIPTION
Returns the URL of the latest Dell WinPE 10 Driver Pack 

.EXAMPLE
Get-DellWinPE10DriverPack

.EXAMPLE
$DellWinPEDriverPack = Get-DellWinPE10DriverPack

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Get-DellWinPE10DriverPack {
    [CmdletBinding()]
    param ()

    $WinPEDriverPacks = $Global:OSDModuleResource.WinPEDriverPack.Dell.Info
    try {
        $null = Invoke-WebRequest -Uri $WinPEDriverPacks -Method Head -UseBasicParsing -ErrorAction Stop
        Write-Verbose "DriverPack Info Online: $WinPEDriverPacks"
        $CurrentDriverPackPage = (Invoke-WebRequest -Uri $WinPEDriverPacks -UseBasicParsing -Method Get).Links | Where-Object {$_.href -like 'https://www.dell.com/support/kbdoc/*/winpe-10*driver*'} | Select-Object -ExpandProperty href
    }
    catch {
        Write-Warning "DriverPack Info Offline: $WinPEDriverPacks"
    }

    if ($CurrentDriverPackPage) {
        try {
            $null = Invoke-WebRequest -Uri $CurrentDriverPackPage -Method Get -UseBasicParsing -ErrorAction Stop
            Write-Verbose "DriverPack Page Online: $CurrentDriverPackPage"
            $CurrentDriverPack = (Invoke-WebRequest -Uri $CurrentDriverPackPage -UseBasicParsing -Method Get).Links | Where-Object {$_.href -like '*.CAB'} | Select-Object -ExpandProperty href
            $CurrentDriverPack = $CurrentDriverPack.Replace('dl.dell.com', 'downloads.dell.com')
        }
        catch {
            Write-Warning "DriverPack Page Offline: $CurrentDriverPackPage"
        }
    }

    if ($CurrentDriverPack) {
        try {
            $null = Invoke-WebRequest -Uri $CurrentDriverPack -Method Head -UseBasicParsing -ErrorAction Stop
            Write-Verbose "DriverPack Online: $CurrentDriverPack"
            Return $CurrentDriverPack
        }
        catch {
            Write-Warning "DriverPack Offline: $CurrentDriverPack"
        }
    }

    Write-Verbose "Trying last known good Dell WinPE Driver Pack"
    $LastKnownGood = $Global:OSDModuleResource.WinPEDriverPack.Dell.LastKnownGood10
    try {
        $null = Invoke-WebRequest -Uri $LastKnownGood -Method Head -UseBasicParsing -ErrorAction Stop
        Write-Verbose "DriverPack LastKnownGood Online: $LastKnownGood"
        Return $LastKnownGood
    }
    catch {
        Write-Warning "DriverPack LastKnownGood Offline: $LastKnownGood"
    }
}