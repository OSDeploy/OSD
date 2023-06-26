#Requires -RunAsAdministrator
<#
.DESCRIPTION
The search command of the winget tool can be used to show all applications available for installation.
It can also be used to identify the string or ID needed to install a specific application.
For example, the command winget search vscode will return all applications available that include "vscode" in the description or tag.
The search command includes parameters for filtering down the applications returned to help you identify the specific application you are looking for, including: --id, --name, --moniker, --tag, --command, or --source.
See descriptions below or use winget search --help in your command line.

.LINK
https://learn.microsoft.com/en-us/windows/package-manager/winget/search

.NOTES
Usage
winget search [[-q] \<query>] [\<options>]

Arguments
-q,--query                  The query flag is the default argument used to search for an app. It does not need to be specified. Entering the command winget search foo will default to using --query so including it is unnecessary.
-?, --help                  Gets additional help on this command.

Options
--id                        Limits the search to the ID of the application. The ID includes the publisher and the application name.
--name                      Limits the search to the name of the application.
--moniker                   Limits the search to the moniker specified.
--tag                       Limits the search to the tags listed for the application.
--command                   Limits the search to the commands listed for the application.
--verbose-logs              Used to override the logging setting and create a verbose log.
-e, --exact                 Uses the exact string in the query, including checking for case-sensitivity. It will not use the default behavior of a substring.
-n, --count                 Show no more than specified number of results (between 1 and 1000).
-s, --source                Find package using the specified source name.
--header                    Optional Windows-Package-Manager REST source HTTP header.
--accept-source-agreements  Accept all source license agreements and avoid the prompt.
#>
[CmdletBinding()]
param()

if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
    # To show all of the winget packages available, use the command:
    # winget search --query ""
    #In PowerShell, you will need to escape the quotes, so this command becomes:
    winget search -q `"`"
}