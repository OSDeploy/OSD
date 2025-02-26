function New-WindowsAdkISO {
    <#
        .SYNOPSIS
        Creates an .iso file from a bootable media directory.  ADK is required

        .DESCRIPTION
        Creates a .iso file from a bootable media directory.  ADK is required

        .NOTES
        David Segura
        25.2.26     Initial Release replacing New-AdkISO
    #>
    [CmdletBinding()]
    param (
        # Root path to the Windows ADK
        [Alias('AdkRoot')]
        [System.String]
        $WindowsAdkRoot,

        # Directory containing the bootable media
        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        # File Name of the ISO
        [Parameter(Mandatory = $true)]
        [System.String]
        $isoFileName,

        # Label of the ISO.  Limited to 16 characters
        [Parameter(Mandatory = $true)]
        [ValidateLength(1,16)]
        [System.String]
        $isoLabel,

        #[System.Management.Automation.SwitchParameter]$NoPrompt,
        #[System.Management.Automation.SwitchParameter]$Mount,

        # Opens Windows Explorer to the parent directory of the ISO File
        [System.Management.Automation.SwitchParameter]
        $OpenExplorer
    )
    #=================================================
    # Start
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
	#=================================================
	# Blocks
	Block-WinPE
	Block-StandardUser
    Block-PowerShellVersionLt5
    #=================================================
    # Get Adk Paths
    if ($AdkRoot) {
        $WindowsAdkPaths = Get-WindowsAdkPaths -AdkRoot $AdkRoot
    } else {
        $WindowsAdkPaths = Get-WindowsAdkPaths
    }
    if ($null -eq $WindowsAdkPaths) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Could not get ADK going, sorry"
        Break
    }
    $WorkspacePath = (Get-Item -Path $MediaPath -ErrorAction Stop).Parent.FullName
    $IsoFullName = Join-Path $WorkspacePath $isoFileName
    $PathOscdimg = $WindowsAdkPaths.PathOscdimg
    $oscdimgexe = $WindowsAdkPaths.oscdimgexe

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WorkspacePath: $WorkspacePath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] IsoFullName: $IsoFullName"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PathOscdimg: $PathOscdimg"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] oscdimgexe: $oscdimgexe"
    #=================================================
    # Test Paths
    $DestinationBoot = Join-Path $MediaPath 'boot'
    if (-NOT (Test-Path $DestinationBoot)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Cannot locate $DestinationBoot"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This does not appear to be a valid bootable ISO"
        Break
    }
    $DestinationEfiBoot = Join-Path $MediaPath 'efi\microsoft\boot'
    if (-NOT (Test-Path $DestinationEfiBoot)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Cannot locate $DestinationEfiBoot"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This does not appear to be a valid bootable ISO"
        Break
    }
    #=================================================
    # etfsboot.com
    $etfsbootcom = $WindowsAdkPaths.etfsbootcom
    $Destinationetfsbootcom = Join-Path $DestinationBoot 'etfsboot.com'
    if (Test-Path $Destinationetfsbootcom) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Using existing $Destinationetfsbootcom"
    }
    else {
        Copy-Item -Path $etfsbootcom -Destination $DestinationBoot -Force -ErrorAction Stop
    }
    #=================================================
    # efisys.bin and efisys_noprompt.bin
    $efisysbin = $WindowsAdkPaths.efisysbin
    $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys.bin'
    if (Test-Path $Destinationefisysbin) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Using existing $Destinationefisysbin"
    }
    else {
        Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
    }

    $efisysnopromptbin = $WindowsAdkPaths.efisysnopromptbin
    $Destinationefisysnopromptbin = Join-Path $DestinationEfiBoot 'efisys_noprompt.bin'
    if (Test-Path $Destinationefisysnopromptbin) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Using existing $Destinationefisysnopromptbin"
    }
    else {
        Copy-Item -Path $efisysnopromptbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
    }

<#     if ($PSBoundParameters.ContainsKey('NoPrompt')) {
        $efisysbin = $WindowsAdkPaths.efisysnopromptbin
        Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
        $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys_noprompt.bin'
    } else {
        $efisysbin = $WindowsAdkPaths.efisysbin
        Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
        $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys.bin'
    } #>

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationBoot: $DestinationBoot"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] etfsbootcom: $etfsbootcom"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destinationetfsbootcom: $Destinationetfsbootcom"

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationEfiBoot: $DestinationEfiBoot"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] efisysbin: $efisysbin"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destinationefisysbin: $Destinationefisysbin"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] efisysnopromptbin: $efisysnopromptbin"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destinationefisysnopromptbin: $Destinationefisysnopromptbin"
    #=================================================
    # Strings
    $isoLabelString = '-l"{0}"' -f "$isoLabel"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] isoLabelString: $isoLabelString"
    #=================================================
    # Create Prompt ISO
    $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$Destinationetfsbootcom", "$Destinationefisysbin"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BootDataString: $BootDataString"

    $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2","-bootdata:$BootDataString",'-u2','-udfver102',$isoLabelString,"`"$MediaPath`"", "`"$IsoFullName`"") -PassThru -Wait -NoNewWindow

    if (-NOT (Test-Path $IsoFullName)) {
        Write-Error "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Something didn't work"
        Break
    }
    $PromptIso = Get-Item -Path $IsoFullName
    #Write-Host -ForegroundColor Yellow "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ISO created at $PromptIso"
    #=================================================
    # Create NoPrompt ISO
    $IsoFullName = "$($PromptIso.Directory)\$($PromptIso.BaseName)_NoPrompt.iso"
    $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$Destinationetfsbootcom", "$Destinationefisysnopromptbin"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BootDataString: $BootDataString"

    $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2","-bootdata:$BootDataString",'-u2','-udfver102',$isoLabelString,"`"$MediaPath`"", "`"$IsoFullName`"") -PassThru -Wait -NoNewWindow

    if (-NOT (Test-Path $IsoFullName)) {
        Write-Error "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Something didn't work"
        Break
    }
    $NoPromptIso = Get-Item -Path $IsoFullName
    #Write-Host -ForegroundColor Yellow "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ISO created at $NoPromptIso"
    #=================================================
    # Open Windows Explorer
    if ($PSBoundParameters.ContainsKey('OpenExplorer')) {
        explorer $WorkspacePath
    }
    #=================================================
    # Return Get-Item
    Return $PromptIso

    <#  $Results += [pscustomobject]@{
        FullName            = $IsoFullName
        Name                = $isoFileName
        Label               = $isoLabel
        isoDirectory     = $MediaPath
    }
    Return $Results #>
    #=================================================
}