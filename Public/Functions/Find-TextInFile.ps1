function Find-TextInFile {
	<#
	.SYNOPSIS
	Searches files for matching text and displays selectable results.

	.DESCRIPTION
	Recursively searches files under a path using Select-String, displays matching lines in Out-GridView, and opens selected files in Visual Studio Code when available.

	.PARAMETER Path
	Root path to search recursively.

	.PARAMETER Text
	Text pattern to search for.

	.PARAMETER Include
	File include pattern(s) used by Get-ChildItem during the recursive search.

	.EXAMPLE
	Find-TextInFile -Path C:\Logs -Text Error -Include *.log
	Searches all .log files in C:\Logs for Error and shows the matches.

	.LINK
	https://github.com/OSDeploy/OSD/tree/master/Docs

	.NOTES
	Author: David Segura - Recast Software
	2026-07-11 - Added comment-based help
	#>
    [CmdletBinding()]
    param (
		[Parameter(Mandatory = $true)]
		[string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Text,
		[string[]]$Include = '*.txt'
	)
    #=================================================
	$Results = Get-ChildItem $Path -Recurse -Include $Include -File | `
	Select-String $Text | `
	Select-Object Path, Filename, LineNumber, Line | `
	Out-Gridview -Title 'Results' -PassThru

	if (Get-Command 'code' -ErrorAction SilentlyContinue) {
	foreach ($Item in $Results) {
	code $($Item.Path)
		}
	}
    #=================================================
}
