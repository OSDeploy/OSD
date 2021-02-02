<#
.SYNOPSIS
Get-Module and copy the ModuleBase to a new Destination\ModuleBase

.DESCRIPTION
Get-Module and copy the ModuleBase to a new Destination\ModuleBase

.LINK
https://osd.osdeploy.com/module/functions/powershellget/copy-moduleosd

.NOTES
21.1.30.1   Initial Release
21.1.30.2   Added WinPE Parameter
21.1.30.3   Renamed PSModulePath Parameter to Destination, Added RemoveOldVersions
21.1.31.1   Removed WinPE Parameter
21.2.2.1	Renamed to Copy-ModuleOSD so I don't mess with PowerShellGet
#>
function Copy-ModuleOSD {
    [CmdletBinding()]
    Param (
        #Name of the PowerShell Module to Copy
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [SupportsWildcards()]
        [String[]]$Name,

        #Destination PSModule directory
        #Copied Module is a Child of Destination
        [Parameter(
            Position=1,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [String]$Destination,

        #Removes older Module Versions from the Destination
        [switch]$RemoveOldVersions=$false
    )

    begin {
        Write-Verbose "Destination: $Destination"
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
                $DestinationModule = Join-Path -Path $Destination -ChildPath $Module.Name

                #If RemoveOldVersions
                if ($RemoveOldVersions -eq $true) {
                    if (Test-Path $DestinationModule) {
                        Write-Warning "Removing $DestinationModule"
                        Remove-Item -Path $DestinationModule -Recurse -Force -ErrorAction Stop
                    }
                }

                #Remove Module if PSD1 is not in a Version subdirectory
                if (Test-Path "$DestinationModule\*.psd1") {
                    Write-Warning "Destination Module contains a Manifest in '$DestinationModule'.  Content will be replaced"
                    Write-Warning "Removing $DestinationModule"
                    Remove-Item -Path $DestinationModule -Recurse -Force -ErrorAction Stop
                }
                
                #Destination is set to the Windows Format with Version in the Destination
                $DestinationModuleVersion = Join-Path -Path $DestinationModule -ChildPath $Module.Version
                if (Test-Path $DestinationModuleVersion) {
                    Write-Warning "Destination Module exists at '$DestinationModuleVersion'.  Content will be replaced"
                    Write-Warning "Removing $DestinationModuleVersion"
                    Remove-Item -Path $DestinationModuleVersion -Recurse -Force -ErrorAction Stop
                }

                #Copy to the Destination
                Write-Verbose "Copying '$($Module.ModuleBase)' to $DestinationModuleVersion"
                Copy-Item -Path $Module.ModuleBase -Destination $DestinationModuleVersion -Recurse -Force -ErrorAction Stop
                Get-Module -ListAvailable -FullyQualifiedName $DestinationModuleVersion
            }
        }
    }
    end {}
}