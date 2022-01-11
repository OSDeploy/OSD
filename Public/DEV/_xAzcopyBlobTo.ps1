function Copy-AzcopyBlobToOs
{
    [CmdletBinding()]
    param ()

    if (Get-Command -Name 'azcopy.exe')
    {
        azcopy login
    }
    else
    {
        Write-Warning 'Copy-AzcopyBlobToOs requires azcopy.exe'
    }
}
function Copy-AzcopyBlobToWinpe
{
    [CmdletBinding()]
    param ()

    if (Get-Command -Name 'azcopy.exe')
    {
        azcopy login

    }
    else
    {
        Write-Warning 'Copy-AzcopyBlobToOs requires azcopy.exe'
    }
}