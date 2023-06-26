$CurrentDateTime = (Get-Date).ToUniversalTime()
Write-Host "Current DateTime is " -NoNewline; Write-Host -ForegroundColor Green "$CurrentDateTime UTC"
Write-Host

$OSDModule = Find-Module OSD
$OSDModuleVersion = $OSDModule.Version
$OSDCloudCLIDatePublished = $OSDModule.PublishedDate
$PublishedHoursAgo = [math]::Round(($CurrentDateTime - $OSDCloudCLIDatePublished).TotalHours)
$OSDModuleDownloadCount = ($OSDModule.AdditionalMetadata).versionDownloadCount

Write-Host "OSD PowerShell Module" -ForegroundColor Cyan
Write-Host "The latest version is " -NoNewline; Write-Host -ForegroundColor Green $OSDModuleVersion
Write-Host "Published at " -NoNewline; Write-Host -ForegroundColor Green "$OSDCloudCLIDatePublished UTC " -NoNewline; Write-Host "($PublishedHoursAgo hours ago)"
Write-Host "This version has been installed or saved " -NoNewline; Write-Host -ForegroundColor Green "$OSDModuleDownloadCount " -NoNewline; Write-Host "times"
Write-Host

$OSDCloud = Find-Module OSDCloudCLI
$OSDCloudDatePublished = $OSDCloud.PublishedDate
$OSDCloudDownloadCount = ($OSDCloud.AdditionalMetadata).versionDownloadCount
$TimeDifference = ((Get-Date).ToUniversalTime()) - $OSDCloudDatePublished
$PublishedHoursAgo = [math]::Round(($TimeDifference).TotalHours)
$DevicesPerHour = [math]::Round(($OSDCloudDownloadCount / $TimeDifference.TotalHours),2)
$DevicesPerDay = [math]::Round(($DevicesPerHour * 24))
$DevicesPerWeek = [math]::Round(($DevicesPerHour * 24 * 7))
$DevicesPerMonth = [math]::Round(($DevicesPerHour * 24 * 365) / 12)
$DevicesPerYear = [math]::Round($DevicesPerHour * 24 * 365)
Write-Host -ForegroundColor Cyan "OSDCloud CLI (Start-OSDCloud)"
Write-Host "Deployment Count started $PublishedHoursAgo hours ago at " -NoNewline; Write-Host -ForegroundColor Green "$OSDCloudDatePublished UTC"
Write-Host -ForegroundColor Green $OSDCloudDownloadCount -NoNewline; Write-Host " devices have been deployed using this method"
Write-Host "Current usage rate is " -NoNewline; Write-Host -ForegroundColor Green "$DevicesPerHour " -NoNewline; Write-Host "devices per hour"
Write-Host -ForegroundColor DarkGray "$DevicesPerDay per day / $DevicesPerWeek per week / $DevicesPerMonth per month / $DevicesPerYear per year"
Write-Host

$OSDCloud = Find-Module OSDCloudGUI
$OSDCloudDatePublished = $OSDCloud.PublishedDate
$OSDCloudDownloadCount = ($OSDCloud.AdditionalMetadata).versionDownloadCount
$TimeDifference = ((Get-Date).ToUniversalTime()) - $OSDCloudDatePublished
$PublishedHoursAgo = [math]::Round(($TimeDifference).TotalHours)
$DevicesPerHour = [math]::Round(($OSDCloudDownloadCount / $TimeDifference.TotalHours),2)
$DevicesPerDay = [math]::Round(($DevicesPerHour * 24))
$DevicesPerWeek = [math]::Round(($DevicesPerHour * 24 * 7))
$DevicesPerMonth = [math]::Round(($DevicesPerHour * 24 * 365) / 12)
$DevicesPerYear = [math]::Round($DevicesPerHour * 24 * 365)
Write-Host -ForegroundColor Cyan "OSDCloud GUI (Start-OSDCloudGUI)"
Write-Host "Deployment Count started $PublishedHoursAgo hours ago at " -NoNewline; Write-Host -ForegroundColor Green "$OSDCloudDatePublished UTC"
Write-Host -ForegroundColor Green $OSDCloudDownloadCount -NoNewline; Write-Host " devices have been deployed using this method"
Write-Host "Current usage rate is " -NoNewline; Write-Host -ForegroundColor Green "$DevicesPerHour " -NoNewline; Write-Host "devices per hour"
Write-Host -ForegroundColor DarkGray "$DevicesPerDay per day / $DevicesPerWeek per week / $DevicesPerMonth per month / $DevicesPerYear per year"
Write-Host

$OSDCloud = Find-Module OSDCloudAzure
$OSDCloudDatePublished = $OSDCloud.PublishedDate
$OSDCloudDownloadCount = ($OSDCloud.AdditionalMetadata).versionDownloadCount
$TimeDifference = ((Get-Date).ToUniversalTime()) - $OSDCloudDatePublished
$PublishedHoursAgo = [math]::Round(($TimeDifference).TotalHours)
$DevicesPerHour = [math]::Round(($OSDCloudDownloadCount / $TimeDifference.TotalHours),2)
$DevicesPerDay = [math]::Round(($DevicesPerHour * 24))
$DevicesPerWeek = [math]::Round(($DevicesPerHour * 24 * 7))
$DevicesPerMonth = [math]::Round(($DevicesPerHour * 24 * 365) / 12)
$DevicesPerYear = [math]::Round($DevicesPerHour * 24 * 365)
Write-Host -ForegroundColor Cyan "OSDCloud Azure (Start-OSDCloudAzure)"
Write-Host "Deployment Count started $PublishedHoursAgo hours ago at " -NoNewline; Write-Host -ForegroundColor Green "$OSDCloudDatePublished UTC"
Write-Host -ForegroundColor Green $OSDCloudDownloadCount -NoNewline; Write-Host " devices have been deployed using this method"
Write-Host "Current usage rate is " -NoNewline; Write-Host -ForegroundColor Green "$DevicesPerHour " -NoNewline; Write-Host "devices per hour"
Write-Host -ForegroundColor DarkGray "$DevicesPerDay per day / $DevicesPerWeek per week / $DevicesPerMonth per month / $DevicesPerYear per year"
Write-Host