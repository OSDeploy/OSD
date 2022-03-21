function Get-OSDCloudTemplateNames {
    <#
    .SYNOPSIS
    Returns valid OSDCloud Template Names

    .DESCRIPTION
    Returns valid OSDCloud Template Names

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
    $Results = @()
    [System.Array]$Results = 'default'
    [System.Array]$Results += Get-ChildItem -Path "$env:ProgramData\OSDCloud\Templates" | Where-Object {$_.PsIsContainer -eq $true} | Select-Object -ExpandProperty Name
    [System.Array]$Results
}