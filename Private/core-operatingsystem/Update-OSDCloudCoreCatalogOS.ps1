function Update-OSDCloudCoreCatalogOS {
	<#
	.SYNOPSIS
		Updates the Windows 11 products operating system catalog.

	.DESCRIPTION
		Queries the Microsoft Update Metadata Service for the current Windows 11 products
		catalog, verifies the downloaded CAB size and SHA256 digest, and validates the
		extracted catalog before changing persistent content.

		Publishes the validated catalog to the module operating system catalog directory using
		the build and release timestamp from its ESD filenames, for example
		26200.9457.260913-0221.xml. The catalog is also copied to
		OSDCloud\catalogs\operatingsystems on each writable drive letter that already contains
		an OSDCloud directory. Existing module catalogs remain in place, and an existing module
		catalog name is never overwritten with different content.

		Any prerequisite, download, validation, or module publication failure is reported as a
		warning and does not produce a terminating error. A failure to update one external drive
		is reported as a warning and does not prevent other eligible drives from being updated.
		WhatIf still performs the network request, CAB download, extraction, and validation; it
		previews only publication and drive synchronization.

	.PARAMETER MinimumItemCount
		Specifies the minimum number of ESD records required before a catalog is accepted.
		The default is 50. Valid values are 1 through 100000.

	.EXAMPLE
		Update-OSDCloudCoreCatalogOS

		Downloads and validates the current Windows 11 products catalog, publishes it to the
		module, and synchronizes it to eligible writable drives.

	.EXAMPLE
		Update-OSDCloudCoreCatalogOS -WhatIf

		Downloads and validates the current catalog, then previews module publication and drive
		synchronization without changing either location.

	.INPUTS
		None. This function does not accept pipeline input.

	.OUTPUTS
		System.Management.Automation.PSCustomObject. Returns the detected build, module catalog
		path, publication status, synchronized drive catalog paths, item count, and SHA256 hash.

	.LINK
		https://github.com/OSDeploy/OSD/tree/master/docs

	.NOTES
		Author: David Segura - Recast Software
		2026-09-30 - Added validated operating-system catalog publication
		Requires Windows, Windows PowerShell 5.1 or later, internet access, expand.exe, writable
		temporary storage, and write access to the module catalog directory when updating.
	#>
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
	[OutputType([System.Management.Automation.PSCustomObject])]
	param (
		[Parameter(Mandatory = $false)]
		[ValidateRange(1, 100000)]
		[System.Int32]
		$MinimumItemCount = 50
	)

	$Error.Clear()
	$ErrorActionPreference = 'Stop'
	$functionName = $MyInvocation.MyCommand.Name
	Write-Verbose "[$(Get-Date -format s)] [$functionName] Start"

	$metadataUri = 'https://fe3.delivery.mp.microsoft.com/UpdateMetadataService/updates/search/v1/bydeviceinfo'
	$products = 'PN=Windows.Products.Cab.amd64&V=0.0.0.0'
	$deviceAttributes = 'DUScan=1;OSVersion=10.0.26100.1'
	$moduleCatalogDirectory = Join-Path $MyInvocation.MyCommand.Module.ModuleBase 'core\operatingsystems'
	$temporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('osdcloud-catalog-' + [guid]::NewGuid().ToString())
	$writeProbePath = $null
	$stagedModulePath = $null
	$stagedDrivePaths = @()

	$getCatalogNameMetadata = {
		param (
			[System.String]
			$Name
		)

		$nameMatch = [regex]::Match(
			$Name,
			'^(?<Identity>(?<Major>\d{5})\.(?<Ubr>0|[1-9]\d*)\.(?<Timestamp>\d{6}-\d{4}))\.xml$',
			[System.Text.RegularExpressions.RegexOptions]::CultureInvariant
		)
		if (-not $nameMatch.Success) {
			return
		}

		$releaseDateTime = [datetime]::MinValue
		if (-not [datetime]::TryParseExact(
			$nameMatch.Groups['Timestamp'].Value,
			'yyMMdd-HHmm',
			[System.Globalization.CultureInfo]::InvariantCulture,
			[System.Globalization.DateTimeStyles]::None,
			[ref]$releaseDateTime
		)) {
			return
		}

		$build = $null
		if (-not [version]::TryParse(
			"$($nameMatch.Groups['Major'].Value).$($nameMatch.Groups['Ubr'].Value)",
			[ref]$build
		)) {
			return
		}

		[pscustomobject]@{
			Identity        = $nameMatch.Groups['Identity'].Value
			Build           = $build
			ReleaseDateTime = $releaseDateTime
		}
	}

	try {
		if (-not (Test-Path -LiteralPath $moduleCatalogDirectory -PathType Container)) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Module catalog directory was not found at '$moduleCatalogDirectory'."
			return
		}

		if (-not $WhatIfPreference) {
			$writeProbePath = Join-Path $moduleCatalogDirectory ('.write-test-' + [guid]::NewGuid().ToString() + '.tmp')
			$writeProbe = [System.IO.File]::Open(
				$writeProbePath,
				[System.IO.FileMode]::CreateNew,
				[System.IO.FileAccess]::Write,
				[System.IO.FileShare]::None
			)
			$writeProbe.Dispose()
			Remove-Item -LiteralPath $writeProbePath -Force -WhatIf:$false
			$writeProbePath = $null
		}

		$null = New-Item -Path $temporaryDirectory -ItemType Directory -WhatIf:$false
		$body = [ordered]@{
			Products         = $products
			DeviceAttributes = $deviceAttributes
		} | ConvertTo-Json -Compress

		$response = Invoke-RestMethod `
			-Uri $metadataUri `
			-Method Post `
			-ContentType 'application/json' `
			-Headers @{ Accept = '*/*' } `
			-Body $body

		if ($response -is [array]) {
			if ($response.Count -ne 1) {
				Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Microsoft metadata returned $($response.Count) response records; expected one."
				return
			}
			$response = $response[0]
		}

		$cabRecords = @($response.FileLocations | Where-Object { $_.FileName -eq 'products.cab' })
		if ($cabRecords.Count -ne 1) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Microsoft metadata returned $($cabRecords.Count) products.cab records; expected one."
			return
		}

		$cabRecord = $cabRecords[0]
		$cabUri = [uri]$cabRecord.Url
		if (-not $cabUri.IsAbsoluteUri -or $cabUri.Scheme -notin @('http', 'https')) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Microsoft metadata returned an invalid products.cab URL: $($cabRecord.Url)"
			return
		}

		[long]$expectedCabSize = 0
		if (-not [long]::TryParse([string]$cabRecord.Size, [ref]$expectedCabSize) -or $expectedCabSize -le 0) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Microsoft metadata returned an invalid products.cab size: $($cabRecord.Size)"
			return
		}

		try {
			$expectedDigest = [Convert]::FromBase64String([string]$cabRecord.Digest)
		}
		catch {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Microsoft metadata returned an invalid products.cab SHA256 digest."
			return
		}
		if ($expectedDigest.Length -ne 32) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Microsoft metadata returned a $($expectedDigest.Length)-byte digest; expected SHA256."
			return
		}

		$cabPath = Join-Path $temporaryDirectory 'products.cab'
		Invoke-WebRequest -Uri $cabUri -OutFile $cabPath -Headers @{ Accept = '*/*' }

		$actualCabSize = (Get-Item -LiteralPath $cabPath).Length
		if ($actualCabSize -ne $expectedCabSize) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Downloaded products.cab size mismatch. Expected $expectedCabSize bytes, got $actualCabSize bytes."
			return
		}

		$hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
		$cabStream = [System.IO.File]::OpenRead($cabPath)
		try {
			$actualDigest = $hashAlgorithm.ComputeHash($cabStream)
		}
		finally {
			$cabStream.Dispose()
			$hashAlgorithm.Dispose()
		}
		if ([Convert]::ToBase64String($actualDigest) -cne [Convert]::ToBase64String($expectedDigest)) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Downloaded products.cab SHA256 digest does not match Microsoft metadata."
			return
		}

		$extractDirectory = Join-Path $temporaryDirectory 'expanded'
		$null = New-Item -Path $extractDirectory -ItemType Directory -WhatIf:$false
		$expandPath = Join-Path $env:SystemRoot 'System32\expand.exe'
		if (-not (Test-Path -LiteralPath $expandPath -PathType Leaf)) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Windows expand.exe was not found at '$expandPath'."
			return
		}

		$sourceXmlPath = Join-Path $extractDirectory 'products.xml'
		$expandResult = & $expandPath $cabPath $sourceXmlPath 2>&1
		if ($LASTEXITCODE -ne 0) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. expand.exe failed with exit code ${LASTEXITCODE}: $expandResult"
			return
		}
		if (-not (Test-Path -LiteralPath $sourceXmlPath -PathType Leaf)) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. expand.exe did not produce products.xml."
			return
		}

		[xml]$catalog = Get-Content -LiteralPath $sourceXmlPath -Raw
		$fileNodes = @($catalog.MCT.Catalogs.Catalog.PublishedMedia.Files.File)
		$esdNodes = @($fileNodes | Where-Object { [string]$_.FileName -like '*.esd' })
		if ($esdNodes.Count -lt $MinimumItemCount) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Catalog contains $($esdNodes.Count) ESD records; expected at least $MinimumItemCount."
			return
		}

		$requiredProperties = @('FileName', 'LanguageCode', 'Edition', 'Architecture', 'Size', 'Sha256', 'FilePath')
		$catalogIdentities = @()
		foreach ($node in $esdNodes) {
			foreach ($property in $requiredProperties) {
				if ([string]::IsNullOrWhiteSpace([string]$node.$property)) {
					Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Catalog record '$($node.FileName)' is missing required property '$property'."
					return
				}
			}

			if ([string]$node.Sha256 -notmatch '^[a-fA-F0-9]{64}$') {
				Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Catalog record '$($node.FileName)' has an invalid SHA256 value."
				return
			}

			[long]$fileSize = 0
			if (-not [long]::TryParse([string]$node.Size, [ref]$fileSize) -or $fileSize -le 0) {
				Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Catalog record '$($node.FileName)' has an invalid size."
				return
			}

			$identityMatch = [regex]::Match(
				[string]$node.FileName,
				'^(?<Identity>\d{5}\.(?:0|[1-9]\d*)\.\d{6}-\d{4})\..+\.esd$',
				[System.Text.RegularExpressions.RegexOptions]::CultureInvariant
			)
			if (-not $identityMatch.Success) {
				Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Catalog record '$($node.FileName)' does not contain a supported build identity."
				return
			}
			$catalogIdentities += $identityMatch.Groups['Identity'].Value
		}

		$catalogIdentities = @($catalogIdentities | Sort-Object -Unique)
		if ($catalogIdentities.Count -ne 1) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Catalog contains $($catalogIdentities.Count) build and release identities; expected one."
			return
		}

		$catalogIdentity = $catalogIdentities[0]
		$catalogMetadata = & $getCatalogNameMetadata "$catalogIdentity.xml"
		if (-not $catalogMetadata) {
			Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Catalog identity '$catalogIdentity' is not valid."
			return
		}
		$build = $catalogMetadata.Build.ToString()

		foreach ($architecture in @('x64', 'ARM64')) {
			$target = @(
				$esdNodes | Where-Object {
					[string]$_.LanguageCode -eq 'en-us' -and
					[string]$_.Edition -eq 'Enterprise' -and
					[string]$_.Architecture -eq $architecture
				}
			)
			if ($target.Count -lt 1) {
				Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Catalog does not contain an en-us Enterprise $architecture ESD record."
				return
			}
		}

		$destinationName = "$catalogIdentity.xml"
		$moduleCatalogPath = Join-Path $moduleCatalogDirectory $destinationName
		$sourceHash = (Get-FileHash -LiteralPath $sourceXmlPath -Algorithm SHA256).Hash
		$destinationExists = Test-Path -LiteralPath $moduleCatalogPath -PathType Leaf

		if ($destinationExists) {
			$destinationHash = (Get-FileHash -LiteralPath $moduleCatalogPath -Algorithm SHA256).Hash
			if ($sourceHash -cne $destinationHash) {
				Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Catalog '$destinationName' already exists with different content."
				return
			}
		}

		foreach ($existingCatalog in Get-ChildItem -LiteralPath $moduleCatalogDirectory -Filter '*.xml' -File) {
			if ($existingCatalog.Name -eq $destinationName) {
				continue
			}

			$existingMetadata = & $getCatalogNameMetadata $existingCatalog.Name
			if (-not $existingMetadata) {
				Write-Verbose "[$(Get-Date -format s)] [$functionName] Ignoring unrecognized catalog filename: $($existingCatalog.FullName)"
				continue
			}

			$isNewerBuild = $existingMetadata.Build -gt $catalogMetadata.Build
			$isNewerRelease = $existingMetadata.Build -eq $catalogMetadata.Build -and
				$existingMetadata.ReleaseDateTime -gt $catalogMetadata.ReleaseDateTime
			if ($isNewerBuild -or $isNewerRelease) {
				Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. Existing catalog '$($existingCatalog.Name)' is newer than downloaded catalog $destinationName."
				return
			}
		}

		$published = $false
		if (-not $destinationExists -and $PSCmdlet.ShouldProcess($moduleCatalogPath, 'Publish the OS catalog')) {
			$stagedModulePath = Join-Path $moduleCatalogDirectory ('.' + $destinationName + '.' + [guid]::NewGuid().ToString() + '.tmp')
			[System.IO.File]::Copy($sourceXmlPath, $stagedModulePath, $false)
			[System.IO.File]::Move($stagedModulePath, $moduleCatalogPath)
			$stagedModulePath = $null
			$published = $true
		}

		$driveCatalogPaths = @()
		$eligibleDrives = @(
			Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue |
			Where-Object { $_.Root -match '^[A-Z]:\\$' } |
			Where-Object { Test-Path -LiteralPath (Join-Path $_.Root 'OSDCloud') -PathType Container }
		)

		foreach ($drive in $eligibleDrives) {
			$driveCatalogDirectory = Join-Path $drive.Root 'OSDCloud\catalogs\operatingsystems'
			$driveCatalogPath = Join-Path $driveCatalogDirectory $destinationName
			if (-not $PSCmdlet.ShouldProcess($driveCatalogPath, 'Synchronize the OS catalog')) {
				continue
			}

			$stagedDrivePath = $null
			try {
				$null = New-Item -Path $driveCatalogDirectory -ItemType Directory -Force
				$stagedDrivePath = Join-Path $driveCatalogDirectory ('.' + $destinationName + '.' + [guid]::NewGuid().ToString() + '.tmp')
				$stagedDrivePaths += $stagedDrivePath
				[System.IO.File]::Copy($sourceXmlPath, $stagedDrivePath, $false)
				Move-Item -LiteralPath $stagedDrivePath -Destination $driveCatalogPath -Force
				$stagedDrivePaths = @($stagedDrivePaths | Where-Object { $_ -ne $stagedDrivePath })
				$driveCatalogPaths += $driveCatalogPath
			}
			catch {
				Write-Warning "[$(Get-Date -format s)] [$functionName] Unable to synchronize the operating system catalog to '$driveCatalogPath': $($_.Exception.Message)"
			}
		}

		[pscustomobject]@{
			Build             = $build
			ModuleCatalogPath = $moduleCatalogPath
			Published         = $published
			DriveCatalogPaths = $driveCatalogPaths
			ItemCount         = $esdNodes.Count
			Sha256            = $sourceHash
		}
	}
	catch {
		Write-Warning "[$(Get-Date -format s)] [$functionName] Catalog update was not successful. $($_.Exception.Message)"
	}
	finally {
		foreach ($cleanupPath in @($stagedModulePath) + @($stagedDrivePaths) + @($writeProbePath)) {
			if ($cleanupPath -and (Test-Path -LiteralPath $cleanupPath -PathType Leaf)) {
				Remove-Item -LiteralPath $cleanupPath -Force -ErrorAction SilentlyContinue -WhatIf:$false
			}
		}
		if (Test-Path -LiteralPath $temporaryDirectory) {
			Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force -ErrorAction SilentlyContinue -WhatIf:$false
		}
		Write-Verbose "[$(Get-Date -format s)] [$functionName] End"
	}
}
