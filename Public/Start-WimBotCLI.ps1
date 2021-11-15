function Start-WimRobotCLI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ImagePath,

        [Int32]$Index = 1,

        [switch]$Update
    )
    function Show-WimRobotTime {
        [CmdletBinding()]
        param ()
        #=================================================
        #   Show-ActionTime
        #=================================================
        $Global:WimRobotTime = Get-Date
        Write-Host -ForegroundColor DarkGray "$(($Global:WimRobotTime).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
        #=================================================
    }
    #=================================================
    #   Block
    #=================================================
    Show-WimRobotTime; Write-Host 'Verify Admin Rights'
    Block-StandardUser
    Show-WimRobotTime; Write-Host 'Verify Windows 10 or Higher'
    Block-WindowsVersionNe10
    #=================================================
    #   Test if ImagePath exists
    #=================================================
    Show-WimRobotTime; Write-Host "Test-Path $ImagePath"
    if (!(Test-Path $ImagePath)) {
        Show-WimRobotTime; Write-Warning "Unable to find ImagePath at $ImagePath"
        Break
    }
    #=================================================
    #   GetItem
    #=================================================
    Show-WimRobotTime; Write-Host "Get-Item -Path $ImagePath"

    try {
        $GetImagePath = Get-Item -Path $ImagePath -ErrorAction Stop
    }
    catch {
        Show-WimRobotTime; Write-Warning $_.Exception.Message
        Break
    }
    #=================================================
    #   Test if file is a WIM
    #=================================================
    if ($GetImagePath.Extension -ne '.wim') {
        Show-WimRobotTime; Write-Warning "ImagePath is not a .wim file"
        Break
    }
    #=================================================
    #   Test WindowsImage
    #=================================================
    Show-WimRobotTime; Write-Host "Get-WindowsImage -ImagePath $ImagePath -Index $Index"
    try {
        $GetWindowsImage = Get-WindowsImage -ImagePath $ImagePath -Index $Index -ErrorAction Stop
    }
    catch {
        Show-WimRobotTime; Write-Warning $_.Exception.Message
        Break
    }
    $GetWindowsImage | Select-Object -Property *
    #=================================================
    #   Verify WindowsImage
    #=================================================
    if ($GetWindowsImage.InstallationType -ne '10') {
        Show-WimRobotTime; Write-Warning 'MajorVersion 10 is required'
        Break
    }
    if ($GetWindowsImage.InstallationType -ne 'Client') {
        Show-WimRobotTime; Write-Warning 'InstallationType Server is required'
        Break
    }
    #=================================================
    #   Mount WindowsImage
    #=================================================








    



    Break
    $MountPath = (Get-Item -Path $Input | Select-Object FullName).FullName
    Write-Verbose "Path: $MountPath" -Verbose





    #=================================================
    #   Validate Mount Path
    #=================================================
    if (-not (Test-Path $Input -ErrorAction SilentlyContinue)) {
        Write-Warning "Update-MyWindowsImage: Unable to locate Mounted WindowsImage at $Input"
        Break
    }
    #=================================================
    #   Get Registry Information
    #=================================================
    $global:GetRegCurrentVersion = Get-RegCurrentVersion -Path $Input
    #=================================================
    #   Require OSMajorVersion 10
    #=================================================
    if ($global:GetRegCurrentVersion.CurrentMajorVersionNumber -ne 10) {
        Write-Warning "Update-MyWindowsImage: OS MajorVersion 10 is required"
        Break
    }

    Write-Verbose -Verbose $global:GetRegCurrentVersion.ReleaseId
    #=================================================
    #   Get-WSUSXML and Filter Results
    #=================================================
    $global:GetWSUSXML = Get-WSUSXML -Catalog Windows | Sort-Object UpdateGroup -Descending

    if ($global:GetRegCurrentVersion.ReleaseId -gt 0) {
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateBuild -eq $global:GetRegCurrentVersion.DisplayVersion}
    }
    else {
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateBuild -eq $global:GetRegCurrentVersion.ReleaseId}
    }

    if ($global:GetRegCurrentVersion.BuildLabEx -match 'amd64') {
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateArch -eq 'x64'}
    } else {
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateArch -eq 'x86'}
    }
    if ($global:GetRegCurrentVersion.InstallationType -match 'WindowsPE') {
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateOS -eq 'Windows 10'}
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -notmatch 'DotNet'}
    }
    if ($global:GetRegCurrentVersion.InstallationType -match 'Core') {
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -notmatch 'Adobe'}
    }
    if ($global:GetRegCurrentVersion.InstallationType -match 'Client') {
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateOS -notmatch 'Server'}
    }
    if ($global:GetRegCurrentVersion.InstallationType -match 'Server') {
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateOS -match 'Server'}
    }

    #Don't install Optional Updates
    $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -ne ''}

    if ($Update -ne 'Check' -and $Update -ne 'All') {
        $global:GetWSUSXML = $global:GetWSUSXML | Where-Object {$_.UpdateGroup -match $Update}
    }
    #=================================================
    #   Get-SessionsXml
    #=================================================
    $global:GetSessionsXml = Get-SessionsXml -Path "$Input" | Where-Object {$_.targetState -eq 'Installed'} | Sort-Object id
    #=================================================
    #   Apply Update
    #=================================================
    foreach ($item in $global:GetWSUSXML) {
        if (! ($Force.IsPresent)) {
            if ($global:GetSessionsXml | Where-Object {$_.KBNumber -match "$($item.FileKBNumber)"}) {
                Write-Verbose "Installed: $($item.Title) $($item.FileName)" -Verbose
                Continue
            } else {
                Write-Warning "Not Installed: $($item.Title) $($item.FileName)"
            }
        }

        if ($Update -eq 'Check') {Continue}
                
<#      if ($BitsTransfer.IsPresent) {
            $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -BitsTransfer -Verbose
        } else {
            $UpdateFile = Save-OSDDownload -SourceUrl $item.OriginUri -Verbose
        } #>
        $UpdateFile = Save-WebFile -SourceUrl $item.OriginUri
        $CurrentLog = "$env:TEMP\OSD\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Update-MyWindowsImage.log"

        if (! (Test-Path "$env:TEMP\OSD")) {New-Item -Path "$env:TEMP\OSD" -Force | Out-Null}

        if (Test-Path $UpdateFile.FullName) {
            #Write-Verbose "Add-WindowsPackage -PackagePath $($UpdateFile.FullName) -Path $Input" -Verbose
            Try {
                Write-Verbose "Add-WindowsPackage -Path $Input -PackagePath $($UpdateFile.FullName)" -Verbose
                Add-WindowsPackage -Path $Input -PackagePath $UpdateFile.FullName -LogPath $CurrentLog | Out-Null
            }
            Catch {
                if ($_.Exception.Message -match '0x800f081e') {
                Write-Verbose "Update-MyWindowsImage: 0x800f081e The package is not applicable to this image" -Verbose}
                Write-Verbose $CurrentLog -Verbose
            }
        } else {
            Write-Warning "Unable to download $($UpdateFile.FullName)"
        }
    }
    #=================================================
    #   Return for PassThru
    #=================================================
    Get-WindowsImage -Mounted | Where-Object {$_.Path -eq $MountPath}
    #=================================================
}