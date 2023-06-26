#requires -version 3

<#
    Regrecent in PowerShell - find registry keys modified in a given time window

    Guy Leech, 2018

    Modification History

    20/12/2017   GRL  Added -sinceBoot parameter

    12/02/2018   GRL  Added grid view output and date format options. Convert non-PowerShell registry provider paths. Added support for HKEY_CLASSES_ROOT
#>

<#
.SYNOPSIS

Show registry keys last modified within a given time/date range

.DESCRIPTION

Registry keys, but not values, contain timestamps recording when they were last modified, e.g. when a registry value in that key was changed.
This script will find keys changed in a given time range to aid troubleshooting of problems which may be related to changed registry settings, e.g. my machine started crashing yesterday so let
us see what registry keys have been changed since yesterday.

.PARAMETER key

The starting key/path to use.

.PARAMETER last

Show changed keys in the preceding period where 's' is seconds, 'm' is minutes, 'h' is hours, 'd' is days, 'w' is weeks and 'y' is years so 12h will show all keys changed in the last 12 hours.

.PARAMETER start

The start date/time in which to look for changes. If no date is given then the current day is used and if no time is given then midnight on that day is used. E.g. "26/01/17 07:00:00"

.PARAMETER end

The end date/time in which to look for changes. If no date is given then the current day is used and if no time is given then midnight on that day is used. E.g. "26/01/17 23:00:00"

.PARAMETER notin

Registry keys not changed in the specified time window are reported

.PARAMETER includes

A comma separated list of regex patterns to only show registry changed keys that match that pattern. E.g. "\\Sheet" will only show keys which start with "\Sheet"

.PARAMETER excludes

A comma separated list of regex patterns to not show registry changed keys that match that pattern. E.g. "\\Enum" will not show any keys which start with "\Enum"

.PARAMETER delimiter

The delimiter to use between the key name and datestamp in the output. The default is a colon.

.PARAMETER dateFormat

The date format to use in the output. See https://blogs.technet.microsoft.com/heyscriptingguy/2015/01/22/formatting-date-strings-with-powershell/

.PARAMETER outputFile

Will write results to the specified csv file

.PARAMETER gridView

Show results in a gridview

.EXAMPLE

.\regrecent.ps1 -key HKCU:\Software -last 1d

Show all registry keys in HKCU\Software changed in the last 1 day

.EXAMPLE

.\regrecent.ps1 -key HKLM:\Software -start "01/01/17" -end "31/01/17" -gridview

Show all registry keys in HKLM\Software changed in January 2017 in a grid view

.EXAMPLE

.\regrecent.ps1 -key HKEY_LOCAL_MACHINE\Software\Microsoft -start "01/01/17" -end "31/01/17" -notin

Show all registry keys in HKLM\Software\Microsoft not changed in January 2017

.EXAMPLE

.\regrecent.ps1 -key HKLM\System\CurrentControlSet -last 36h -exclude '\\Enum','\\Linkage' -outputFile registry.changes.csv 

Show all registry keys in HKLM\System\CurrentControlSet, except for keys beginning \Enum and \Linkage, which have changed in the last 36 hours and output to a csv file.
Note the escaping of the backslash characters in the -exclude arguments since they are regualr expressions

#>

[CmdletBinding()]

Param
(
    [Parameter(Mandatory=$true)]
    [string]$key ,
    [Parameter(ParameterSetName='Last')]
    [string]$last , 
    [Parameter(ParameterSetName='SinceBoot')]
    [switch]$sinceBoot ,
    [Parameter(ParameterSetName='StartTime')]
    [string]$start ,
    [string]$end ,
    [switch]$notin ,
    [string[]]$excludes ,
    [string[]]$includes ,
    [string]$delimiter = ':' ,
    [string]$outputFile ,
    [string]$dateFormat = 'G' ,
    [switch]$gridView
)

[hashtable]$regKeyConversions = `
@{
    'HKEY_CLASSES_ROOT' = 'HKCR'
    'HKEY_CURRENT_USER' = 'HKCU'
    'HKEY_LOCAL_MACHINE' = 'HKLM'
    'HKEY_USERS' = 'HKU'
}

Add-Type @"
    using System; 
    using System.Text;
    using System.Runtime.InteropServices; 
            
    namespace PInvoke.Win32 {

        public class advapi32 {
                [DllImport("advapi32.dll", CharSet = CharSet.Auto)]
                public static extern Int32 RegQueryInfoKey(
                    Microsoft.Win32.SafeHandles.SafeRegistryHandle hKey,
                    out UInt32 lpClass,
                    [In, Out] ref UInt32 lpcbClass,
                    UInt32 lpReserved,
                    out UInt32 lpcSubKeys,
                    out UInt32 lpcbMaxSubKeyLen,
                    out UInt32 lpcbMaxClassLen,
                    out UInt32 lpcValues,
                    out UInt32 lpcbMaxValueNameLen,
                    out UInt32 lpcbMaxValueLen,
                    out UInt32 lpcbSecurityDescriptor,
                    out Int64 lpftLastWriteTime
                );
        }
    }
"@

Function Get-RegTimeStamp
{
    [OutputType([datetime])]
    Param
    (
        $regkey
    )

    $LastWriteTime = $null

    if( $regKey )
    {
        $result = [PInvoke.win32.advapi32]::RegQueryInfoKey( $regKey.Handle , 
                                            [ref] $null, # ClassName, 
                                            [ref] $null, # ClassLength, 
                                            $null,       # Reserved
                                            [ref] $null, # SubKeyCount
                                            [ref] $null, # MaxSubKeyNameLength
                                            [ref] $null, # MaxClassLength
                                            [ref] $null, # ValueCount
                                            [ref] $null, # MaxValueNameLength 
                                            [ref] $null, # MaxValueValueLength 
                                            [ref] $null, # SecurityDescriptorSize
                                            [ref] $LastWriteTime )

        if( $result -eq 0 -and $LastWriteTime )
        {
            $LastWriteTime = [datetime]::FromFileTime( $LastWriteTime )
        }
    }
    $LastWriteTime
}

if( ! [string]::IsNullOrEmpty( $last ) )
{
    ## see what last character is as will tell us what units to work with
    [int]$multiplier = 0
    switch( $last[-1] )
    {
        "s" { $multiplier = 1 }
        "m" { $multiplier = 60 }
        "h" { $multiplier = 3600 }
        "d" { $multiplier = 86400 }
        "w" { $multiplier = 86400 * 7 }
        "y" { $multiplier = 86400 * 365 }
        default { Write-Error "Unknown multiplier `"$($last[-1])`"" ; return }
    }
    $endDate = Get-Date
    if( $last.Length -le 1 )
    {
        $startDate = $endDate.AddSeconds( -$multiplier )
    }
    else
    {
        $startDate = $endDate.AddSeconds( - ( ( $last.Substring( 0 ,$last.Length - 1 ) -as [int] ) * $multiplier ) )
    }
}
else
{
    if( $sinceBoot )
    {
        if( Get-Command Get-CimInstance -ErrorAction SilentlyContinue )
        {
            $startDate = Get-CimInstance -ClassName Win32_OperatingSystem | Select -ExpandProperty lastbootuptime
        }
        else
        {
            Write-Warning ( "Cannot use -sinceBoot with PowerShell version {0}, requires minimum 3.0" -f $PSVersionTable.PSVersion.Major )
            return
        }
    }
    elseif( ! $start )
    {
        Write-Error "Must specify at least a start date/time with -start or -last"
        return
    }
    else
    {
        $startDate = [datetime]::Parse( $start )
    }
    if( ! $end )
    {
        $endDate = Get-Date
    }
    else
    {
        $endDate = [datetime]::Parse( $end )
    }
}

## If key name is long format, like would get when copied from regedit, convert to PoSH reg provider path
[string]$changedKey = $regKeyConversions[ ( $key -split '\\' )[0] ]

if( ! [string]::IsNullOrEmpty( $changedKey ) )
{
    $key = $key -replace '^HK[A-Z_]+' , $changedKey
}

## If PoSH reg provider style path not given, as in missing :, then change it
if( $key -match '^(HK[A-Z]{2})\\[^:]' )
{
    $key = $key -replace "^$($Matches[1])" ,( $Matches[1] + ':' )
}

## Don't have out of the box paths for HKCR and HKU
if( $key -match '^(HKU|HKCR)' )
{
    try
    {
        $provider = Get-PSDrive -Name $matches[1] -ErrorAction SilentlyContinue
    }
    catch
    {
        $provider = $null
    }

    if( ! $provider )
    {
        [string]$rootKey = $null

        $regKeyConversions.GetEnumerator() | ForEach-Object `
        {
            if( $_.Value -eq $Matches[1] -and [string]::IsNullOrEmpty( $rootKey ) )
            {
                $rootKey = $_.Key
            }
        }

        $null = New-PSDrive -Name $Matches[1] -PSProvider Registry -Root "Registry::$rootKey"
    }
}

## Check top key as we'll be silent for other failures
if( ! ( Get-Item $key -EA Stop ) )
{
    return
}

$results = @( Get-ChildItem -Path $key -Recurse -EA SilentlyContinue | ForEach-Object `
{
    $thisKey = $_
    [bool]$excluded = $false
    if( $excludes -and $excludes.Count -gt 0 )
    {
        ForEach( $exclude in $excludes )
        {
            if( $thisKey -match $exclude )
            {
                $excluded = $true
                break
            }
        }
    }
    if( ! $excluded )
    {
        if( $includes -and $includes.Count -gt 0 )
        {
            $excluded = $true
            ForEach( $include in $includes )
            {
                if( $thisKey -match $include )
                {
                    $excluded = $false
                    break
                }
            }
        }
        else
        {
            $excluded = $false
        }
    }
    if( ! $excluded )
    {
        $lastwritten = Get-RegTimeStamp $thisKey
        if( $lastWritten )
        {
            if( ( ! $notin -and $lastWritten -ge $startDate -and $lastWritten -le $endDate ) `
                -or ( $notin -and ( $lastWritten -lt $startDate -or $lastWritten -gt $endDate ) ) )
            {
                New-Object -TypeName PSCustomObject -Property ( @{ 'Key' = $thisKey ; 'Last Written' = $lastwritten.ToString($dateFormat) } )
            }
        }
    }
} )

[string]$message = ( "Got $($results.Count) results from {0} to {1} for {2}" -f $startDate.ToString('G') ,$endDate.ToString($dateFormat) , $key )

Write-Verbose $message

if( $results -and $results.Count )
{
    if( ! [string]::IsNullOrEmpty( $outputFile ) )
    {
        $results | Export-Csv -Path $outputFile -NoTypeInformation -NoClobber
    }
    elseif( $gridView )
    {
        $results | Out-GridView -PassThru -Title $message
        $results.key | Out-GridView -PassThru -Title $message
    }
    else
    {
        $results | ForEach-Object `
        {
            "{0}{1}{2}" -f $_.Key , $delimiter , $_.'Last Written'
        }
    }
}

        



