<#
.SYNOPSIS
    OSDBuilder function that tests the LCU and returns the Package Type

.DESCRIPTION
    OSDBuilder function that tests the LCU and returns the Package Type

.PARAMETER PackagePath
    Path to the Windows update package to test

.PARAMETER Path
    Directory path where the Windows Image is mounted

.LINK
https://www.osdcloud.com

.NOTES
    Credit to Lasse Meggele @lassemeggele for correcting some issues. Thanks!
#>
function Test-WindowsPackageCAB {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String]
        $PackagePath,

        [Parameter()]
        [System.String]
        $Path
    )
    
    try {
        $WinPackage = $null
        if ($Path) {
            $WinPackage = Get-WindowsPackage -Path $Path -PackagePath $PackagePath -ErrorAction SilentlyContinue
        }
        else {
            $WinPackage = Get-WindowsPackage -Online -PackagePath $PackagePath -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Verbose -Message $_.Exception.Message
    }
    
    Write-Verbose -Message $PackagePath
    Write-Verbose -Message $Path

    [string]$returnVal = [string]::Empty

    if ([string]::IsNullOrWhiteSpace($WinPackage.PackageName)) {
        Write-Verbose -Message 'Could not extract PackageName from PackagePath.'
    }
    else {
        switch ($WinPackage.PackageName) {
            { $_ -match 'OnePackage' } { $returnVal = 'CombinedMSU'; Break; }
            { $_ -match 'Multiple_Packages' } { $returnVal = 'CombinedLCU'; Break; }
            { $_ -match 'DotNetRollup' } { $returnVal = 'DotNetCU'; Break; }
            { $_ -match 'ServicingStack' } { $returnVal = 'SSU'; Break; }
            Default { $returnVal = $WinPackage.PackageName; Break; }
        }
        Write-Verbose -Message $returnVal
    }
    Return $returnVal
}