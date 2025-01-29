function Get-OSDCacheRepositories {
    [CmdletBinding()]
    [OutputType([System.IO.FileSystemInfo])]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))] $($MyInvocation.MyCommand)"
    #=================================================
    $Path = Get-OSDCachePath

    if (Test-Path $Path) {
        $Results = Get-ChildItem -Path $Path -Directory | Select-Object -Property * | Where-Object { Test-Path $(Join-Path $_.FullName '.git') }
    }

    return $Results
    #=================================================
}