function Write-DarkGrayDate {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.String]
        $Message
    )
    if ($Message) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $Message"
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] " -NoNewline
    }
}
function Write-DarkGrayHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Message
    )
    Write-Host -ForegroundColor DarkGray $Message
}
function Write-DarkGrayLine {
    [CmdletBinding()]
    param ()
    # Write-Host -ForegroundColor DarkGray '========================================================================='
}
function Write-SectionHeader {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Message
    )
    Write-DarkGrayLine
    # Write-DarkGrayDate
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] $Message"
}
function Write-SectionSuccess {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.String]
        $Message = 'Success!'
    )
    Write-DarkGrayDate
    Write-Host -ForegroundColor Green $Message
}

function ConvertTo-TrimmedString {
    param(
        [Parameter(ValueFromPipeline = $true)]
        $Value
    )

    process {
        if ($null -eq $Value) {
            return $null
        }
        return $Value.ToString().Trim()
    }
}
