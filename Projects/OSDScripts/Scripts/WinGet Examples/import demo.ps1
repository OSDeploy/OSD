#Requires -RunAsAdministrator
<#
.DESCRIPTION
The import command of the winget tool imports a JSON file of apps to install.
The import command combined with the export command allows you to batch install applications on your PC.
The import command is often used to share your developer environment or build up your PC image with your favorite apps.

.LINK
https://learn.microsoft.com/en-us/windows/package-manager/winget/import

.NOTES
Usage
winget import [-i] <import-file> [<options>]

Arguments
-i,--import-file            JSON file describing the packages to install.

Options
--ignore-unavailable        Suppresses errors if the app requested is unavailable.
--ignore-versions           Ignores versions specified in the JSON file and installs the latest available version.
--accept-package-agreements Used to accept the license agreement, and avoid the prompt.
--accept-source-agreements  Used to accept the source license agreement, and avoid the prompt.
--verbose-logs	            Used to override the logging setting and create a verbose log.
#>
[CmdletBinding()]
param()

$WinGetJson = @'
{
	"$schema" : "https://aka.ms/winget-packages.schema.2.0.json",

	"title": "OSD Created WinGet Export",
	"description": "ADK MDT",

	"WinGetVersion" : "1.2.10691",
	"CreationDate" : "2023-06-25T23:43:27.520-00:00",

	"Sources" : 
	[
		{
			"SourceDetails" : 
			{
				"Argument" : "https://storeedgefd.dsx.mp.microsoft.com/v9.0",
				"Identifier" : "StoreEdgeFD",
				"Name" : "msstore",
				"Type" : "Microsoft.Rest"
			},
			"Packages" : 
			[
				{
					"PackageIdentifier" : "9NBLGGH4TX22"
				}
			]
		},
		{
			"SourceDetails" : 
			{
				"Argument" : "https://winget.azureedge.net/cache",
				"Identifier" : "Microsoft.Winget.Source_8wekyb3d8bbwe",
				"Name" : "winget",
				"Type" : "Microsoft.PreIndexed.Package"
			},
			"Packages" : 
			[
				{
					"PackageIdentifier" : "Microsoft.WindowsADK",
					"Version" : "10.1.22621.1"
				},
				{
					"PackageIdentifier" : "Microsoft.ADKPEAddon",
					"Version" : "10.1.22621.1"
				},
				{
					"PackageIdentifier" : "Microsoft.DeploymentToolkit",
					"Version" : "6.3.8456.1000"
				},
				{
					"PackageIdentifier" : "Git.Git",
					"Version" : "2.41.0"
				},
				{
					"PackageIdentifier" : "GitHub.GitHubDesktop",
					"Version" : "3.2.3"
				},
				{
					"PackageIdentifier" : "Microsoft.VisualStudioCode",
					"Version" : "1.79.2"
				},
				{
					"PackageIdentifier" : "Google.Chrome",
					"Version" : "114.0.5735.134"
				},
				{
					"PackageIdentifier" : "Notepad++.Notepad++",
					"Version" : "8.5.4"
				},
				{
					"PackageIdentifier" : "7zip.7zip",
					"Version" : "22.01.00.0"
				}
			]
		}
	]
}
'@

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    $WinGetJson | Out-File -FilePath $env:TEMP\wingetimport.json -Encoding utf8 -Force
    winget import --import-file $env:TEMP\wingetimport.json
}