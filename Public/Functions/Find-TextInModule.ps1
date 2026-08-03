function Find-TextInModule {
    <#
    .SYNOPSIS
    Searches module files for matching text.

    .DESCRIPTION
    Resolves the latest installed version of a module, searches its files for matching text, shows results in Out-GridView, and opens selected files in Visual Studio Code when available.

    .PARAMETER Text
    Text pattern to search for in module files.

    .PARAMETER Module
    Module name to search. The latest installed version is selected.

    .PARAMETER Include
    File include pattern(s) used by Get-ChildItem during the recursive search.

    .EXAMPLE
    Find-TextInModule -Text Save-WebFile -Module OSD -Include *.ps1
    Searches PowerShell files in the latest installed OSD module for Save-WebFile.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Text,
        [string]$Module = 'OSD',
		[string[]]$Include = '*.*'
	)
    #=================================================
    #	Get-Module Path
    #=================================================
    $GetModule = @()
    $GetModule = Get-Module -ListAvailable -Name $Module | Select-Object Name, Version, ModuleBase
    $GetModule = $GetModule | Sort-Object Name, Version -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}

    if ($null -eq $GetModule) {
        Write-Warning "Unable to find Module in Get-Module -ListAvailable -Name '$Module'"
    }
    else {
        Write-Verbose "Module Name: $($GetModule.Name)"
        Write-Verbose "Module Version: $($GetModule.Version)"
        Write-Verbose "Module ModuleBase: $($GetModule.ModuleBase)"

        $Results = Get-ChildItem $GetModule.ModuleBase -Recurse -Include $Include -File | Select-String $Text | Select-Object Path, Filename, LineNumber, Line | Out-Gridview -Title 'Results' -PassThru

        if (Get-Command 'code' -ErrorAction SilentlyContinue) {
            foreach ($Item in $Results) {
                code $($Item.Path)
            }
        }
    }
}
