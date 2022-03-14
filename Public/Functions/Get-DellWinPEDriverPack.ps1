function Get-DellWinPEDriverPack {
    <#
    .SYNOPSIS
    Returns the URL of the latest Dell WinPE 10 Driver Pack 

    .DESCRIPTION
    Download and expand WinPE Drivers

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param ()

    $LastKnownGood = 'https://downloads.dell.com/FOLDER07703466M/1/WinPE10.0-Drivers-A25-F0XPX.CAB'
    $DriverPackInfoUrl = 'https://www.dell.com/support/kbdoc/en-us/000107478/dell-command-deploy-winpe-driver-packs'

    Write-Verbose $DriverPackInfoUrl

    Try {
        $results = (Invoke-WebRequest -Uri $DriverPackInfoUrl -UseBasicParsing -Method Get).Links | Where-Object {$_.href -like 'https://www.dell.com/support/kbdoc/*/winpe-10*driver*'} | Select-Object -ExpandProperty href
        (Invoke-WebRequest -Uri $results -UseBasicParsing -Method Get).Links | Where-Object {$_.outerHTML -match 'Download Now'} | Select-Object -ExpandProperty href
    }
    Catch {
        Write-Output $LastKnownGood
    }
}