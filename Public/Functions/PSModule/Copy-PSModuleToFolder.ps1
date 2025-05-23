function Copy-PSModuleToFolder {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [SupportsWildcards()]
        [String[]]$Name,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Folder')]
        [String]$Destination,

        [System.Management.Automation.SwitchParameter]$RemoveOldVersions
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
                $sourceModuleBase = $Module.ModuleBase
                $exclude = @(".git")
                Write-Verbose "Copying $sourceModuleBase to $DestinationModuleVersion"

                if (-not (Test-Path $DestinationModuleVersion)) {
                    New-Item -Path $DestinationModuleVersion -ItemType Directory -Force | Out-Null
                }

                #Copy-Item -Path "$sourceModuleBase\*" -Destination $DestinationModuleVersion -Exclude $exclude -Recurse -Force -ErrorAction Stop
                Copy-Item -Path (Get-Item -Path "$sourceModuleBase\*" -Exclude $exclude).FullName -Destination $DestinationModuleVersion -Recurse -Force


                Get-Module -ListAvailable -FullyQualifiedName $DestinationModuleVersion
            }
        }
    }
    end {}
}
