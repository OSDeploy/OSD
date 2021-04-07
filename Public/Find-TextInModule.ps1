<#
.SYNOPSIS
Simple function that searches for Text in a PowerShell Module

.DESCRIPTION
Simple function that searches for Text in a PowerShell Module.  Files selected in Out-GridView can be opened in VSCode

.PARAMETER Text
String to find

.PARAMETER Module
Module to search in.  OSD is the default

.PARAMETER Include
Files to include in the search.  *.* is the default

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Find-TextInModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Text,
        [string]$Module = 'OSD',
		[string[]]$Include = '*.*'
	)
    #=======================================================================
    #	Get-Module Path
    #=======================================================================
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