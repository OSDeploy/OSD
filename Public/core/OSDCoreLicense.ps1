function Get-OSDCoreLicense {
	<#
	.SYNOPSIS
	Returns a single Recast Core license object.

	.DESCRIPTION
	Reads .license2 files from the Recast Software license directory, parses the
	JSON payload, validates expected fields, removes duplicates, and returns one
	selected license object.
	Selection precedence is:
	1) PreferredEmail exact match (when provided)
	2) Any non-empty email that is not support@recastsoftware.com
	3) support@recastsoftware.com fallback
	4) Empty or null email
	Expired licenses are still eligible for selection.

	.PARAMETER Path
	The directory path to search for .license2 files.

	.PARAMETER PreferredEmail
	Optional preferred email value used to prioritize license selection when
	multiple license files exist.
	Comparison is case-insensitive.

	.OUTPUTS
	PSCustomObject. Returns one selected license object, or $null when no
	license files are available.

	.EXAMPLE
	Get-OSDCoreLicense
	Returns a selected validated license object from ProgramData\Recast Software\Licenses.

	.EXAMPLE
	Get-OSDCoreLicense -Path 'D:\Licenses'
	Returns a selected validated license object from a custom directory.

	.EXAMPLE
	Get-OSDCoreLicense -PreferredEmail 'david@segura.org'
	Prefers a license with the specified email when available.

	.LINK
	https://github.com/OSDeploy/OSD/tree/master/docs

	.NOTES
	Author: David Segura - Recast Software
	2026-07-17 - Initial help block created
	2026-07-17 - Added content parsing, validation, and de-duplication
	2026-07-17 - Added single-object selection with email preference and support fallback
	#>
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]$Path = (Join-Path -Path $env:ProgramData -ChildPath 'Recast Software\Licenses'),

		[Parameter()]
		[string]$PreferredEmail
	)

	if (-not (Test-Path -Path $Path -PathType Container)) {
		try {
			$null = New-Item -Path $Path -ItemType Directory -Force -ErrorAction Stop
		}
		catch {
			Write-Verbose "Unable to create license path: $Path. Error: $($_.Exception.Message)"
			return $null
		}
	}

	Write-Verbose "Starting license discovery in path: $Path"

	if (-not (Test-Path -Path $Path -PathType Container)) {
		Write-Verbose "License path not found: $Path"
		return $null
	}

	# Gather candidate license files newest-first so tie-breaking remains deterministic.
	$LicenseFiles = Get-ChildItem -Path $Path -Filter '*.license2' -File -ErrorAction Ignore |
	Sort-Object -Property LastWriteTime -Descending
	Write-Verbose "Discovered $(@($LicenseFiles).Count) license file(s)"

	if (-not $LicenseFiles) {
		Write-Verbose 'No license files found'
		return $null
	}

	# Parse each file into candidate entries and track seen identities for deduplication.
	$ParsedResults = New-Object System.Collections.Generic.List[object]
	$Seen = @{}

	foreach ($LicenseFile in $LicenseFiles) {
		$RawContent = $null
		$Payload = $null

		try {
			Write-Verbose "Reading license file: $($LicenseFile.FullName)"
			$RawContent = Get-Content -Path $LicenseFile.FullName -Raw -ErrorAction Stop
			$Payload = $RawContent | ConvertFrom-Json -ErrorAction Stop
			Write-Verbose "Parsed $(@($Payload).Count) payload entr$(if (@($Payload).Count -eq 1) {'y'} else {'ies'}) from $($LicenseFile.Name)"
		}
		catch {
			Write-Verbose "Skipping unreadable license file: $($LicenseFile.FullName). Error: $($_.Exception.Message)"
			continue
		}

		foreach ($Entry in @($Payload)) {
			# Validate required schema fields and normalize commonly used values.
			$ValidationErrors = New-Object System.Collections.Generic.List[string]
			$LicenseGuid = $null
			$ExpirationDate = $null
			$ActivationExpirationDate = $null

			if (-not ($Entry.PSObject.Properties.Name -contains 'Data')) {
				$ValidationErrors.Add('Missing Data object')
			}

			if (-not ($Entry.PSObject.Properties.Name -contains 'Signature') -or [string]::IsNullOrWhiteSpace([string]$Entry.Signature)) {
				$ValidationErrors.Add('Missing Signature')
			}

			if ($Entry.Data) {
				if (-not ($Entry.Data.PSObject.Properties.Name -contains 'LicenseGuid') -or [string]::IsNullOrWhiteSpace([string]$Entry.Data.LicenseGuid)) {
					$ValidationErrors.Add('Missing Data.LicenseGuid')
				}
				else {
					try {
						$LicenseGuid = [guid]([string]$Entry.Data.LicenseGuid)
					}
					catch {
						$ValidationErrors.Add('Invalid Data.LicenseGuid format')
					}
				}

				if (-not ($Entry.Data.PSObject.Properties.Name -contains 'AuthorizedPluginCommands') -or -not @($Entry.Data.AuthorizedPluginCommands)) {
					$ValidationErrors.Add('Missing or empty Data.AuthorizedPluginCommands')
				}
			}

			if (($Entry.PSObject.Properties.Name -contains 'Expiration') -and -not [string]::IsNullOrWhiteSpace([string]$Entry.Expiration)) {
				try {
					$ExpirationDate = [datetime]([string]$Entry.Expiration)
				}
				catch {
					$ValidationErrors.Add('Invalid Expiration date format')
				}
			}

			if (($Entry.PSObject.Properties.Name -contains 'ActivationExpiration') -and -not [string]::IsNullOrWhiteSpace([string]$Entry.ActivationExpiration)) {
				try {
					$ActivationExpirationDate = [datetime]([string]$Entry.ActivationExpiration)
				}
				catch {
					$ValidationErrors.Add('Invalid ActivationExpiration date format')
				}
			}

			$SignatureHash = $null
			if ($Entry.PSObject.Properties.Name -contains 'Signature' -and -not [string]::IsNullOrWhiteSpace([string]$Entry.Signature)) {
				$HashProvider = [System.Security.Cryptography.SHA256]::Create()
				try {
					$Bytes = [System.Text.Encoding]::UTF8.GetBytes([string]$Entry.Signature)
					$SignatureHash = [System.BitConverter]::ToString($HashProvider.ComputeHash($Bytes)).Replace('-', '').ToLowerInvariant()
				}
				finally {
					$HashProvider.Dispose()
				}
			}

			$DedupKey = $null
			if ($LicenseGuid) {
				$DedupKey = "guid:$($LicenseGuid.ToString().ToLowerInvariant())"
			}
			elseif ($SignatureHash) {
				$DedupKey = "signature:$SignatureHash"
			}
			else {
				$DedupKey = "file:$($LicenseFile.FullName.ToLowerInvariant())"
			}

			if ($Seen.ContainsKey($DedupKey)) {
				Write-Verbose "Skipping duplicate license: $($LicenseFile.FullName)"
				continue
			}

			# Mark identity as seen and materialize a normalized candidate object.
			$Seen[$DedupKey] = $true

			$ParsedResults.Add([pscustomobject]@{
					FileName                     = $LicenseFile.Name
					FullName                     = $LicenseFile.FullName
					LastWriteTime                = $LicenseFile.LastWriteTime
					LicenseGuid                  = if ($LicenseGuid) { $LicenseGuid.ToString() } else { $null }
					Organization                 = $Entry.Data.Organization
					FirstName                    = $Entry.Data.FirstName
					LastName                     = $Entry.Data.LastName
					Email                        = $Entry.Data.Email
					LicenseType                  = $Entry.Data.LicenseType
					DeviceCount                  = $Entry.Data.DeviceCount
					UserCount                    = $Entry.Data.UserCount
					Expiration                   = $ExpirationDate
					ActivationExpiration         = $ActivationExpirationDate
					AuthorizedPluginCommandCount = @($Entry.Data.AuthorizedPluginCommands).Count
					SignatureHash                = $SignatureHash
					IsValid                      = ($ValidationErrors.Count -eq 0)
					ValidationErrors             = @($ValidationErrors)
					Data                         = $Entry.Data
				})
		}
	}

	if (-not $ParsedResults) {
		Write-Verbose 'No valid parseable license candidates were produced'
		return $null
	}
	Write-Verbose "Candidate count after de-duplication: $($ParsedResults.Count)"

	$PreferredEmailNormalized = $null
	if (-not [string]::IsNullOrWhiteSpace($PreferredEmail)) {
		$PreferredEmailNormalized = $PreferredEmail.Trim().ToLowerInvariant()
		Write-Verbose "PreferredEmail provided: $PreferredEmailNormalized"
	}
	else {
		Write-Verbose 'PreferredEmail not provided; using default selection precedence'
	}

	$SupportFallbackEmail = 'support@recastsoftware.com'

	# Rank candidates by email precedence, then by newest timestamp, then file name.
	$SelectedLicense = $ParsedResults |
	Sort-Object -Property @(
		@{
			Expression = {
				$EmailValue = $null
				if (-not [string]::IsNullOrWhiteSpace([string]$_.Email)) {
					$EmailValue = ([string]$_.Email).Trim().ToLowerInvariant()
				}

				if ($PreferredEmailNormalized -and $EmailValue -eq $PreferredEmailNormalized) {
					0
				}
				elseif ($EmailValue -and $EmailValue -ne $SupportFallbackEmail) {
					1
				}
				elseif ($EmailValue -eq $SupportFallbackEmail) {
					2
				}
				else {
					3
				}
			}
			Ascending  = $true
		},
		@{
			Expression = { $_.LastWriteTime }
			Descending = $true
		},
		@{
			Expression = { $_.FileName }
			Ascending  = $true
		}
	) |
	Select-Object -First 1

	if ($SelectedLicense) {
		Write-Verbose "Selected license file: $($SelectedLicense.FileName) (Email: $($SelectedLicense.Email); LicenseGuid: $($SelectedLicense.LicenseGuid))"
	}

	$SelectedLicense
}
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
