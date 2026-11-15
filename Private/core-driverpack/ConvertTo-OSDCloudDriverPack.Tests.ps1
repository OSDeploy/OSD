BeforeAll {
    . $PSScriptRoot\ConvertTo-OSDCloudDriverPack.ps1

    $script:coreDriverPack = [PSCustomObject]@{
        CatalogVersion  = '26.09.25'
        ReleaseDate     = '26.06.16'
        Name            = 'Surface Laptop 8 Snapdragon [26.06.16]'
        Manufacturer    = 'Microsoft'
        Model           = 'Surface Laptop 8 Snapdragon'
        SystemId        = @('Surface_Laptop_13_8in_8th_Ed_Snapdragon_2036', 'Surface_Laptop_15in_8th_Ed_Snapdragon_2037')
        FileName        = 'SurfaceLaptop8withSnapdragon_Win11_28000_26.083.28964.0.msi'
        Url             = 'https://download.microsoft.com/example/SurfaceLaptop8withSnapdragon_Win11_28000_26.083.28964.0.msi'
        OperatingSystem = 'Windows 11'
        OSArchitecture  = 'arm64'
        HashMD5         = $null
        UpdatePage      = 'https://www.microsoft.com/download/details.aspx?id=108705'
    }
}

Describe 'ConvertTo-OSDCloudDriverPack' {
    It 'returns the complete legacy property contract in order' {
        $result = $script:coreDriverPack | ConvertTo-OSDCloudDriverPack
        $expectedProperties = @(
            'CatalogVersion', 'Status', 'ReleaseDate', 'Manufacturer', 'Model',
            'Legacy', 'Product', 'Name', 'PackageID', 'FileName', 'Url', 'OS',
            'OSReleaseId', 'OSBuild', 'OSArchitecture', 'HashMD5', 'Guid'
        )

        @($result.PSObject.Properties.Name) | Should -Be $expectedProperties
    }

    It 'derives Surface compatibility metadata' {
        $result = $script:coreDriverPack | ConvertTo-OSDCloudDriverPack

        $result.PackageID | Should -Be '108705'
        $result.OSBuild | Should -Be '28000'
        $result.OSReleaseId | Should -Be '26H1'
        $result.OS | Should -Be 'Windows 11 x64'
        $result.Product | Should -Contain 'Surface_Laptop_13_8in_8th_Ed_Snapdragon_2036'
    }

    It 'creates a deterministic GUID for the same catalog object' {
        $first = $script:coreDriverPack | ConvertTo-OSDCloudDriverPack
        $second = $script:coreDriverPack | ConvertTo-OSDCloudDriverPack

        $first.Guid | Should -Be $second.Guid
        { [System.Guid]::Parse($first.Guid) } | Should -Not -Throw
    }

    It 'creates distinct GUIDs for different model records sharing a package' {
        $otherModel = $script:coreDriverPack.PSObject.Copy()
        $otherModel.Model = 'Surface Laptop 8 Snapdragon 15 inch'

        $first = $script:coreDriverPack | ConvertTo-OSDCloudDriverPack
        $second = $otherModel | ConvertTo-OSDCloudDriverPack

        $first.Guid | Should -Not -Be $second.Guid
    }
}
