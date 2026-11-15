BeforeAll {
    . $PSScriptRoot\Initialize-OSDCloudSetupScripts.ps1
}

Describe 'Initialize-OSDCloudSetupScripts' {
    BeforeEach {
        $script:windowsPath = Join-Path -Path $TestDrive -ChildPath ([System.Guid]::NewGuid().Guid)
        New-Item -Path $script:windowsPath -ItemType Directory -Force | Out-Null
    }

    It 'creates both setup command files and their parent directory' {
        Initialize-OSDCloudSetupScripts -WindowsPath $script:windowsPath

        $scriptsPath = Join-Path -Path $script:windowsPath -ChildPath 'Setup\Scripts'
        Test-Path -Path (Join-Path -Path $scriptsPath -ChildPath 'SetupComplete.cmd') -PathType Leaf | Should -BeTrue
        Test-Path -Path (Join-Path -Path $scriptsPath -ChildPath 'OOBE.cmd') -PathType Leaf | Should -BeTrue
    }

    It 'preserves existing content and appends an OSDCloud marker to both files' {
        $scriptsPath = Join-Path -Path $script:windowsPath -ChildPath 'Setup\Scripts'
        New-Item -Path $scriptsPath -ItemType Directory -Force | Out-Null
        $setupCompletePath = Join-Path -Path $scriptsPath -ChildPath 'SetupComplete.cmd'
        $oobePath = Join-Path -Path $scriptsPath -ChildPath 'OOBE.cmd'
        'existing setup command' | Set-Content -Path $setupCompletePath -Encoding ascii
        'existing OOBE command' | Set-Content -Path $oobePath -Encoding ascii

        Initialize-OSDCloudSetupScripts -WindowsPath $script:windowsPath

        $setupCompleteContent = @(Get-Content -Path $setupCompletePath)
        $oobeContent = @(Get-Content -Path $oobePath)
        $setupCompleteContent | Should -HaveCount 2
        $setupCompleteContent[0] | Should -Be 'existing setup command'
        $setupCompleteContent[1] | Should -BeLike ':: OSDCloud *'
        $oobeContent | Should -HaveCount 2
        $oobeContent[0] | Should -Be 'existing OOBE command'
        $oobeContent[1] | Should -BeLike ':: OSDCloud *'
    }

    It 'starts the marker on a new line when existing files lack a trailing newline' {
        $scriptsPath = Join-Path -Path $script:windowsPath -ChildPath 'Setup\Scripts'
        New-Item -Path $scriptsPath -ItemType Directory -Force | Out-Null
        $setupCompletePath = Join-Path -Path $scriptsPath -ChildPath 'SetupComplete.cmd'
        $oobePath = Join-Path -Path $scriptsPath -ChildPath 'OOBE.cmd'
        [System.IO.File]::WriteAllText($setupCompletePath, 'existing setup command', [System.Text.Encoding]::ASCII)
        [System.IO.File]::WriteAllText($oobePath, 'existing OOBE command', [System.Text.Encoding]::ASCII)

        Initialize-OSDCloudSetupScripts -WindowsPath $script:windowsPath

        $setupCompleteContent = @(Get-Content -Path $setupCompletePath)
        $oobeContent = @(Get-Content -Path $oobePath)
        $setupCompleteContent | Should -HaveCount 2
        $setupCompleteContent[0] | Should -Be 'existing setup command'
        $setupCompleteContent[1] | Should -BeLike ':: OSDCloud *'
        $oobeContent | Should -HaveCount 2
        $oobeContent[0] | Should -Be 'existing OOBE command'
        $oobeContent[1] | Should -BeLike ':: OSDCloud *'
    }

    It 'writes ASCII content without a byte-order mark' {
        Initialize-OSDCloudSetupScripts -WindowsPath $script:windowsPath

        $setupCompletePath = Join-Path -Path $script:windowsPath -ChildPath 'Setup\Scripts\SetupComplete.cmd'
        $bytes = [System.IO.File]::ReadAllBytes($setupCompletePath)
        $bytes[0] | Should -Be 58
        @($bytes | Where-Object { $_ -gt 127 }).Count | Should -Be 0
    }

    It 'propagates file write failures' {
        $setupPath = Join-Path -Path $script:windowsPath -ChildPath 'Setup'
        'path conflict' | Set-Content -Path $setupPath -Encoding ascii

        { Initialize-OSDCloudSetupScripts -WindowsPath $script:windowsPath } | Should -Throw
    }
}
