function Test-WindowsPackageCAB {
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
            Write-Output 'CombinedMSU'
        }
        elseif ($WinPackage.PackageName -match 'Multiple_Packages') {
            Write-Output 'CombinedLCU'
        }
        elseif ($WinPackage.PackageName -match 'DotNetRollup') {
            Write-Output 'DotNetCU'
        }
        elseif ($WinPackage.PackageName -match 'ServicingStack') {
            Write-Output 'SSU'
        }
    }
}