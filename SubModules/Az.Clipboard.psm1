function Get-AzClipboard {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the secret to get
        $Name = 'Clipboard'
    )

    $GetAzKeyVaultSecret = $null
    #=================================================
    #	FromAzKeyVaultSecret
    #=================================================
    $Module = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
    if (-not $Module) {
        Install-Module Az.KeyVault -Force
    }

    $Module = Import-Module Az.Accounts -PassThru -ErrorAction Ignore
    if (-not $Module) {
        Install-Module Az.Accounts -Force
    }
    
    if (-not (Get-AzContext -ErrorAction Ignore)) {
        if ($env:SystemDrive -eq 'X:') {
            $null = Connect-AzAccount -DeviceCode
        }
        else {
            $null = Connect-AzAccount
        }
    }

    if (Get-AzContext -ErrorAction Ignore) {

        $Global:AzClipBoardKeyVault = Get-AzKeyVault -ErrorAction Ignore -WarningAction Ignore | Sort-Object Name | Where-Object {$_.Tags.ContainsKey('AzClipboard')} | Select-Object -First 1

        if ($Global:AzClipBoardKeyVault) {
            $Result = $Global:AzClipBoardKeyVault | Get-AzKeyVaultSecret -Name $Name -AsPlainText -ErrorAction Ignore
            if ($Result) {
                Return $Result
            }
        }
    }
    else {
        Write-Warning "Authenticate to Azure using Connect-AzAccount first"
        Break
    }
}
function Set-AzClipboard {
    [CmdletBinding()]
    param (      
        [Parameter(Position = 0)]
        # Specifies the name of the Key Vault Secret to set
        [System.String]
        $Name = 'Clipboard'
    )
    $RawString = $null
    #=================================================
    #	Import Az Modules
    #=================================================
    $Module = Import-Module Az.Accounts -PassThru -ErrorAction Ignore
    if (-not $Module) {
        Install-Module Az.Accounts -Force
    }
    
    $Module = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
    if (-not $Module) {
        Install-Module Az.KeyVault -Force
    }
    
    if (-not (Get-AzContext -ErrorAction Ignore)) {
        if ($env:SystemDrive -eq 'X:') {
            $null = Connect-AzAccount -DeviceCode
        }
        else {
            $null = Connect-AzAccount
        }
    }

    if (Get-AzContext -ErrorAction Ignore) {

        $Global:AzClipBoardKeyVault = Get-AzKeyVault -ErrorAction Ignore -WarningAction Ignore | Sort-Object Name | Where-Object {$_.Tags.ContainsKey('AzClipboard')} | Select-Object -First 1

        if ($Global:AzClipBoardKeyVault) {
            if (Get-Clipboard -ErrorAction Ignore) {
                try {
                    $RawString = Get-Clipboard -Format Text -Raw
                }
                catch {
                    Write-Warning $_
                }
            }
            if ($RawString) {
                try {
                    $SecretValue = ConvertTo-SecureString -String $RawString -AsPlainText -Force
                    Set-AzKeyVaultSecret -VaultName $Global:AzClipBoardKeyVault.VaultName -Name $Name -SecretValue $SecretValue -ContentType 'text/plain'
                }
                catch {
                    Write-Warning $_
                }
            }
        }
    }
}