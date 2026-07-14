function Convert-KeyboardLayoutToLanguageCode {
	<#
	.SYNOPSIS
	Converts a Windows keyboard layout value to a language/culture code.

	.DESCRIPTION
	Resolves the culture tag (for example, en-US or fr-FR) from a keyboard
	layout hexadecimal string such as 00000409. If no keyboard layout is
	provided, the function attempts to detect the current layout from
	Win32_Keyboard. When conversion fails, a fallback language code is returned.

	.PARAMETER KeyboardLayout
	Keyboard layout hexadecimal value (KLID), for example 00000409 or
	00010409. The function uses the trailing 4 hex characters as the LCID.

	.PARAMETER FallbackLanguageCode
	Language code to return when keyboard layout detection or conversion fails.
	Default is en-US.

	.PARAMETER LowerCase
	Returns the language code in lowercase (for example en-us).

	.EXAMPLE
	Convert-KeyboardLayoutToLanguageCode
	Detects the active keyboard layout from Win32_Keyboard and returns the
	resolved language code.

	.EXAMPLE
	Convert-KeyboardLayoutToLanguageCode -KeyboardLayout '0000040C'
	Returns fr-FR.

	.EXAMPLE
	Convert-KeyboardLayoutToLanguageCode -KeyboardLayout '00000409' -LowerCase
	Returns en-us.

	.LINK
	https://github.com/OSDeploy/OSD/tree/master/Docs

	.LINK
	https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-language-pack-default-values

	.NOTES
	Author: David Segura - Recast Software
	2026-07-14 - Initial help block created
	2026-07-14 - Added keyboard layout to language code conversion with fallback behavior
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('Layout', 'KLID')]
		[string]
		$KeyboardLayout,

		[Parameter(Mandatory = $false)]
		[ValidateNotNullOrEmpty()]
		[string]
		$FallbackLanguageCode = 'en-US',

		[Parameter(Mandatory = $false)]
		[switch]
		$LowerCase
	)

	process {
		$layoutToResolve = $KeyboardLayout

		if ([string]::IsNullOrWhiteSpace($layoutToResolve)) {
			try {
				$layoutToResolve = [string](Get-CimInstance -ClassName Win32_Keyboard -ErrorAction Stop | Select-Object -ExpandProperty Layout -First 1)
				Write-Verbose "[$(Get-Date -Format s)] [$($MyInvocation.MyCommand.Name)] Detected keyboard layout: $layoutToResolve"
			}
			catch {
				Write-Verbose "[$(Get-Date -Format s)] [$($MyInvocation.MyCommand.Name)] Unable to detect keyboard layout from Win32_Keyboard. Returning fallback language code: $FallbackLanguageCode"
				if ($LowerCase) {
					return $FallbackLanguageCode.ToLowerInvariant()
				}
				return $FallbackLanguageCode
			}
		}

		$normalizedLayout = ($layoutToResolve -replace '^0x', '').Trim()

		if ([string]::IsNullOrWhiteSpace($normalizedLayout) -or $normalizedLayout.Length -lt 4 -or $normalizedLayout -notmatch '^[0-9a-fA-F]+$') {
			Write-Verbose "[$(Get-Date -Format s)] [$($MyInvocation.MyCommand.Name)] Keyboard layout '$layoutToResolve' is not a valid hex layout. Returning fallback language code: $FallbackLanguageCode"
			if ($LowerCase) {
				return $FallbackLanguageCode.ToLowerInvariant()
			}
			return $FallbackLanguageCode
		}

		$languageIdHex = $normalizedLayout.Substring($normalizedLayout.Length - 4)

		try {
			$languageId = [Convert]::ToInt32($languageIdHex, 16)
			$cultureName = [System.Globalization.CultureInfo]::GetCultureInfo($languageId).Name

			if ([string]::IsNullOrWhiteSpace($cultureName)) {
				throw "No culture name resolved for LCID $languageIdHex"
			}

			if ($LowerCase) {
				return $cultureName.ToLowerInvariant()
			}

			return $cultureName
		}
		catch {
			Write-Verbose "[$(Get-Date -Format s)] [$($MyInvocation.MyCommand.Name)] Unable to convert keyboard layout '$layoutToResolve' (LCID: $languageIdHex). Returning fallback language code: $FallbackLanguageCode"
			if ($LowerCase) {
				return $FallbackLanguageCode.ToLowerInvariant()
			}
			return $FallbackLanguageCode
		}
	}
}
