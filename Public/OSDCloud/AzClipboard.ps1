function Get-AzClipboard {
    <#
    .SYNOPSIS
    Read a secret value from the Azure clipboard Key Vault.

    .DESCRIPTION
    Connects to Azure if needed, finds the first Key Vault tagged with AzClipboard, and returns
    the named secret as plain text.

    .PARAMETER Name
    The name of the Key Vault secret to read. The default secret name is Clipboard.

    .EXAMPLE
    Get-AzClipboard
    Returns the value stored in the default Clipboard secret.

    .EXAMPLE
    Get-AzClipboard -Name Clipboard
    Returns the value stored in the Clipboard secret explicitly.

    .OUTPUTS
    System.String

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .LINK
    https://github.com/OSDeploy/OSD/blob/master/Docs/Get-AzClipboard.md
    #>
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
    <#
    .SYNOPSIS
    Write the current clipboard text to the Azure clipboard Key Vault.

    .DESCRIPTION
    Connects to Azure if needed, finds the first Key Vault tagged with AzClipboard, and stores
    the current clipboard text in the named secret as plain text.

    .PARAMETER Name
    The name of the Key Vault secret to write. The default secret name is Clipboard.

    .EXAMPLE
    Set-AzClipboard
    Copies the current clipboard text into the default Clipboard secret.

    .EXAMPLE
    Set-AzClipboard -Name Clipboard
    Copies the current clipboard text into the Clipboard secret explicitly.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .LINK
    https://github.com/OSDeploy/OSD/blob/master/Docs/Set-AzClipboard.md
    #>
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
