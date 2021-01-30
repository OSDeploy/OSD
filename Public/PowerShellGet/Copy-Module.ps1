<#
.SYNOPSIS
Get-Module and copy the ModuleBase to a new Destination\ModuleBase

.DESCRIPTION
Get-Module and copy the ModuleBase to a new Destination\ModuleBase

.LINK
https://osd.osdeploy.com/module/functions/powershellget/copy-module

.NOTES
21.1.30.1   Initial Release
21.1.30.2   Added WinPE Parameter
21.1.30.3   Renamed PSModulePath Parameter to Destination, Added RemoveOldVersions
#>
function Copy-Module {
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
        [switch]$RemoveOldVersions=$false,

        #Removes destination Version from copied directories
        #for compatibility with WinPE
        [switch]$WinPE=$false
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

                #If WinPE or RemoveOldVersions
                if (($WinPE -eq $true) -or ($RemoveOldVersions -eq $true)) {
                    if (Test-Path $DestinationModule) {
                        Write-Warning "Destination Module exists at '$DestinationModule'.  Content will be replaced"
                        Write-Warning "Removing $DestinationModule"
                        Remove-Item -Path $DestinationModule -Recurse -Force -ErrorAction Stop
                    }
                }

                if ($WinPE -eq $false) {
                    #Destination is in the WinPE Format
                    if (Test-Path "$DestinationModule\*.psd1") {
                        Write-Warning "Destination Module contains a Manifest in '$DestinationModule'.  Content will be replaced"
                        Write-Warning "Removing $DestinationModule"
                        Remove-Item -Path $DestinationModule -Recurse -Force -ErrorAction Stop
                    }
                    
                    #Destination is set to the Windows Format with Version in the Destination
                    $DestinationModule = Join-Path -Path $DestinationModule -ChildPath $Module.Version
                    if (Test-Path $DestinationModule) {
                        Write-Warning "Destination Module exists at '$DestinationModule'.  Content will be replaced"
                        Write-Warning "Removing $DestinationModule"
                        Remove-Item -Path $DestinationModule -Recurse -Force -ErrorAction Stop
                    }
                }

                #Copy to the Destination
                Write-Verbose "Copying '$($Module.ModuleBase)' to $DestinationModule"
                Copy-Item -Path $Module.ModuleBase -Destination $DestinationModule -Recurse -Force -ErrorAction Stop
                Get-Module -ListAvailable -FullyQualifiedName $DestinationModule
            }
        }
    }
    end {}
}