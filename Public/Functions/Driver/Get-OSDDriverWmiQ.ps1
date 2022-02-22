<#
.SYNOPSIS
Returns a Computer Model WMI Query that can be used in Task Sequences

.DESCRIPTION
Returns a Computer Model WMI Query that can be used in Task Sequences

.LINK
https://osd.osdeploy.com/module/functions/driver/get-osddriverwmiq

.NOTES
19.12.6     David Segura @SeguraOSD
#>
function Get-OSDDriverWmiQ {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]$InputObject,

        #Select a Computer Manufacturer OSDGroup
        #Default is DellModel
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet ('DellModel','HpModel')]
        [string]$OSDGroup,

        #Select whether the Query is based off Model or SystemId SystemSku Product
        #Default is Model
        [ValidateSet ('Model','SystemId')]
        [string]$Result = 'Model',

        #Open a Text File with the WMI Query after completion
        [System.Management.Automation.SwitchParameter]$ShowTextFile
    )

    begin {
        #=================================================
        #	Information
        #=================================================
        Write-Verbose 'Get-OSDDriverWmiQ: Results are saved in the Global Variable $GetOSDDriverWmiQ for this PowerShell session'
        $OSDComputerModels = @()
        $OSDModelPacks = @()
    }

    process {
        if ($InputObject) {
            $OSDModelPacks += $InputObject
            $OSDComputerModels = foreach ($ModelPack in $OSDModelPacks) {
                foreach ($item in $ModelPack.Model) {
                    $ObjectProperties = @{
                        Model = $item
                    }
                    New-Object -TypeName PSObject -Property $ObjectProperties
                }
            }
        } else {
            $OSDModelPacks = @()
            $OSDModelPacks = Get-OSDDriver $OSDGroup | Sort-Object Model -Unique
            $OSDModelPacks = $OSDModelPacks | Select-Object Make, Model, Generation, SystemSku | Out-GridView -PassThru -Title 'Select Computer Models to Generate a WMI Query'
        }
    }

    end {
        $Items = @()
        #=================================================
        #   Model
        #=================================================
        if ($Result -eq 'Model') {
            foreach ($Item in $OSDModelPacks.Model) {$Items += $Item}
            $Items = $Items | Sort-Object -Unique
            $WmiQueryFullName = Join-Path -Path $env:TEMP -ChildPath "WmiQuery.txt"
            $WmiCodeString = [System.Text.StringBuilder]::new()
            [void]$WmiCodeString.AppendLine('SELECT Model FROM Win32_ComputerSystem WHERE')

            foreach ($Item in $Items) {
                [void]$WmiCodeString.AppendLine("Model = '$($Item)'")
    
                if ($Item -eq $Items[-1]){
                    #"last item in array is $Item"
                } else {
                    [void]$WmiCodeString.Append('OR ')
                }
            }
            $WmiCodeString.ToString() | Out-File -FilePath $WmiQueryFullName -Encoding UTF8 -Width 2000 -Force
            if ($ShowTextFile.IsPresent) {
                notepad.exe $WmiQueryFullName
            }
            $global:GetOSDDriverWmiQ = $WmiCodeString.ToString()
            Return $global:GetOSDDriverWmiQ
        }
        #=================================================
        #   Dell SystemId
        #=================================================
        if ($Result -eq 'SystemId' -and $OSDGroup -eq 'DellModel') {
            foreach ($Item in $OSDModelPacks.SystemSku) {$Items += $Item}
            $Items = $Items | Sort-Object -Unique
            $WmiQueryFullName = Join-Path -Path $env:TEMP -ChildPath "WmiQuery.txt"
            $WmiCodeString = [System.Text.StringBuilder]::new()
            [void]$WmiCodeString.AppendLine('SELECT SystemSku FROM Win32_ComputerSystem WHERE')
        
            foreach ($Item in $Items) {
                [void]$WmiCodeString.AppendLine("SystemSku = '$($Item)'")
    
                if ($Item -eq $Items[-1]){
                    #"last item in array is $Item"
                } else {
                    [void]$WmiCodeString.Append('OR ')
                }
            }
            $WmiCodeString.ToString() | Out-File -FilePath $WmiQueryFullName -Encoding UTF8 -Width 2000 -Force
            if ($ShowTextFile.IsPresent) {
                notepad.exe $WmiQueryFullName
            }
            Return $WmiCodeString.ToString()
        }
        #=================================================
        #   HP SystemId
        #=================================================
        if ($Result -eq 'SystemId' -and $OSDGroup -eq 'HpModel') {
            foreach ($Item in $OSDModelPacks.SystemSku) {$Items += $Item}

            $Items = $Items | Sort-Object -Unique
            $WmiQueryFullName = Join-Path -Path $env:TEMP -ChildPath "WmiQuery.txt"
            $WmiCodeString = [System.Text.StringBuilder]::new()
            [void]$WmiCodeString.AppendLine('SELECT Product FROM Win32_BaseBoard WHERE')
            foreach ($Item in $Items) {
                [void]$WmiCodeString.AppendLine("Product = '$($Item)'")
    
                if ($Item -eq $Items[-1]){
                    #"last item in array is $Item"
                } else {
                    [void]$WmiCodeString.Append('OR ')
                }
            }
            $WmiCodeString.ToString() | Out-File -FilePath $WmiQueryFullName -Encoding UTF8 -Width 2000 -Force
            if ($ShowTextFile.IsPresent) {
                notepad.exe $WmiQueryFullName
            }
            $global:GetOSDDriverWmiQ = $WmiCodeString.ToString()
            Return $global:GetOSDDriverWmiQ
        }
    }
}