$LocalExperiencePackFiles = Get-ChildItem "$PSScriptRoot\1903 LXP" *.appx -Recurse | Select-Object -Property *
$LocalExperiencePacks = foreach ($Item in $LocalExperiencePackFiles) {
    [PSCustomObject] @{
        Language    = ($Item.Directory).Name
        Directory   = $Item.Directory
        Package     = $Item.FullName
        License     = Join-Path $Item.Directory 'License.xml'
    }
}
$LocalExperiencePacks | Out-GridView -Wait