BeforeAll {
    . $PSScriptRoot\ConvertTo-OSDCloudDriverPack.ps1
    . $PSScriptRoot\Get-OSDCloudDriverPackCompatibilityCatalog.ps1

    function Get-OSDCoreDriverPackCatalogDell {
        [CmdletBinding()]
        param ([switch]$LocalOnly, [string]$LocalDriverPackCatalog)
    }

    function Get-OSDCoreDriverPackCatalogHP {
        [CmdletBinding()]
        param ([switch]$LocalOnly, [string]$LocalDriverPackCatalog)
    }

    function Get-OSDCoreDriverPackCatalogLenovo {
        [CmdletBinding()]
        param ([switch]$LocalOnly, [string]$LocalDriverPackCatalog)
    }

    function Get-OSDCoreDriverPackCatalogPanasonic {
        [CmdletBinding()]
        param ([switch]$LocalOnly, [string]$LocalDriverPackCatalog)
    }

    function Get-OSDCoreDriverPackCatalogSurface {
        [CmdletBinding()]
        param ([switch]$LocalOnly, [string]$LocalDriverPackCatalog)
    }

    $script:testCoreDriverPack = [PSCustomObject]@{
        CatalogVersion  = '26.09.30'
        ReleaseDate     = '26.09.30'
        Name            = 'Test Driver Pack [26.09.30]'
        Manufacturer    = 'Test'
        Model           = 'Test Model'
        SystemId        = 'TEST-01'
        FileName        = 'test.cab'
        Url             = 'https://example.test/test.cab'
        OperatingSystem = 'Windows 11'
        OSArchitecture  = 'amd64'
        OSVersion       = '26H2'
        HashMD5         = '0123456789ABCDEF0123456789ABCDEF'
    }
    $script:testGenericDriverPackJson = @'
{
    "CatalogVersion": "26.09.30",
    "ReleaseDate": "26.09.29",
    "Name": "Generic Driver Pack [26.09.29]",
    "Manufacturer": "Generic",
    "Model": "Generic Model",
    "SystemId": "GENERIC-01",
    "FileName": "generic.cab",
    "Url": "https://example.test/generic.cab",
    "OperatingSystem": "Windows 11",
    "OSArchitecture": "arm64",
    "OSVersion": "26H2",
    "HashMD5": "FEDCBA9876543210FEDCBA9876543210"
}
'@
    $script:testLegacyDriverPackCatalogJson = @'
[
    {
        "Manufacturer": "Test",
        "Model": "Test Model",
        "FileName": "test.cab",
        "Guid": "11111111-1111-1111-1111-111111111111"
    },
    {
        "Manufacturer": "Test",
        "Model": "Test Model",
        "FileName": "test.cab",
        "Guid": "22222222-2222-2222-2222-222222222222"
    }
]
'@
}

Describe 'Get-OSDCloudDriverPackCompatibilityCatalog' {
    BeforeEach {
        Mock Test-Path { $true }
        Mock Get-OSDCoreDriverPackCatalogDell { $script:testCoreDriverPack }
        Mock Get-OSDCoreDriverPackCatalogHP { @() }
        Mock Get-OSDCoreDriverPackCatalogLenovo { @() }
        Mock Get-OSDCoreDriverPackCatalogPanasonic { @() }
        Mock Get-OSDCoreDriverPackCatalogSurface { @() }
        Mock Get-Content {
            if ($LiteralPath -like '*build-driverpacks.json') {
                $script:testLegacyDriverPackCatalogJson
            }
            else {
                $script:testGenericDriverPackJson
            }
        }
    }

    It 'reads local core catalogs and returns compatibility objects' {
        $result = @(Get-OSDCloudDriverPackCompatibilityCatalog -ModuleBase $TestDrive)

        $result | Should -HaveCount 2
        $result.Product | Should -Contain 'TEST-01'
        $result.Product | Should -Contain 'GENERIC-01'
        $testDriverPack = $result | Where-Object { $_.Product -contains 'TEST-01' }
        $testDriverPack.Guid | Should -Be '11111111-1111-1111-1111-111111111111'
        $testDriverPack.GuidAliases | Should -Contain '22222222-2222-2222-2222-222222222222'
        Should -Invoke Get-OSDCoreDriverPackCatalogDell -Exactly 1 -ParameterFilter { $LocalOnly }
        Should -Invoke Get-OSDCoreDriverPackCatalogSurface -Exactly 1 -ParameterFilter { $LocalOnly }
    }

    It 'throws when a required core catalog is missing' {
        Mock Test-Path { $false }

        { Get-OSDCloudDriverPackCompatibilityCatalog -ModuleBase $TestDrive } |
            Should -Throw '*Required driver pack catalog was not found*'
    }
}
