<# OLD - API was blocked unless subscription paid
Function Get-TimeZoneFromIP {
    $URIRequest = "https://timezoneapi.io/api/ip/?token=aZuNiKeSCzxosgrJGmCK"
    $TimeZoneAPI =  (Invoke-WebRequest -Uri $URIRequest -UseBasicParsing).Content
    $TimeZoneInfo = $TimeZoneAPI  | ConvertFrom-Json
    $TimeZoneOffSet = $TimeZoneInfo.data.datetime.offset_tzfull
    if ($TimeZoneOffSet -match "Daylight"){$TimeZoneOffSet = $TimeZoneOffSet.Replace("Daylight","Standard")}
    return $TimeZoneOffSet
}

#>

#New Method
Function Get-TimeZoneFromIP {
    $URIRequest = "http://worldtimeapi.org/api/ip"
    $TimeZoneAPI =  (Invoke-WebRequest -Uri $URIRequest -UseBasicParsing).Content
    $TimeZoneInfo = $TimeZoneAPI  | ConvertFrom-Json
    $TimeZoneLookupURL = 'https://raw.githubusercontent.com/dmfilipenko/timezones.json/master/timezones.json'
    $Data = Invoke-WebRequest -UseBasicParsing -Uri $TimeZoneLookupURL
    $TimeZoneData = $Data.Content | ConvertFrom-Json
    return ($TimeZoneData | Where-Object {$_.utc -match $TimeZoneInfo.timezone}).value
}
