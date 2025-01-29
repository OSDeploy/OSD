function Get-OSDCachePath {
    [CmdletBinding()]
    param ()

    $ParentPath = $env:ProgramData
    $ChildPath = 'OSDCache'

    $Path = Join-Path -Path $ParentPath -ChildPath $ChildPath

    return $Path
}