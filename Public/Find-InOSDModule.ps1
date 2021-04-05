function Find-InOSDModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Text,
		[string[]]$Include = '*.*'
	)
	
    $Results = Get-ChildItem $MyInvocation.MyCommand.Module.ModuleBase -Recurse -Include $Include -File | Select-String $Text | Select-Object Path, Filename, LineNumber, Line | Out-Gridview -Title 'Results' -PassThru

    if (Get-Command 'code' -ErrorAction SilentlyContinue) {
        foreach ($Item in $Results) {
            code $($Item.Path)
        }
    }
}