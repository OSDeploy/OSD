function Test-IsVM {
<#
.SYNOPSIS
Tests IsVM conditions.

.DESCRIPTION
Evaluates IsVM state and returns a validation result for scripting decisions.

.EXAMPLE
Test-IsVM
Demonstrates a common way to run Test-IsVM.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
        [CmdletBinding()]
        param ()
        
    $Result = ((Get-CimInstance -ClassName CIM_ComputerSystem).Model).Trim()
    
    ($Result -match 'Virtual') -or ($Result -match 'VMware')
}
