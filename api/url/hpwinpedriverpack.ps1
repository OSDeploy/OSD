[CmdletBinding()]
param ()

$LastKnownGood = 'https://ftp.ext.hp.com/pub/softpaq/sp142501-143000/sp142621.exe'
$DriverPackInfoUrl = 'http://ftp.ext.hp.com/pub/caps-softpaq/cmit/softpaq/WinPE10.html'

Write-Verbose $DriverPackInfoUrl

Try {
    (Invoke-WebRequest -Uri $DriverPackInfoUrl -UseBasicParsing -Method Get).Links | Where-Object {$_.href -like '*ftp.ext.hp.com/pub/softpaq/*/*.exe'} | Select-Object -ExpandProperty href
}
Catch {
    Write-Output $LastKnownGood
}