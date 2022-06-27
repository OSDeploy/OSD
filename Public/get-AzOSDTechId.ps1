function get-azOSDTechId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AzureAdUserName
    )
    begin {
        Connect-AzAccount -UseDeviceAuthentication  -ErrorAction Stop 
    
        $Global:AzSubscription = Get-AzSubscription
    
        if (($Global:AzSubscription).Count -ge 2) {
            $i = $null
            $Results = foreach ($Item in $Global:AzSubscription) {
                $i++
        
                $ObjectProperties = @{
                    Number  = $i
                    Name    = $Item.Name
                    Id      = $Item.Id
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
        
            $Results | Select-Object -Property Number, Name, Id | Format-Table | Out-Host
        
            do {
                $SelectReadHost = Read-Host -Prompt "Select an Azure Subscription by Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Results.Number))))
        
            $Results = $Results | Where-Object {$_.Number -eq $SelectReadHost}
        
            $Global:AzContext = Set-AzContext -Subscription $Results.Id
        }
        else {
            $Global:AzContext = Get-AzContext
        }
        }
    }
    
    process {
       $AzOSDUser = Get-AzADUser -StartsWith $AzureAdUserName | select-object -Property DisplayName,Id
    }
    
    end {
        
        return $azOSDUser
    }
}