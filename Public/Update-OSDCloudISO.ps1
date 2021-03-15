function Update-OSDCloudISO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MediaDirectory
    )
    begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #===================================================================================================
        #   Require cURL
        #===================================================================================================
        if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
            Write-Warning "$($MyInvocation.MyCommand) could not find $env:SystemRoot\System32\curl.exe"
            Write-Warning "Get a newer Windows version!"
            Break
        }
        #===================================================================================================
        #   Get Variables
        #===================================================================================================
        $WinPEArch = 'amd64'
        $GetMyAdk = Get-MyAdk -Arch $WinPEArch

        if ($null -eq $GetMyAdk) {
            Write-Warning "Could not get ADK going, sorry"
            Break
        }
        #===================================================================================================
    }
    process {
        $ISODirectory = (Get-Item -Path $MediaDirectory).Parent.FullName

        $ISOLabel = '-l"{0}"' -f "OSDCloud"

        $ISOFile = Join-Path $ISODirectory 'OSDCloud.iso'
        Write-Verbose "ISOFile: $ISOFile"

        $OSCDIMG = $GetMyAdk.PathOscdimg
        Write-Verbose "OSCDIMG: $OSCDIMG"

        $OSCDIMGexe = Join-Path $OSCDIMG 'oscdimg.exe'
        Write-Verbose "OSCDIMGexe: $OSCDIMGexe"

        robocopy "$OSCDIMG" "$MediaDirectory\boot" etfsboot.com /ndl /nfl /njh /njs /b
        $etfsboot = "$MediaDirectory\boot\etfsboot.com"
        Write-Verbose "etfsboot: $etfsboot"

        robocopy "$OSCDIMG" "$MediaDirectory\efi\microsoft\boot" efisys.bin /ndl /nfl /njh /njs /b
        $efisys = "$MediaDirectory\efi\microsoft\boot\efisys.bin"
        Write-Verbose "efisys: $efisys"
        #$efisys = "$MediaDirectory\efi\microsoft\boot\efisys.bin"

        $data = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f $etfsboot, $efisys
        Write-Verbose "data: $data"

        Write-Verbose "Creating ISO at $ISOFile" -Verbose
        Start-Process $OSCDIMGexe -args @("-m","-o","-u2","-bootdata:$data",'-u2','-udfver102',$ISOLabel,"`"$MediaDirectory`"", "`"$ISOFile`"") -Wait
        explorer $ISODirectory
    }
    end {}
}