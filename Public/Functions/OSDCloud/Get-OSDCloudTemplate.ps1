function Get-OSDCloudTemplate {
    <#
    .SYNOPSIS
    Returns the path to the OSDCloud Template.  This is typically $env:ProgramData\OSDCloud\Templates\Default

    .DESCRIPTION
    Returns the path to the OSDCloud Template.  This is typically $env:ProgramData\OSDCloud\Templates\Default

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    param ()
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #   template.json
    #=================================================
    if (Test-Path "$env:ProgramData\OSDCloud\template.json") {
        $TemplateSettings = Get-Content -Path "$env:ProgramData\OSDCloud\template.json" | ConvertFrom-Json
        $OSDCloudTemplate = $TemplateSettings.TemplatePath

        if (! (Test-Path "$OSDCloudTemplate\Media\sources\boot.wim")) {
            $OSDCloudTemplate = "$env:ProgramData\OSDCloud"
            $null = Remove-Item -Path "$env:ProgramData\OSDCloud\template.json" -Force
        }
    }
    else {
        $OSDCloudTemplate = "$env:ProgramData\OSDCloud"
    }
    #=================================================
    #   Template is not complete
    #=================================================
    if (! (Test-Path "$OSDCloudTemplate\Media\sources\boot.wim")) {
        Return $null
    }
    #=================================================
    #   Return Template Path
    #=================================================
    if (Test-Path "$env:ProgramData\OSDCloud\template.json") {
        $TemplateSettings = Get-Content -Path "$env:ProgramData\OSDCloud\template.json" | ConvertFrom-Json
        $OSDCloudTemplate = $TemplateSettings.TemplatePath
        
    }
    Return $OSDCloudTemplate
}