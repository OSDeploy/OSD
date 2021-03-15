<#
.SYNOPSIS
Returns the Registry Key values from HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion

.DESCRIPTION
Returns the Registry Key values from HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion for Online and Offline Windows Images

.LINK
https://osd.osdeploy.com/module/functions/general/get-regcurrentversion

.NOTES
19.11.20    Added Pipeline Support
19.11.9     David Segura @SeguraOSD Initial Release
#>
function Get-RegCurrentVersion {
    [CmdletBinding()]
    param (
        #Specifies the full path to the root directory of the offline Windows image that you will service.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Path,

        [ValidateSet(
            'BaseBuildRevisionNumber',
            'BuildBranch',
            'BuildGUID',
            'BuildLab',
            'BuildLabEx',
            'CompositionEditionID',
            'CurrentBuild',
            'CurrentBuildNumber',
            'CurrentMajorVersionNumber',
            'CurrentMinorVersionNumber',
            'CurrentType',
            'CurrentVersion',
            'EditionID',
            'InstallationType',
            'ProductId',
            'ProductName',
            'ReleaseId',
            'UBR'
            )]
        [string]$Property
    )
    begin {}
    process {
        $Global:GetRegCurrentVersion = $null

        if ($Path) {
            if (-not (Test-Path $Path -ErrorAction SilentlyContinue)) {Write-Warning "Unable to locate Mounted WindowsImage at $Path"; Break}
            Write-Verbose $Path
        
            $RegHive = "$Path\Windows\System32\Config\SOFTWARE"
            if (-not (Test-Path $RegHive)) {Write-Warning "Unable to locate RegHive at $RegHive"; Break}
        
            reg LOAD 'HKLM\OSD' "$Path\Windows\System32\Config\SOFTWARE" | Out-Null
            $Global:GetRegCurrentVersion = Get-ItemProperty -Path 'HKLM:\OSD\Microsoft\Windows NT\CurrentVersion'
            reg UNLOAD 'HKLM\OSD' | Out-Null
            Start-Sleep -Seconds 1
        } else {
            $Global:GetRegCurrentVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        }

        if ($Property) {
            Return ($Global:GetRegCurrentVersion).$Property
        } else {
            Return $Global:GetRegCurrentVersion
        }
    }
    end {}
}