function ConvertTo-TrimmedString {
    <#
    .SYNOPSIS
    Converts input to a trimmed string.

    .DESCRIPTION
    Accepts pipeline or direct input, converts non-null values to string, and
    returns the value with leading and trailing whitespace removed. Null input
    is returned as null.

    .PARAMETER Value
    Value to convert to string and trim.

    .EXAMPLE
    ConvertTo-TrimmedString -Value '  hello  '
    Returns 'hello'.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Moved help block inside function and normalized required sections
    #>
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
