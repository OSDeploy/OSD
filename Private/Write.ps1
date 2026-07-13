function Write-DarkGrayDate {
    <#
    .SYNOPSIS
    Writes a timestamped message in DarkGray.

    .DESCRIPTION
    Writes the current date and time in ISO-like sortable format. When Message is provided,
    the timestamp and message are written on one line. When Message is omitted, only the
    timestamp prefix is written and the cursor remains on the same line.

    .PARAMETER Message
    Optional text appended after the timestamp.

    .EXAMPLE
    Write-DarkGrayDate -Message 'Starting task'
    Writes a DarkGray line like [2026-07-12T10:15:30] Starting task.

    .EXAMPLE
    Write-DarkGrayDate
    Writes only the timestamp prefix in DarkGray without a trailing newline.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-12 - Added comment-based help
    #>
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
    <#
    .SYNOPSIS
    Writes a message in DarkGray.

    .DESCRIPTION
    Writes the provided message to the host using DarkGray foreground color.

    .PARAMETER Message
    The text to write to the host.

    .EXAMPLE
    Write-DarkGrayHost -Message 'Downloading content'
    Writes Downloading content in DarkGray.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-12 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Message
    )
    Write-Host -ForegroundColor DarkGray $Message
}
function Write-DarkGrayLine {
    <#
    .SYNOPSIS
    Provides a visual section separator.

    .DESCRIPTION
    Intended to write a separator line in DarkGray for section formatting. The current
    implementation is a no-op because the Write-Host statement is commented out.

    .EXAMPLE
    Write-DarkGrayLine
    Runs the separator helper. In the current implementation, no text is written.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-12 - Added comment-based help
    #>
    [CmdletBinding()]
    param ()
    # Write-Host -ForegroundColor DarkGray '========================================================================='
}
function Write-SectionHeader {
    <#
    .SYNOPSIS
    Writes a timestamped section header in DarkCyan.

    .DESCRIPTION
    Calls the section separator helper, then writes a DarkCyan timestamped header message
    to identify a major step in script output.

    .PARAMETER Message
    The section title to display.

    .EXAMPLE
    Write-SectionHeader -Message 'Initialize Deployment'
    Writes a timestamped section header in DarkCyan.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-12 - Added comment-based help
    #>
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
    <#
    .SYNOPSIS
    Writes a success status line.

    .DESCRIPTION
    Writes a DarkGray timestamp prefix and then writes the success message in Green.
    If Message is not provided, the default text Success! is used.

    .PARAMETER Message
    Success text to display. Defaults to Success!.

    .EXAMPLE
    Write-SectionSuccess
    Writes a timestamped green success line using the default message Success!.

    .EXAMPLE
    Write-SectionSuccess -Message 'Completed image customization'
    Writes a timestamped green success line with a custom message.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-12 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.String]
        $Message = 'Success!'
    )
    Write-DarkGrayDate
    Write-Host -ForegroundColor Green $Message
}
