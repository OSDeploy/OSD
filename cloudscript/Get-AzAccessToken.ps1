$global:accessToken = (Get-AzAccessToken -ResourceUrl https://graph.microsoft.com).Token
$global:authHeader = @{
    'Content-Type' = 'application/json'
    'Authorization' = 'Bearer ' + $global:accessToken
}
$global:accessToken
Write-Verbose -Verbose '$global:accessToken contains the Azure Access Token'
Write-Verbose -Verbose '$global:authHeader contains the HTTP Header Authorization'