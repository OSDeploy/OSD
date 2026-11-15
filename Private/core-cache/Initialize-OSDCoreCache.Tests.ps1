BeforeAll {
    . $PSScriptRoot\Initialize-OSDCoreCache.ps1

    function Get-OSDCoreCacheContent {
        [CmdletBinding()]
        param ()
    }
}

Describe 'Initialize-OSDCoreCache' {
    It 'stores discovered cache content in the selection inventory' {
        $expectedCacheContent = @(
            [PSCustomObject]@{ Type = 'ESD'; FullName = 'C:\OSDCloud\OS\install.esd' }
        )
        Mock Get-OSDCoreCacheContent { $expectedCacheContent }

        Initialize-OSDCoreCache

        $global:OSDCoreCacheContent | Should -Be $expectedCacheContent
        Should -Invoke Get-OSDCoreCacheContent -Exactly 1
    }
}
