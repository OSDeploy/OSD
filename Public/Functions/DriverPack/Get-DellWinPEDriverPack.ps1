function Get-DellWinPEDriverPack {
    <#
    .SYNOPSIS
    Returns the URL of the latest Dell WinPE 10 Driver Pack 

    .DESCRIPTION
    Download and expand WinPE Drivers

    .EXAMPLE
    Get-DellWinPEDriverPack

    .EXAMPLE
    $DellWinPEDriverPack = Get-DellWinPEDriverPack

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param ()

    $WinPEDriverPacks = 'https://www.dell.com/support/kbdoc/en-us/000107478/dell-command-deploy-winpe-driver-packs'
    try {
        $null = Invoke-WebRequest -Uri $WinPEDriverPacks -Method Head -UseBasicParsing -ErrorAction Stop
        Write-Verbose "Online: $WinPEDriverPacks"
        $CurrentDriverPackPage = (Invoke-WebRequest -Uri $WinPEDriverPacks -UseBasicParsing -Method Get).Links | Where-Object {$_.href -like 'https://www.dell.com/support/kbdoc/*/winpe-10*driver*'} | Select-Object -ExpandProperty href
    }
    catch {
        Write-Verbose "Offline: $WinPEDriverPacks"
    }

    if ($CurrentDriverPackPage) {
        try {
            $null = Invoke-WebRequest -Uri $CurrentDriverPackPage -Method Head -UseBasicParsing -ErrorAction Stop
            Write-Verbose "Online: $CurrentDriverPackPage"
            $CurrentDriverPack = (Invoke-WebRequest -Uri $CurrentDriverPackPage -UseBasicParsing -Method Get).Links | Where-Object {$_.outerHTML -match 'Download Now'} | Select-Object -ExpandProperty href
            $CurrentDriverPack = $CurrentDriverPack.Replace('dl.dell.com', 'downloads.dell.com')
        }
        catch {
            Write-Verbose "Offline: $CurrentDriverPackPage"
        }
    }

    if ($CurrentDriverPack) {
        try {
            $null = Invoke-WebRequest -Uri $CurrentDriverPack -Method Head -UseBasicParsing -ErrorAction Stop
            Write-Verbose "Online: $CurrentDriverPack"
            Return $CurrentDriverPack
        }
        catch {
            Write-Verbose "Offline: $CurrentDriverPack"
        }
    }

    Write-Verbose "Trying last known good Dell WinPE Driver Pack"
    $LastKnownGood = 'https://downloads.dell.com/FOLDER07703466M/1/WinPE10.0-Drivers-A25-F0XPX.CAB'
    try {
        $null = Invoke-WebRequest -Uri $LastKnownGood -Method Head -UseBasicParsing -ErrorAction Stop
        Write-Verbose "Online: $LastKnownGood"
        Return $LastKnownGood
    }
    catch {
        Write-Verbose "Offline: $LastKnownGood"
    }
}