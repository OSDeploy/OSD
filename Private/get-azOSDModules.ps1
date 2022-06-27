function Get-AzOSDModules {
    [CmdletBinding()]
    param ()
    $PSModuleName = ('Az.Accounts','Az.Resources')
    
    foreach ($currentItemName in $PSModuleName ) {
        $InstalledModule = Get-InstalledModule $currentItemName -ErrorAction Ignore | Select-Object -First 1
        $GalleryPSModule = Find-Module -Name $currentItemName -ErrorAction Ignore
    
        if ($InstalledModule) {
            if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
                if ($WindowsPhase -eq 'WinPE') {
                    Write-Host -ForegroundColor DarkGray "Update-Module $currentItemName $($GalleryPSModule.Version) [AllUsers]"
                    Update-Module -Name $currentItemName -Scope AllUsers -Force
                    Import-Module $currentItemName -Force
                }
                else {
                    Write-Host -ForegroundColor DarkGray "Update-Module $currentItemName $($GalleryPSModule.Version) [CurrentUser]"
                    Update-Module -Name $currentItemName -Scope CurrentUser -Force
                    Import-Module $currentItemName -Force
                } 
            }
        }
        else {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Install-Module $currentItemName $($GalleryPSModule.Version) [AllUsers]"
                Install-Module $currentItemName -Scope AllUsers
            }
            else {
                Write-Host -ForegroundColor DarkGray "Install-Module $currentItemName $($GalleryPSModule.Version) [CurrentUser]"
                Install-Module $currentItemName -Scope CurrentUser
            }
        }
        Import-Module $currentItemName -Force
    
    }
   
}
