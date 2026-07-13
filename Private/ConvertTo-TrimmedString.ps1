<#
.SYNOPSIS
Converts input to a trimmed string.

.DESCRIPTION
Accepts a value from the pipeline or parameter input, converts it to a string,
and returns the string with leading and trailing whitespace removed.
If the input value is `$null`, the function returns `$null`.

.PARAMETER Value
The value to convert to a string and trim.

.INPUTS
System.Object

.OUTPUTS
System.String
System.Object

.EXAMPLE
ConvertTo-TrimmedString -Value '  hello  '

Returns `hello`.

.EXAMPLE
'  world  ' | ConvertTo-TrimmedString

Returns `world`.

.EXAMPLE
$null | ConvertTo-TrimmedString

Returns `$null`.
#>
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
