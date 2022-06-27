function get-azOSDTechId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AzureAdUserName
    )
    begin {
        Connect-AzAccount -UseDeviceAuthentication
    }
    
    process {
       $AzOSDUser = Get-AzADUser -StartsWith $AzureAdUserName 
    }
    
    end {
        
        return $azOSDUser
    }
}