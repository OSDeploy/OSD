# OSD Comment-Based Help Authoring Skill

Purpose: standardize comment-based help across OSD PowerShell functions so help output is complete, consistent, and ready for documentation workflows.

## Required Help Sections

Use comment-based help inside each function block as the first statement after the opening `{` and include sections in this order:

1. `.SYNOPSIS`
2. `.DESCRIPTION`
3. `.PARAMETER <Name>` for every exposed parameter
4. `.EXAMPLE` (at least one practical example)
5. `.LINK`
6. `.NOTES`

Optional sections when relevant:

- `.OUTPUTS`
- `.INPUTS`
- Additional `.EXAMPLE` blocks

## Placement Rule

- Comment-based help must be inside the function block, not outside the function definition.
- Place the help block immediately after `function Verb-Noun {` and before `[CmdletBinding()]` or `param(...)`.

## Required NOTES Content

Every function help block must include the following in `.NOTES`:

- `Author: David Segura - Recast Software`
changelog with one or more entries in this exact format:
- `YYYY-MM-DD - short note`

Example NOTES section:

```powershell
.NOTES
Author: David Segura - Recast Software
2026-07-09 - Initial help block created
```

## LINK Policy

The first `.LINK` entry must always be:

`https://github.com/OSDeploy/OSD/tree/master/Docs`

Additional `.LINK` entries are allowed after the required first entry.

Example:

```powershell
.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.LINK
https://example.vendor.com/reference
```

## Canonical Template

```powershell
function Verb-Noun {
    <#
    .SYNOPSIS
    One-line summary of what the function does.

    .DESCRIPTION
    Clear, behavior-focused description of what the function does and when to use it.

    .PARAMETER Name
    Explain what this parameter controls.

    .EXAMPLE
    Verb-Noun -Name Value
    Explain what this example does and expected outcome.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Initial help block created

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    # Function implementation
}
```

## Writing Rules

- Keep `.SYNOPSIS` concise and action-oriented.
- Use `.DESCRIPTION` for behavior, constraints, and side effects.
- Ensure each `.PARAMETER` entry matches the real parameter name exactly.
- Ensure each `.EXAMPLE` is executable and reflects real usage.
- Keep changelog entries short and factual.

## Validation Checklist

Before submitting changes, verify all items are true:

1. Help block exists inside the function block and is the first statement after the opening `{`.
2. Required sections are present and in the defined order.
3. Every exposed parameter has a matching `.PARAMETER` entry.
4. The first `.LINK` is exactly `https://github.com/OSDeploy/OSD/tree/master/Docs`.
5. Any additional links are placed after the required docs link.
6. `.NOTES` contains:
   - `Author: David Segura - Recast Software`
   - `YYYY-MM-DD - short note` changelog entries
7. Examples are accurate for both Windows PowerShell 5.1 and PowerShell 7 usage where applicable.
8. Help text reflects current behavior and parameter defaults.

## Pass/Fail Examples

Pass:

- Includes required NOTES lines and dated changelog entries.
- First link points to OSD Docs URL.
- Parameter documentation fully matches function signature.

Fail:

- Missing changelog or invalid date format.
- Compatibility line missing or different wording.
- First link is not the required OSD Docs URL.
- Parameter exists in `param()` but missing from `.PARAMETER` section.
