function Set-OSDPreferences {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript( { if (Test-Path -Path $_ -PathType 'Leaf') { $true } else { throw "Cannot find file $_" } })]
        [System.String] $Path = (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "Preferences.json")
    )

    try {
        Write-Verbose -Message "$($MyInvocation.MyCommand): read module resource strings from [$Path]"
        $params = @{
            Path        = $Path
            Raw         = $True
            ErrorAction = "Stop"
        }
        $content = Get-Content @params
    }
    catch {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read from: $Path."
        Throw $_.Exception.Message
    }

    try {
        $script:resourceStringsTable = $content | ConvertFrom-Json -ErrorAction "Stop" | ConvertTo-Hashtable
    }
    catch {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert strings to required object."
        Throw $_.Exception.Message
    }
    finally {
        If ($Null -ne $script:resourceStringsTable) {
            Write-Output -InputObject $script:resourceStringsTable
        }
    }
}