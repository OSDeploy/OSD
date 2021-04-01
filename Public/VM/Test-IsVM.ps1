function Test-IsVM {
        [CmdletBinding()]
        param ()
        
    $Result = ((Get-CimInstance -ClassName CIM_ComputerSystem).Model).Trim()
    
    ($Result -match 'Virtual') -or ($Result -match 'VMware')
}