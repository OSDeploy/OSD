<#
.SYNOPSIS
Creates an .iso file from a bootable media directory.  ADK is required

.Description
Creates a .iso file from a bootable media directory.  ADK is required

.PARAMETER MediaPath
Directory containing the bootable media

.PARAMETER isoFileName
File Name of the ISO

.PARAMETER isoLabel
Label of the ISO.  Limited to 16 characters

.PARAMETER OpenExplorer
Opens Windows Explorer to the parent directory of the ISO File

.LINK
https://osd.osdeploy.com/module/functions/adk

.NOTES
21.3.16     Initial Release
#>
function New-ADK.iso {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MediaPath,

        [Parameter(Mandatory = $true)]
        [string]$isoFileName,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1,16)]
        [string]$isoLabel,

        #[switch]$NoPrompt,
        #[switch]$Mount,
        [switch]$OpenExplorer
    )
    #=======================================================================
    #	Require WinOS
    #=======================================================================
    if ((Get-OSDGather -Property IsWinPE)) {
        Write-Warning "$($MyInvocation.MyCommand) cannot be run from WinPE"
        Break
    }
    #=======================================================================
    #   Require Admin Rights
    #=======================================================================
    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
        Break
    }
    #=======================================================================
    #	Set VerbosePreference
    #=======================================================================
    $CurrentVerbosePreference = $VerbosePreference
    $VerbosePreference = 'Continue'
    #=======================================================================
    #   Get Adk Paths
    #=======================================================================
    $AdkPaths = Get-AdkPaths

    if ($null -eq $AdkPaths) {
        Write-Warning "Could not get ADK going, sorry"
        Break
    }
    #=======================================================================
    $WorkspacePath = (Get-Item -Path $MediaPath -ErrorAction Stop).Parent.FullName
    $IsoFullName = Join-Path $WorkspacePath $isoFileName
    $PathOscdimg = $AdkPaths.PathOscdimg
    $oscdimgexe = $AdkPaths.oscdimgexe

    Write-Verbose "WorkspacePath: $WorkspacePath"
    Write-Verbose "IsoFullName: $IsoFullName"
    Write-Verbose "PathOscdimg: $PathOscdimg"
    Write-Verbose "oscdimgexe: $oscdimgexe"
    #=======================================================================
    #   Test Paths
    #=======================================================================
    $DestinationBoot = Join-Path $MediaPath 'boot'
    if (-NOT (Test-Path $DestinationBoot)) {
        Write-Warning "Cannot locate $DestinationBoot"
        Write-Warning "This does not appear to be a valid bootable ISO"
        Break
    }
    $DestinationEfiBoot = Join-Path $MediaPath 'efi\microsoft\boot'
    if (-NOT (Test-Path $DestinationEfiBoot)) {
        Write-Warning "Cannot locate $DestinationEfiBoot"
        Write-Warning "This does not appear to be a valid bootable ISO"
        Break
    }
    #=======================================================================
    #   etfsboot.com
    #=======================================================================
    $etfsbootcom = $AdkPaths.etfsbootcom
    Copy-Item -Path $etfsbootcom -Destination $DestinationBoot -Force -ErrorAction Stop
    $Destinationetfsbootcom = Join-Path $DestinationBoot 'etfsboot.com'
    #=======================================================================
    #   efisys.bin and efisys_noprompt.bin
    #=======================================================================
    $efisysbin = $AdkPaths.efisysbin
    Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
    $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys.bin'

    $efisysnopromptbin = $AdkPaths.efisysnopromptbin
    Copy-Item -Path $efisysnopromptbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
    $Destinationefisysnopromptbin = Join-Path $DestinationEfiBoot 'efisys_noprompt.bin'

<#     if ($PSBoundParameters.ContainsKey('NoPrompt')) {
        $efisysbin = $AdkPaths.efisysnopromptbin
        Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
        $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys_noprompt.bin'
    } else {
        $efisysbin = $AdkPaths.efisysbin
        Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
        $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys.bin'
    } #>

    Write-Verbose "DestinationBoot: $DestinationBoot"
    Write-Verbose "etfsbootcom: $etfsbootcom"
    Write-Verbose "Destinationetfsbootcom: $Destinationetfsbootcom"

    Write-Verbose "DestinationEfiBoot: $DestinationEfiBoot"
    Write-Verbose "efisysbin: $efisysbin"
    Write-Verbose "Destinationefisysbin: $Destinationefisysbin"
    Write-Verbose "efisysnopromptbin: $efisysnopromptbin"
    Write-Verbose "Destinationefisysnopromptbin: $Destinationefisysnopromptbin"
    #=======================================================================
    #   Strings
    #=======================================================================
    $isoLabelString = '-l"{0}"' -f "$isoLabel"
    Write-Verbose "isoLabelString: $isoLabelString"
    #=======================================================================
    #   Prompt
    #=======================================================================
    $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$Destinationetfsbootcom", "$Destinationefisysbin"
    Write-Verbose "BootDataString: $BootDataString"

    $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2","-bootdata:$BootDataString",'-u2','-udfver102',$isoLabelString,"`"$MediaPath`"", "`"$IsoFullName`"") -PassThru -Wait -NoNewWindow

    if (-NOT (Test-Path $IsoFullName)) {
        Write-Error "Something didn't work"
        Break
    }
    $PromptIso = Get-Item -Path $IsoFullName
    #=======================================================================
    #   NoPrompt
    #=======================================================================
    $IsoFullName = "$($PromptIso.Directory)\$($PromptIso.BaseName)_NoPrompt.iso"
    $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$Destinationetfsbootcom", "$Destinationefisysnopromptbin"
    Write-Verbose "BootDataString: $BootDataString"

    $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2","-bootdata:$BootDataString",'-u2','-udfver102',$isoLabelString,"`"$MediaPath`"", "`"$IsoFullName`"") -PassThru -Wait -NoNewWindow

    if (-NOT (Test-Path $IsoFullName)) {
        Write-Error "Something didn't work"
        Break
    }
    #=======================================================================
    #   Restore VerbosePreference
    #=======================================================================
    $VerbosePreference = $CurrentVerbosePreference
    #=======================================================================
    #   OpenExplorer
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('OpenExplorer')) {
        explorer $WorkspacePath
    }
    #=======================================================================
    #   Mount
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('Mount')) {
        explorer $IsoFullName
    }
    #=======================================================================
    #   Return Get-Item
    #=======================================================================
    Return $PromptIso

<#     $Results += [pscustomobject]@{
        FullName            = $IsoFullName
        Name                = $isoFileName
        Label               = $isoLabel
        isoDirectory     = $MediaPath
    }
    Return $Results #>
    #=======================================================================
}