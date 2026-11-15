BeforeAll {
    . $PSScriptRoot\..\..\Private\core-driverpack\ConvertTo-OSDCloudDriverPack.ps1
    . $PSScriptRoot\..\..\Private\core-driverpack\Get-OSDCloudDriverPackCompatibilityCatalog.ps1
    . $PSScriptRoot\OSDCloudDriverPack.ps1

    function Block-WindowsVersionNe10 {
        [CmdletBinding()]
        param ()
    }

    function Save-WebFile {
        [CmdletBinding()]
        param (
            [string]$SourceUrl,
            [string]$DestinationDirectory,
            [string]$DestinationName
        )
    }

    $script:testDriverPacks = @(
        [PSCustomObject]@{
            CatalogVersion = '26.09.30'
            Status         = $null
            ReleaseDate    = '26.09.30'
            Manufacturer   = 'Test'
            Model          = 'Test Model'
            Legacy         = $null
            Product        = @('TEST-01')
            Name           = 'Test Model Windows 11 26H2'
            PackageID      = 'TEST01'
            FileName       = 'test-26h2.cab'
            Url            = 'https://example.test/test-26h2.cab'
            OS             = 'Windows 11 x64'
            OSReleaseId    = '26H2'
            OSBuild        = '26300'
            OSArchitecture = 'amd64'
            HashMD5        = '0123456789ABCDEF0123456789ABCDEF'
            Guid           = '11111111-1111-1111-1111-111111111111'
        }
        [PSCustomObject]@{
            CatalogVersion = '26.09.30'
            Status         = $null
            ReleaseDate    = '26.09.29'
            Manufacturer   = 'Test'
            Model          = 'Other Model'
            Legacy         = $null
            Product        = @('TEST-02')
            Name           = 'Other Model Windows 11 25H2'
            PackageID      = 'TEST02'
            FileName       = 'test-25h2.cab'
            Url            = 'https://example.test/test-25h2.cab'
            OS             = 'Windows 11 x64'
            OSReleaseId    = '25H2'
            OSBuild        = '26200'
            OSArchitecture = 'amd64'
            HashMD5        = 'FEDCBA9876543210FEDCBA9876543210'
            Guid           = '22222222-2222-2222-2222-222222222222'
            GuidAliases    = @('33333333-3333-3333-3333-333333333333')
        }
    )
}

Describe 'OSDCloud driver pack public compatibility' {
    BeforeEach {
        Mock Get-OSDCloudDriverPackCompatibilityCatalog { $script:testDriverPacks }
    }

    It 'returns compatibility catalog objects without reading the legacy cache' {
        $result = @(Get-OSDCloudDriverPacks)

        $result | Should -HaveCount 2
        $result[0].PSObject.Properties.Name | Should -Contain 'Product'
        $result[0].PSObject.Properties.Name | Should -Contain 'Guid'
        Should -Invoke Get-OSDCloudDriverPackCompatibilityCatalog -Exactly 1
    }

    It 'selects a driver pack by product and operating system' {
        $result = Get-OSDCloudDriverPack -Product 'TEST-01' -OSVersion 'Windows 11' -OSReleaseID '26H2'

        $result.Guid | Should -Be '11111111-1111-1111-1111-111111111111'
    }

    It 'uses GUID selection when saving a driver pack' {
        Mock Block-WindowsVersionNe10 {}
        Mock Save-WebFile {
            New-Item -Path $DestinationDirectory -ItemType Directory -Force | Out-Null
            New-Item -Path (Join-Path $DestinationDirectory $DestinationName) -ItemType File -Force | Out-Null
        }

        Save-OSDCloudDriverPack -Guid '22222222-2222-2222-2222-222222222222' -DownloadPath $TestDrive

        Should -Invoke Save-WebFile -Exactly 1 -ParameterFilter {
            $SourceUrl -eq 'https://example.test/test-25h2.cab' -and
            $DestinationName -eq 'test-25h2.cab'
        }
    }

    It 'uses legacy GUID aliases when saving a driver pack' {
        Mock Block-WindowsVersionNe10 {}
        Mock Save-WebFile {
            New-Item -Path $DestinationDirectory -ItemType Directory -Force | Out-Null
            New-Item -Path (Join-Path $DestinationDirectory $DestinationName) -ItemType File -Force | Out-Null
        }

        Save-OSDCloudDriverPack -Guid '33333333-3333-3333-3333-333333333333' -DownloadPath $TestDrive

        Should -Invoke Save-WebFile -Exactly 1 -ParameterFilter {
            $SourceUrl -eq 'https://example.test/test-25h2.cab' -and
            $DestinationName -eq 'test-25h2.cab'
        }
    }
}
