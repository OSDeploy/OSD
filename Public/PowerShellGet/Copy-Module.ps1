<#
.SYNOPSIS
Get-Module and copy the ModuleBase to a new PSModulePath

.DESCRIPTION
Get-Module and copy the ModuleBase to a new PSModulePath

.LINK
https://osd.osdeploy.com/module/functions/powershellget/copy-module

.NOTES
21.1.30    Initial Release
#>function Copy-Module {
    [CmdletBinding()]
    Param (
        #Name of the Module to Copy
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [SupportsWildcards()]
        [String[]]$Name,

        #Destination PSModule root directory
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true
        )]
        [String]$PSModulePath
    )

    begin {
        Write-Verbose "PSModulePath: $PSModulePath"
    }
    process {
        foreach ($Item in $Name) {

            #GetModule
            $GetModule = @()
            $GetModule = Get-Module -ListAvailable -Name $Item | Select-Object Name, Version, ModuleBase
            $GetModule = $GetModule | Sort-Object Name, Version -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}

            if ($null -eq $GetModule) {
                Write-Warning "Unable to find Module in Get-Module -ListAvailable -Name '$Item'"
                Continue
            }
            
            foreach ($Module in $GetModule) {
                Write-Verbose "Module Name: $($Module.Name)"
                Write-Verbose "Module Version: $($Module.Version)"
                Write-Verbose "Module ModuleBase: $($Module.ModuleBase)"

                #Get the Path to the Destination Module
                $Destination = Join-Path -Path $PSModulePath -ChildPath $Module.Name

                if (Test-Path $Destination) {
                    Write-Warning "Destination exists at '$Destination'.  Content will be overwritten"
                    Write-Warning "Removing $Destination"
                    Remove-Item -Path $Destination -Recurse -Force -ErrorAction Stop
                } else {
                    Write-Verbose "CopyModuleBase: $Destination"
                }

                #Copy to the Destination
                Write-Verbose "Copying '$($Module.ModuleBase)' to $Destination"
                Copy-Item -Path $Module.ModuleBase -Destination $Destination -Recurse -Force -ErrorAction Stop
                Get-Module -ListAvailable -FullyQualifiedName $Destination
            }
        }
    }
    end {}
}