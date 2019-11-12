function Update-OSDWindowsImage {
    [CmdletBinding()]
    Param (
        #Specifies the full path to the root directory of the offline Windows image that you will service.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string]$Path,

        #Install the selected update
        [ValidateSet('All','AdobeSU','DotNet','DotNetCU','LCU','Optional','SSU')]
        [string]$UpdateGroup = 'All',

        #Updates are only installed if they are needed.  Force parameter will install the update even if it is already installed
        [switch]$Force
    )

    Begin {
        #===================================================================================================
        #   Initial Warning
        #===================================================================================================
        Write-Warning 'Update-WindowsImage: This function is currently under development'
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
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateArch -eq 'x64'}
        }
        if ($global:GetRegKeyWinCurVer.InstallationType -match 'WindowsPE') {
            $global:GetOSDSUS = $global:GetOSDSUS | Where-Object {$_.UpdateOS -eq 'Windows 10'}
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
        #   Apply Update
        #===================================================================================================
        foreach ($item in $global:GetOSDSUS) {
            Write-Verbose $item.Title -Verbose
            $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -BitsTransfer -Verbose
            $CurrentLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Update-WindowsImage.log"

            if (! (Test-Path "$env:TEMP\OSD")) {
                New-Item -Path "$env:TEMP\OSD" -Force | Out-Null
            }

            if (Test-Path $UpdateFile.FullName) {
                #Write-Verbose "Add-WindowsPackage -PackagePath $($UpdateFile.FullName) -Path $Path" -Verbose
                Try {Add-WindowsPackage -Path $Path -PackagePath $UpdateFile.FullName -LogPath $CurrentLog | Out-Null}
                Catch {
                    if ($_.Exception.Message -match '0x800f081e') {
                    Write-Verbose "Update-WindowsImage: 0x800f081e The package is not applicable to this image" -Verbose}
                    Write-Verbose "Update-WindowsImage: Review the log for more information" -Verbose
                    Write-Verbose $CurrentLog -Verbose
                }
            } else {
                Write-Warning "Unable to find $($UpdateFile.FullName)"
            }
        }
    }
    End {}
}