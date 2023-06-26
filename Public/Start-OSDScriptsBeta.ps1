function Start-OSDScriptsBeta {
    [CmdletBinding()]
    param ()
    #================================================
    #   Set Global Variables
    #================================================
    $Global:OSDPadBranding = @{
        Title = 'OSDScripts'
        Color = '#01786A'
    }
    #=================================================
    #   Parameters
    #=================================================
    $Path = "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDScripts\Scripts"
    $ScriptFiles = Get-ChildItem -Path $Path -Recurse -File
    $ScriptFiles = $ScriptFiles | Where-Object {($_.Name -match '.ps1') -or ($_.Name -match '.md') -or ($_.Name -match '.json')}
    #=================================================
    #   Create Object
    #=================================================
    $Global:OSDScripts = foreach ($Item in $ScriptFiles) {
        $FullName = $Item.FullName
        $DirectoryName = $Item.DirectoryName
        $RelativePath = $Item.FullName -replace [regex]::Escape("$Path\"), ''

        if ($DirectoryName -eq $Path) {
            $Category = ''
            $Script = $RelativePath
        }
        else {
            $Category = $Item.DirectoryName -replace [regex]::Escape("$Path\"), ''
            $Script = $RelativePath 
        }

        # Category is the first part of the path
        # $Category = $RelativePath.Split('\')[0]
        # $Category = $RelativePath.Split('\')[0..1] -join '\'

        $ObjectProperties = [ordered]@{
            Category = $Category
            Script = $Script
            Content = Get-Content -Path $Item.FullName -Raw
            DirectoryName = $DirectoryName
            RelativePath = $RelativePath
            Name = $Item.Name
            FullName = $FullName
        }
        New-Object -TypeName PSObject -Property $ObjectProperties
    }
    #=================================================
    #   OSDScripts.ps1
    #=================================================
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDScripts\MainWindow.ps1"
    #=================================================
}