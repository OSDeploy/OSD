

function Convert-FolderToIso {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]$folderFullName,

        [string]$isoFullName = $null,

        [ValidateLength(1,16)]
        [string]$isoLabel = 'FolderToIso',

        [System.Management.Automation.SwitchParameter]$noPrompt
    )
    #=================================================
    #	Blocks
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-WindowsVersionNe10
    Block-WindowsReleaseIdLt1703
    #=================================================
    #   Make sure the folder we are iso'ing exists
    #=================================================
    if (! (Test-Path $folderFullName)) {
        Write-Warning "Convert-FolderToIso: folderFullName does not exist at $folderFullName"
        Break
    }
    #=================================================
    #   Make sure folder is a folder
    #=================================================
    if ((Get-Item $folderFullName) -isnot [System.IO.DirectoryInfo]) {
        Write-Warning "Convert-FolderToIso: folderFullName is not a folder"
        Break
    }
    #=================================================
    #   isoFullName
    #=================================================
    $GetItem = Get-Item -Path $folderFullName
    if (! ($isoFullName)) {
        $isoFullName = Join-Path (get-item -Path "T:\DevBox\Win11_22000.318").Parent.FullName ($GetItem.BaseName + '.iso')
    }
    #=================================================
    #	Variables
    #=================================================
    Write-Verbose -Verbose "folderFullName: $folderFullName"
    Write-Verbose -Verbose "isoFullName: $isoFullName"
    Write-Verbose -Verbose "isoLabel: $isoLabel"
    #=================================================
    #   Test-FolderToIso
    #=================================================
    $Params = @{
        folderFullName = $folderFullName
        isoFullName = $isoFullName
        isoLabel = $isoLabel
    }

    if (Test-FolderToIso @Params) {
        #=================================================
        #   Get Adk Paths
        #=================================================
        $AdkPaths = Get-AdkPaths
        #=================================================
        #   oscdimg.exe
        #=================================================
        $oscdimgexe = $AdkPaths.oscdimgexe
        Write-Verbose -Verbose "oscdimgexe: $oscdimgexe"
        #=================================================
        #   Bootable
        #=================================================
        $isBootable = $true
        $folderBoot = Join-Path $folderFullName 'boot'
        if (! (Test-Path $folderBoot)) {
            Write-Warning "Convert-FolderToIso: folderFullName does not contain a Boot directory at $folderBoot"
            $isBootable = $false
        }
        $etfsbootcom = Join-Path $folderBoot 'etfsboot.com'
        if (! (Test-Path $etfsbootcom)) {
            Write-Warning "Convert-FolderToIso: folderFullName is missing $etfsbootcom"
            $isBootable = $false
        }

        $folderEfiBoot = Join-Path $folderFullName 'efi\microsoft\boot'
        if (! (Test-Path $folderEfiBoot)) {
            Write-Warning "Convert-FolderToIso: folderFullName does not contain a Boot directory at $folderEfiBoot"
            $isBootable = $false
        }
        $efisysbin = Join-Path $folderEfiBoot 'efisys.bin'
        if (! (Test-Path $efisysbin)) {
            Write-Warning "Convert-FolderToIso: folderFullName is missing $efisysbin"
        }
        $efisysnopromptbin = Join-Path $folderEfiBoot 'efisys_noprompt.bin'
        if (! (Test-Path $efisysnopromptbin)) {
            Write-Warning "Convert-FolderToIso: folderFullName is missing $efisysnopromptbin"
        }
        if ((Test-Path $efisysbin) -or (Test-Path $efisysnopromptbin)) {
            #Bootable
        }
        else {
            $isBootable = $false
        }
        #=================================================
        #   Strings
        #=================================================
        $isoLabelString = '-l"{0}"' -f "$isoLabel"
        Write-Verbose -Verbose "isoLabelString: $isoLabelString"
        #=================================================
        #   Create ISO
        #=================================================
        if ($isBootable) {
            if (($noPrompt) -and (Test-Path $efisysnopromptbin)) {
                $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$etfsbootcom", "$efisysnopromptbin"
                Write-Verbose -Verbose "BootDataString: $BootDataString"
                $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2","-bootdata:$BootDataString",'-u2','-udfver102',$isoLabelString,"`"$folderFullName`"", "`"$isoFullName`"") -PassThru -Wait -NoNewWindow
            }
            else {
                $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$etfsbootcom", "$efisysbin"
                Write-Verbose -Verbose "BootDataString: $BootDataString"
                $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2","-bootdata:$BootDataString",'-u2','-udfver102',$isoLabelString,"`"$folderFullName`"", "`"$isoFullName`"") -PassThru -Wait -NoNewWindow
            }
        }
        else {
            $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2",'-udfver102',$isoLabelString,"`"$folderFullName`"", "`"$isoFullName`"") -PassThru -Wait -NoNewWindow
        }
    
        if (Test-Path $isoFullName) {
            Get-Item -Path $isoFullName
        }
        else {
            Write-Error "Something didn't work"
        }
        #=================================================
    }
    else {
        Write-Warning 'Test-FolderToIso failed with one or more errors'
    }
}