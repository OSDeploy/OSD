Get-ChildItem *.ps1 | ForEach-Object {
    $content = Get-Content -Path $_
    Set-Content -Path $_.Fullname -Value $content -Encoding utf8BOM -PassThru -Force
}
