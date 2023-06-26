#https://platform.openai.com/docs/api-reference/models/list

# Login to https://platform.openai.com/account/api-keys and generate an API key
$ApiKey = '<your API key>'

$Uri = 'https://api.openai.com/v1/models'

$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $ApiKey"
}

if ($ApiKey) {
    Invoke-RestMethod -Uri $Uri -Method GET -Headers $headers | ConvertTo-Json
}
else {
    Write-Warning 'You must provide an ApiKey'
}