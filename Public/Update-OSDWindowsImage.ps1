function Update-OSDWindowsImage {
    [CmdletBinding()]
    Param (
        #Specifies the full path to the root directory of the offline Windows image that you will service.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string]$Path,

        #Install the selected update
        [ValidateSet('All','AdobeSU','DotNet','DotNetCU','LCU','SSU')]
        [string]$UpdateGroup = 'All',

        #Checks the updates to see if they are installed
        [switch]$CheckOnly,

        #Download the file using BITS-Transfer
        #Interactive Login required
        [switch]$BitsTransfer,

        #Updates are only installed if they are needed.  Force parameter will install the update even if it is already installed
        [switch]$Force
    )

    Begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning 'Update-WindowsImage: This function requires Admin Rights ELEVATED'
            Break
        }
        #===================================================================================================
        #   Require OSDSUS Module
        #===================================================================================================
        if (-not (Get-Module -ListAvailable -Name OSDSUS)) {
            Write-Warning "Update-WindowsImage: PowerShell Module OSDSUS is required"
            Break
        }
    }
    Process {
        #===================================================================================================
        #   Validate Mount Path
        #===================================================================================================
        if (-not (Test-Path $Path -ErrorAction SilentlyContinue)) {
            Write-Warning "Update-WindowsImage: Unable to locate Mounted WindowsImage at $Path"
            Break
        }
        #===================================================================================================
        #   Get Registry Information
        #===================================================================================================
        $global:GetRegKeyWinCurVer = Get-RegKeyWinCurVer -Path $Path
        #===================================================================================================
        #   Require OSMajorVersion 10
        #===================================================================================================
        if ($global:GetRegKeyWinCurVer.CurrentMajorVersionNumber -ne 10) {
            Write-Warning "Update-WindowsImage: OS MajorVersion 10 is required"
            Break
        }
        #===================================================================================================
        #   Get-OSDSUS and Filter Results
        #===================================================================================================
        $global:GetOSDSUS = Get-OSDSUS -Catalog OSDBuilder | Sort-Object UpdateGroup -Descending
        $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateBuild -eq $global:GetRegKeyWinCurVer.ReleaseId}
        
        if ($global:GetRegKeyWinCurVer.BuildLabEx -match 'amd64') {
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateArch -eq 'x64'}
        } else {
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateArch -eq 'x86'}
        }
        if ($global:GetRegKeyWinCurVer.InstallationType -match 'WindowsPE') {
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateOS -eq 'Windows 10'}
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -notmatch 'DotNet'}
        }
        if ($global:GetRegKeyWinCurVer.InstallationType -match 'Core') {
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
        }
        if ($global:GetRegKeyWinCurVer.InstallationType -match 'Client') {
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateOS -notmatch 'Server'}
        }
        if ($global:GetRegKeyWinCurVer.InstallationType -match 'Server') {
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateOS -match 'Server'}
        }

        #Don't install Optional Updates
        $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -ne ''}

        if ($UpdateGroup -ne 'All') {
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateGroup -match $UpdateGroup}
        }
        #===================================================================================================
        #   Get-OSDSessions
        #===================================================================================================
        $global:GetOSDSessions = Get-OSDSessions -Path "$Path\Windows\Servicing\Sessions\Sessions.xml" | Where-Object {$_.targetState -eq 'Installed'} | Sort-Object id
        #===================================================================================================
        #   Apply Update
        #===================================================================================================
        foreach ($item in $global:GetOSDSUS) {

            if (! ($Force.IsPresent)) {
                if ($global:GetOSDSessions | Where-Object {$_.KBNumber -match "$($item.FileKBNumber)"}) {
                    Write-Verbose "Installed: $($item.Title) $($item.FileName)" -Verbose
                    Continue
                } else {
                    Write-Warning "Not Installed: $($item.Title) $($item.FileName)"
                }
            }

            if ($CheckOnly.IsPresent) {Continue}
            

            if ($BitsTransfer.IsPresent) {
                $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -BitsTransfer -Verbose
            } else {
                $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -Verbose
            }
            $CurrentLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Update-WindowsImage.log"

            if (! (Test-Path "$env:TEMP\OSD")) {New-Item -Path "$env:TEMP\OSD" -Force | Out-Null}

            if (Test-Path $UpdateFile.FullName) {
                #Write-Verbose "Add-WindowsPackage -PackagePath $($UpdateFile.FullName) -Path $Path" -Verbose
                Try {
                    Write-Verbose "Add-WindowsPackage -Path $Path -PackagePath $($UpdateFile.FullName)" -Verbose
                    Add-WindowsPackage -Path $Path -PackagePath $UpdateFile.FullName -LogPath $CurrentLog | Out-Null
                }
                Catch {
                    if ($_.Exception.Message -match '0x800f081e') {
                    Write-Verbose "Update-WindowsImage: 0x800f081e The package is not applicable to this image" -Verbose}
                    Write-Verbose $CurrentLog -Verbose
                }
            } else {
                Write-Warning "Unable to download $($UpdateFile.FullName)"
            }
        }
    }
    End {
        Start-Sleep -Seconds 2
    }
}