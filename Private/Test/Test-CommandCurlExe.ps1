function Test-CommandCurlExe {
    [CmdletBinding()]
    param ()
    
    if (Get-Command 'curl.exe' -ErrorAction SilentlyContinue) {
        Return $true
    }
    else {
        Return $false
    }
}