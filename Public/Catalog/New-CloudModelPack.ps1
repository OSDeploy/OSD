class CloudModelPack {
    [string] $CatalogVersion = $(Get-Module -Name OSD | Sort-Object Version | Select-Object Version -Last 1).Version
    [string] $Component = 'CloudModelPack'
    [datetime] $ReleaseDate = (Get-Date)
    [string] $Name
    [string] $Manufacturer
    [string] $Family
    [string] $Model
    [string] $SystemId
    [string] $Product
    [string] $Version
    [string] $FileName
    [string] $SizeMB
    [string] $Hash
    [string] $Download
    [string] $About
    [string] $Expand
    [ValidateSet('Windows7','Windows8','Windows10','Windows11')]
    [string[]] $osName = 'Windows10'
    [ValidateSet('x64','x86')]
    [string[]] $osArch = 'x64'
    [ValidateSet('6.1','6.3','10.0')]
    [string[]] $osVersion = '10.0'
}

function New-CloudModelPack {
    [CmdletBinding()]
    [OutputType([CloudModelPack])]
    param (
        [string]$Name,
        [ValidateSet('Windows7','Windows8','Windows10','Windows11')]
        [string[]] $osName = 'Windows10',
        [ValidateSet('x64','x86')]
        [string[]] $osArch = 'x64',
        [ValidateSet('6.1','6.3','10.0')]
        [string[]] $osVersion = '10.0'
    )

    [CloudModelPack]@{
        Name        = $Name
        osName      = $osName
        osArch      = $osArch
        osVersion   = $osVersion
    }
}