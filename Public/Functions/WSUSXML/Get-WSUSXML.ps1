<#
.SYNOPSIS
Returns an Array of Microsoft Updates

.DESCRIPTION
Returns an Array of Microsoft Updates contained in the local WSUS Cats

.LINK
https://osd.osdeploy.com/

.PARAMETER GridView
Displays the results in GridView with -PassThru

.PARAMETER Silent
Hide the Current Update Date information
#>
function Get-WSUSXML {
    [CmdletBinding()]
    PARAM (
        #Filter by Catalog Property
        [Parameter(Position = 0)]
        [ValidateSet(
            'All',
            'Enablement',
            'FeatureUpdate',
            'Office',
            'Office 2010 32-Bit',
            'Office 2010 64-Bit',
            'Office 2013 32-Bit',
            'Office 2013 64-Bit',
            'Office 2016 32-Bit',
            'Office 2016 64-Bit',
            'Windows',
            'Windows 10',
            'Windows 10 Dynamic Update',
            'Windows 11',
            'Windows 11 Dynamic Update',
            'Windows Client',
            'Windows Server'
        )]
        [Alias('Format')]
        [string]$Catalog = 'All',

        #Filter by UpdateArch Property
        [ValidateSet('x64','x86')]
        [string]$UpdateArch,

        #Filter by UpdateBuild Property
        [ValidateSet(1507,1511,1607,1703,1709,1803,1809,1903,1909,2004,'20H2','21H1','21H2','22H2','23H2','24H2')]
        [string]$UpdateBuild,

        #Filter by UpdateGroup Property
        [ValidateSet('AdobeSU','DotNet','DotNetCU','LCU','Optional','SSU')]
        [string]$UpdateGroup,

        #Filter by UpdateOS Property
        [ValidateSet('Windows 11','Windows 10','Windows Server')]
        [string]$UpdateOS,

        #Display the results in GridView
        [System.Management.Automation.SwitchParameter]$GridView,

        #Don't display the Module Information
        [System.Management.Automation.SwitchParameter]$Silent
    )
    #===================================================================================================
    #   Defaults
    #===================================================================================================
    $WSUSXMLCatsPath = Join-Path -Path $(Get-OSDCatsPath) -ChildPath 'wsusxml'
    $WSUSXMLVersion = $($MyInvocation.MyCommand.Module.Version)
    #===================================================================================================
    $WSUSXMLCats = Get-ChildItem -Path "$WSUSXMLCatsPath\*" -Include "*.xml" -Recurse | Select-Object -Property *

    switch ($Catalog) {
        'Enablement'                    {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Enablement'}}
        'FeatureUpdate'                 {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'FeatureUpdate'}}
        'Office'                        {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Office'}}
        'Office 2010 32-Bit'            {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Office 2010'}}
        'Office 2010 64-Bit'            {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Office 2010'}}
        'Office 2013 32-Bit'            {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Office 2013'}}
        'Office 2013 64-Bit'            {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Office 2013'}}
        'Office 2016 32-Bit'            {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Office 2016'}}
        'Office 2016 64-Bit'            {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Office 2016'}}
        'Windows' {
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Windows'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'Enablement'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}
        }
        'Windows Client' {
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Windows'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'Dynamic Update'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'Enablement'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'Server'}
        }
        'Windows 10' {
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Windows 10'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'Dynamic Update'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'Enablement'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}
        }
        'Windows 11' {
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Windows 11'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'Dynamic Update'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'Enablement'}
            $WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}
        }
        'Windows 10 Dynamic Update' {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -eq $Catalog}}
        'Windows 11 Dynamic Update' {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -eq $Catalog}}
        'Windows Server'            {$WSUSXMLCats = $WSUSXMLCats | Where-Object {$_.BaseName -match 'Windows Server'}}
    }
    #===================================================================================================
    #   Update Information
    #===================================================================================================
    if (!($Silent.IsPresent)) {
        Write-Verbose "WSUSXML $WSUSXMLVersion $Catalog" -Verbose
    }
    #===================================================================================================
    #   Variables
    #===================================================================================================
    $WSUSXML = @()
    #===================================================================================================
    #   Import Catalog XML Files
    #===================================================================================================
    foreach ($WSUSXMLCatalog in $WSUSXMLCats) {
        $WSUSXML += Import-Clixml -Path "$($WSUSXMLCatalog.FullName)"
    }
    #===================================================================================================
    #   Standard Filters
    #===================================================================================================
    $WSUSXML = $WSUSXML | Where-Object {$_.FileName -notlike "*.exe"}
    $WSUSXML = $WSUSXML | Where-Object {$_.FileName -notlike "*.psf"}
    $WSUSXML = $WSUSXML | Where-Object {$_.FileName -notlike "*.txt"}
    $WSUSXML = $WSUSXML | Where-Object {$_.FileName -notlike "*delta.exe"}
    $WSUSXML = $WSUSXML | Where-Object {$_.FileName -notlike "*express.cab"}

    if ($Catalog -match 'Office') {
        if ($Catalog -match '32-Bit') {
            $WSUSXML = $WSUSXML | Where-Object {$_.Title -match '32-Bit'}
        }
        if ($Catalog -match '64-Bit') {
            $WSUSXML = $WSUSXML | Where-Object {$_.Title -notmatch '64-Bit'}
        }
    }
    #===================================================================================================
    #   Filter
    #===================================================================================================
    if ($UpdateArch) {$WSUSXML = $WSUSXML | Where-Object {$_.UpdateArch -eq $UpdateArch}}
    if ($UpdateBuild) {$WSUSXML = $WSUSXML | Where-Object {$_.UpdateBuild -eq $UpdateBuild}}
    if ($UpdateGroup) {$WSUSXML = $WSUSXML | Where-Object {$_.UpdateGroup -eq $UpdateGroup}}
    if ($UpdateOS) {$WSUSXML = $WSUSXML | Where-Object {$_.UpdateOS -eq $UpdateOS}}
    #===================================================================================================
    #   Sorting
    #===================================================================================================
    #$WSUSXML = $WSUSXML | Sort-Object -Property @{Expression = {$_.CreationDate}; Ascending = $false}, Size -Descending
    $WSUSXML = $WSUSXML | Sort-Object -Property CreationDate -Descending
    if ($Catalog -eq 'FeatureUpdate') {$WSUSXML = $WSUSXML | Sort-Object -Property Title}
    #===================================================================================================
    #   GridView
    #===================================================================================================
    if ($GridView.IsPresent) {
        $WSUSXML = $WSUSXML | Out-GridView -PassThru -Title 'Select Updates to Return'
    }
    #===================================================================================================
    #   Return
    #===================================================================================================
    Return $WSUSXML
}