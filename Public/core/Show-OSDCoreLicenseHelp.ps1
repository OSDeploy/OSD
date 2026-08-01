function Show-OSDCoreLicenseHelp {
	<#
	.SYNOPSIS
	Displays instructions for setting the Recast Core license for OSDCloud.

	.DESCRIPTION
	Provides a concise, step-by-step guide to acquire and place the
	Right Click Tools Community Edition license used by OSDCloud.
	The function also checks the local license directory and reports
	whether any .license2 files are currently present.

	.PARAMETER LicensePath
	The directory path where .license2 files should be stored when not using
	a full Right Click Tools Community Edition installation.

	.EXAMPLE
	Show-OSDCoreLicenseHelp
	Displays the default setup steps and checks ProgramData\Recast Software\Licenses.

	.EXAMPLE
	Show-OSDCoreLicenseHelp -LicensePath 'D:\Licenses'
	Displays setup steps and checks a custom license directory.

	.LINK
	https://github.com/OSDeploy/OSD/tree/master/docs

	.LINK
	https://portal.recastsoftware.com/

	.NOTES
	Author: David Segura - Recast Software
	2026-07-22 - Initial help block created
	2026-07-22 - Added OSDCloud Recast Core license setup guidance
	#>
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]$LicensePath = (Join-Path -Path $env:ProgramData -ChildPath 'Recast Software\Licenses')
	)

	Write-Host -ForegroundColor Cyan 'Recast Community License for OSD | OSDCloud | OSDeploy'
	Write-Host -ForegroundColor DarkGray 'Follow these steps to set the license used by OSDCloud:'
	Write-Host ''

	Write-Host -ForegroundColor Yellow '1. Login or Register for Recast Software Community Portal:'
	Write-Host '   https://portal.recastsoftware.com/'
	Write-Host ''

	Write-Host -ForegroundColor Yellow '2. Download a license for Right Click Tools Community Edition.'
	Write-Host ''

	Write-Host -ForegroundColor Yellow '3. Either install Right Click Tools Community Edition or place your *.license2 files here:'
	Write-Host "   $LicensePath"
	Write-Host ''

	if (Test-Path -Path $LicensePath -PathType Container) {
		$LicenseCount = @(Get-ChildItem -Path $LicensePath -Filter '*.license2' -File -ErrorAction Ignore).Count
		if ($LicenseCount -gt 0) {
			Write-Host -ForegroundColor DarkGreen "Found $LicenseCount .license2 file(s) in $LicensePath"
		}
		else {
			Write-Host -ForegroundColor DarkYellow "No .license2 files found yet in $LicensePath"
		}
	}
	else {
		Write-Host -ForegroundColor DarkYellow "License path does not exist yet: $LicensePath"
	}
}
