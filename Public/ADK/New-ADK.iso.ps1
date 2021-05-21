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
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)"
	#=======================================================================
	#	Blocks
	#=======================================================================
	Block-WinPE
	Block-StandardUser
    Block-PowerShellVersionLt5
    #=======================================================================
    #   Get Adk Paths
    #=======================================================================
    $AdkPaths = Get-AdkPaths

    if ($null -eq $AdkPaths) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "Could not get ADK going, sorry"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting Paths"

    $WorkspacePath = (Get-Item -Path $MediaPath -ErrorAction Stop).Parent.FullName
    $IsoFullName = Join-Path $WorkspacePath $isoFileName
    $PathOscdimg = $AdkPaths.PathOscdimg
    $oscdimgexe = $AdkPaths.oscdimgexe

    Write-Host -ForegroundColor DarkGray "WorkspacePath: $WorkspacePath"
    Write-Host -ForegroundColor DarkGray "IsoFullName: $IsoFullName"
    Write-Host -ForegroundColor DarkGray "PathOscdimg: $PathOscdimg"
    Write-Host -ForegroundColor DarkGray "oscdimgexe: $oscdimgexe"
    #=======================================================================
    #   Test Paths
    #=======================================================================
    $DestinationBoot = Join-Path $MediaPath 'boot'
    if (-NOT (Test-Path $DestinationBoot)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "Cannot locate $DestinationBoot"
        Write-Warning "This does not appear to be a valid bootable ISO"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    $DestinationEfiBoot = Join-Path $MediaPath 'efi\microsoft\boot'
    if (-NOT (Test-Path $DestinationEfiBoot)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "Cannot locate $DestinationEfiBoot"
        Write-Warning "This does not appear to be a valid bootable ISO"
        Write-Host -ForegroundColor DarkGray "========================================================================="
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

    Write-Host -ForegroundColor DarkGray  "DestinationBoot: $DestinationBoot"
    Write-Host -ForegroundColor DarkGray  "etfsbootcom: $etfsbootcom"
    Write-Host -ForegroundColor DarkGray  "Destinationetfsbootcom: $Destinationetfsbootcom"

    Write-Host -ForegroundColor DarkGray  "DestinationEfiBoot: $DestinationEfiBoot"
    Write-Host -ForegroundColor DarkGray  "efisysbin: $efisysbin"
    Write-Host -ForegroundColor DarkGray  "Destinationefisysbin: $Destinationefisysbin"
    Write-Host -ForegroundColor DarkGray  "efisysnopromptbin: $efisysnopromptbin"
    Write-Host -ForegroundColor DarkGray  "Destinationefisysnopromptbin: $Destinationefisysnopromptbin"
    #=======================================================================
    #   Strings
    #=======================================================================
    $isoLabelString = '-l"{0}"' -f "$isoLabel"
    Write-Host -ForegroundColor DarkGray  "isoLabelString: $isoLabelString"
    #=======================================================================
    #   Create Prompt ISO
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating Prompt ISO"
    $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$Destinationetfsbootcom", "$Destinationefisysbin"
    Write-Host -ForegroundColor DarkGray  "BootDataString: $BootDataString"

    $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2","-bootdata:$BootDataString",'-u2','-udfver102',$isoLabelString,"`"$MediaPath`"", "`"$IsoFullName`"") -PassThru -Wait -NoNewWindow

    if (-NOT (Test-Path $IsoFullName)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Error "Something didn't work"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    $PromptIso = Get-Item -Path $IsoFullName
    Write-Host -ForegroundColor DarkGray  "PromptIso: $PromptIso"
    #=======================================================================
    #   Create NoPrompt ISO
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating NoPrompt ISO"
    $IsoFullName = "$($PromptIso.Directory)\$($PromptIso.BaseName)_NoPrompt.iso"
    $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$Destinationetfsbootcom", "$Destinationefisysnopromptbin"
    Write-Host -ForegroundColor DarkGray  "BootDataString: $BootDataString"

    $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2","-bootdata:$BootDataString",'-u2','-udfver102',$isoLabelString,"`"$MediaPath`"", "`"$IsoFullName`"") -PassThru -Wait -NoNewWindow

    if (-NOT (Test-Path $IsoFullName)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Error "Something didn't work"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    $NoPromptIso = Get-Item -Path $IsoFullName
    Write-Host -ForegroundColor DarkGray  "NoPromptIso: $NoPromptIso"
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