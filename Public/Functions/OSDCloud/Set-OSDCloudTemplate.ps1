function Set-OSDCloudTemplate {
    <#
    .SYNOPSIS
    Changes the path to the OSDCloud Template to $env:ProgramData\OSDCloud

    .DESCRIPTION
    Changes the path to the OSDCloud Template to $env:ProgramData\OSDCloud

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [System.String]
        #Name of the OSDCloud Template
        $Name = 'default'
    )
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-WinPE
    #=================================================
    #	Set Template Path
    #=================================================
    if ($Name -ne 'default') {
        $OSDCloudTemplate = "$env:ProgramData\OSDCloud\Templates\$Name"

        if (-NOT (Test-Path "$OSDCloudTemplate\Media\sources\boot.wim")) {
            $Name = 'default'
        }
    }

    if ($Name -eq 'default') {
        $OSDCloudTemplate = "$env:ProgramData\OSDCloud"
        if (Test-Path "$env:ProgramData\OSDCloud\template.json") {
            $null = Remove-Item -Path "$env:ProgramData\OSDCloud\template.json" -Force
        }
    }
    else {
        $TemplateSettings = [PSCustomObject]@{
            TemplatePath = $OSDCloudTemplate
        }
    
        $TemplateSettings | ConvertTo-Json | Out-File "$env:ProgramData\OSDCloud\template.json" -Encoding ascii -Width 2000 -Force
    }

    $OSDCloudTemplate

<#     if ((Test-Path "$env:ProgramData\OSDCloud\Config") -or (Test-Path "$env:ProgramData\OSDCloud\Logs") -or (Test-Path "$env:ProgramData\OSDCloud\Media")) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Migrating existing OSDCloud Template to $OSDCloudTemplate"
        $null = robocopy "$env:ProgramData\OSDCloud\Config" "$OSDCloudTemplate\Config" *.* /move /e /np /njh /njs /r:0 /w:0
        $null = robocopy "$env:ProgramData\OSDCloud\Autopilot\Profiles" "$OSDCloudTemplate\Config\AutopilotJSON" *.* /move /e /np /njh /njs /r:0 /w:0
        $null = robocopy "$env:ProgramData\OSDCloud\Logs" "$OSDCloudTemplate\Logs" *.* /move /e /np /njh /njs /r:0 /w:0
        $null = robocopy "$env:ProgramData\OSDCloud\Media" "$OSDCloudTemplate\Media" *.* /move /e /np /njh /njs /r:0 /w:0
        $null = robocopy "$env:ProgramData\OSDCloud" "$OSDCloudTemplate" winpe.json /move /np /njh /njs /r:0 /w:0
        $null = robocopy "$env:ProgramData\OSDCloud" "$OSDCloudTemplate" *.iso /move /np /njh /njs /r:0 /w:0
    } #>
}
Register-ArgumentCompleter -CommandName Set-OSDCloudTemplate -ParameterName Name -ScriptBlock {Get-OSDCloudTemplateNames}