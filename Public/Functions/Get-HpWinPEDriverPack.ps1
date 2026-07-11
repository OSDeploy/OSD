function Get-HpWinPEDriverPack {
    <#
    .SYNOPSIS
    Returns the URL of the latest HP WinPE 10 Driver Pack 

    .DESCRIPTION
    Download and expand WinPE Drivers

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param ()

    # WinPE Driver Packs
    # https://ftp.hp.com/pub/caps-softpaq/cmit/HP_WinPE_DriverPack.html

    # WinPE 10
    # http://ftp.ext.hp.com/pub/caps-softpaq/cmit/softpaq/WinPE10.html

    # WinPE 11
    # http://ftp.ext.hp.com/pub/caps-softpaq/cmit/softpaq/WinPE11.html

    $LastKnownGood = $Global:OSDModuleResource.WinPEDriverPack.HP.LastKnownGood
    $DriverPackInfoUrl = $Global:OSDModuleResource.WinPEDriverPack.HP.Info

    Write-Verbose $DriverPackInfoUrl

    Try {
        (Invoke-WebRequest -Uri $DriverPackInfoUrl -UseBasicParsing -Method Get).Links | Where-Object {$_.href -like '*.hp.com/pub/softpaq/*/*.exe'} | Select-Object -ExpandProperty href
    }
    Catch {
        Write-Output $LastKnownGood
    }
}