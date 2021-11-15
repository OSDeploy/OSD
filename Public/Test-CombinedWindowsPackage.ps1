function Test-CombinedWindowsPackage {
    [CmdletBinding()]
    param (
        [string]$PackagePath
    )
    
    try {
        $WinPackage = $null
        $WinPackage = Get-WindowsPackage -Online -PackagePath $PackagePath -ErrorAction SilentlyContinue
    }
    catch {
        
    }
    finally {
        Write-Verbose $PackagePath
        if ($WinPackage.PackageName) {
            Write-Verbose -Verbose $WinPackage.PackageName
        }
        if ($WinPackage.PackageName -match 'OnePackage') {
            $true
        }
        elseif ($WinPackage.PackageName -match 'Multiple_Packages') {
            $true
        }
        else {
            $false
        }
    }
}