function New-MyAdkCopyPE {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('amd64','x86')]
        [string]$WinPEArch = 'amd64'


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
        #   Get Variables
        #===================================================================================================
        $MyAdk = Get-MyAdk -Arch $WinPEArch
        #===================================================================================================
    }
    process {
        $SOURCE = $MyAdk.PathWinPE
        $DEST = $Path
        $WIMSOURCEPATH = "$SOURCE\en-us\winpe.wim"
        $FWFILESROOT = $MyAdk.PathOscdimg

        $TEMPL = "media"
        $FWFILES = "fwfiles"


        if (-NOT (Test-Path (Join-Path $DEST $TEMPL))) {
            New-Item (Join-Path $DEST $TEMPL) -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        if (-NOT (Test-Path (Join-Path $DEST 'mount'))) {
            New-Item (Join-Path $DEST 'mount') -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        if (-NOT (Test-Path (Join-Path $DEST $FWFILES))) {
            New-Item (Join-Path $DEST $FWFILES) -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        xcopy /herky "$SOURCE\Media" "$DEST\$TEMPL\"

        $NewPath = "$DEST\$TEMPL\sources"
        if (-NOT (Test-Path $NewPath)) {
            New-Item $NewPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        copy "$WIMSOURCEPATH" "$DEST\$TEMPL\sources\boot.wim"
        copy "$FWFILESROOT\efisys.bin" "$DEST\$FWFILES"
        copy "$FWFILESROOT\etfsboot.com" "$DEST\$FWFILES"
    }
    end {}
}