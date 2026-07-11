function Convert-FolderToIso {
    <#
    .SYNOPSIS
    Creates an ISO file from a source folder.

    .DESCRIPTION
    Uses Windows ADK oscdimg to create a standard or bootable ISO from a folder.
    The function validates required boot files when present and supports optional
    no-prompt UEFI boot media generation.

    .PARAMETER folderFullName
    Source folder path to convert into an ISO.

    .PARAMETER isoFullName
    Destination ISO file path. If omitted, an ISO is created beside the source
    folder using the folder name.

    .PARAMETER isoLabel
    ISO volume label. Must be 1 to 16 characters.

    .PARAMETER noPrompt
    Uses efisys_noprompt.bin when available for UEFI boot media.

    .PARAMETER WindowsAdkRoot
    Optional Windows ADK root path used to resolve oscdimg.exe.

    .EXAMPLE
    Convert-FolderToIso -folderFullName 'C:\OSD\Media'
    Creates C:\OSD\Media.iso from the specified folder.

    .EXAMPLE
    Convert-FolderToIso -folderFullName 'C:\OSD\Media' -isoFullName 'C:\ISO\Custom.iso' -isoLabel 'CustomISO' -noPrompt
    Creates a bootable ISO at the specified destination with a custom label.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
                if (!($_ | Test-Path)) { throw "Path does not exist: $_" }
                if (!($_ | Test-Path -PathType Container)) { throw "Path must be a directory: $_" }
                return $true
            })]
        [Alias('FullName')]
        [string]$folderFullName,

        [string]$isoFullName = $null,

        [ValidateLength(1,16)]
        [string]$isoLabel = 'FolderToIso',

        [System.Management.Automation.SwitchParameter]$noPrompt,

        # Path to the Windows ADK root directory. Typically 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
        [ValidateScript({
            if (-NOT ($_ | Test-Path)) { throw "Path does not exist: $_" }
            if (-NOT ($_ | Test-Path -PathType Container)) { throw "Path must be a directory: $_" }
            if (-NOT (Test-Path "$($_.FullName)\Deployment Tools")) { throw "Path does not contain a Deployment Tools subfolder: $_"}
            # if (-NOT (Test-Path "$($_.FullName)\Windows Preinstallation Environment")) { throw "Path does not contain a Windows Preinstallation Environment directory: $_"}
            return $true
        })]
        [System.IO.FileInfo]
        $WindowsAdkRoot
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] Start"
    #=================================================
    #	Blocks
    #=================================================
    Block-WinPE
    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required to run this function"
        return
    }
    Block-PowerShellVersionLt5
    Block-WindowsVersionNe10
    Block-WindowsReleaseIdLt1703
    #=================================================
    #   isoFullName
    #=================================================
    $GetItem = Get-Item -Path $folderFullName
    if (! ($isoFullName)) {
        $isoFullName = Join-Path $($GetItem.Parent.FullName) $($GetItem.BaseName + '.iso')
    }
    #=================================================
    #	Variables
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName: $folderFullName"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] isoFullName: $isoFullName"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] isoLabel: $isoLabel"
    #=================================================
    #   Test if existing file exists and writable
    #=================================================
    if (Test-Path $isoFullName) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] Delete exiting file at $isoFullName"
        return
    }

    try {
        New-Item -Path $isoFullName -Force -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] isoFullName is not writable at $isoFullName"
        return
    }
    finally {
        if (Test-Path $isoFullName) {
            Remove-Item -Path $isoFullName -Force | Out-Null
        }
    }
    #=================================================
    #   Get Adk Paths
    #=================================================
    if ($WindowsAdkRoot) {
        $WindowsAdkPaths = Get-WindowsAdkPaths -WindowsAdkRoot $WindowsAdkRoot
    }
    else {
        $WindowsAdkPaths = Get-WindowsAdkPaths
    }
    #=================================================
    #   oscdimg.exe
    #=================================================
    $oscdimgexe = $WindowsAdkPaths.oscdimgexe
    Write-Verbose -Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] oscdimgexe: $oscdimgexe"
    #=================================================
    #   Bootable
    #=================================================
    $isBootable = $true
    $folderBoot = Join-Path $folderFullName 'boot'
    if (! (Test-Path $folderBoot)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName does not contain a Boot directory at $folderBoot"
        $isBootable = $false
    }
    $etfsbootcom = Join-Path $folderBoot 'etfsboot.com'
    if (! (Test-Path $etfsbootcom)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName is missing $etfsbootcom"
        $isBootable = $false
    }
    $folderEfiBoot = Join-Path $folderFullName 'efi\microsoft\boot'
    if (! (Test-Path $folderEfiBoot)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName does not contain a Boot directory at $folderEfiBoot"
        $isBootable = $false
    }
    $efisysbin = Join-Path $folderEfiBoot 'efisys.bin'
    if (! (Test-Path $efisysbin)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName is missing $efisysbin"
    }
    $efisysnopromptbin = Join-Path $folderEfiBoot 'efisys_noprompt.bin'
    if (! (Test-Path $efisysnopromptbin)) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] folderFullName is missing $efisysnopromptbin"
    }
    if ((Test-Path $efisysbin) -or (Test-Path $efisysnopromptbin)) {
        $isBootable = $true
    }
    else {
        $isBootable = $false
    }
    #=================================================
    #   Strings
    #=================================================
    $isoLabelString = '-l"{0}"' -f "$isoLabel"
    Write-Verbose -Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] isoLabelString: $isoLabelString"
    #=================================================
    #   Create ISO
    #=================================================
    if ($isBootable) {
        if (($noPrompt) -and (Test-Path $efisysnopromptbin)) {
            $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$etfsbootcom", "$efisysnopromptbin"
            Write-Verbose -Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] BootDataString: $BootDataString"
            $Process = Start-Process $oscdimgexe -args @('-m', '-o', '-u2', "-bootdata:$BootDataString", '-u2', '-udfver102', $isoLabelString, "`"$folderFullName`"", "`"$isoFullName`"") -PassThru -Wait -WindowStyle Hidden
        }
        else {
            $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$etfsbootcom", "$efisysbin"
            Write-Verbose -Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] BootDataString: $BootDataString"
            $Process = Start-Process $oscdimgexe -args @('-m', '-o', '-u2', "-bootdata:$BootDataString", '-u2', '-udfver102', $isoLabelString, "`"$folderFullName`"", "`"$isoFullName`"") -PassThru -Wait -WindowStyle Hidden
        }
    }
    else {
        $Process = Start-Process $oscdimgexe -args @('-m', '-o', '-u2', '-udfver102', $isoLabelString, "`"$folderFullName`"", "`"$isoFullName`"") -PassThru -Wait -WindowStyle Hidden
    }

    if (Test-Path $isoFullName) {
        Get-Item -Path $isoFullName
    }
    else {
        Write-Error "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] Something didn't work"
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand)] End"
    #=================================================
}
