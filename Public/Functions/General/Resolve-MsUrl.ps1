<#
.SYNOPSIS
Resolves a short Microsoft akams or a fwlink URL
.DESCRIPTION
Resolves a short Microsoft akams or a fwlink URL
.LINK
https://osd.osdeploy.com
#>
function Resolve-MsUrl
{
    [OutputType([System.Uri])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        # Uri to resolve
        [System.Uri]
        $Uri
    )
    
    switch ($Uri) {
        HonoluluDownload    {$Uri = 'https://aka.ms/HonoluluDownload'}
        MCMultiplayerHelp   {$Uri = 'https://aka.ms/MCMultiplayerHelp'}
        SignupAzureDevOps   {$Uri = 'https://aka.ms/SignupAzureDevOps'}
        WS03blog            {$Uri = 'https://aka.ms/WS03blog'}
        WinterofXamarin     {$Uri = 'https://aka.ms/WinterofXamarin'}
        aadv2               {$Uri = 'https://aka.ms/aadv2'}
        account             {$Uri = 'https://aka.ms/account'}
        admincenter         {$Uri = 'https://aka.ms/admincenter'}
        armworkshop         {$Uri = 'https://aka.ms/citadel/arm'}
        authapp             {$Uri = 'https://aka.ms/authapp'}
        azsb                {$Uri = 'https://aka.ms/azsb'}
        azureadvisor        {$Uri = 'https://aka.ms/azureadvisor'}
        azureportal         {$Uri = 'https://aka.ms/azureportal'}
        azuretipsandtricks  {$Uri = 'https://aka.ms/azuretipsandtricks'}
        dsvm                {$Uri = 'https://aka.ms/dsvm'}
        insider             {$Uri = 'https://aka.ms/insider'}
        m365pnp             {$Uri = 'https://aka.ms/m365pnp'}
        mdwdataops          {$Uri = 'https://aka.ms/mdw-dataops'}
        mfasetup            {$Uri = 'https://aka.ms/MFASetup'}
        mslab               {$Uri = 'https://aka.ms/mslab'}
        mslabdownload       {$Uri = 'https://aka.ms/mslab/download'}
        mysecurityinfo      {$Uri = 'https://aka.ms/mysecurityinfo'}
        office              {$Uri = 'https://aka.ms/office'}
        officepowershell    {$Uri = 'https://aka.ms/office-powershell'}
        onedrive            {$Uri = 'https://aka.ms/onedrive'}
        onedrivesetup       {$Uri = 'https://go.microsoft.com/fwlink/p/?LinkID=2182910'}
        privacy             {$Uri = 'https://aka.ms/privacy'}
        remoteconnect       {$Uri = 'https://aka.ms/remoteconnect'}
        server              {$Uri = 'https://aka.ms/server'}
        spfx                {$Uri = 'https://aka.ms/spfx-extensions'}
        teams-samples       {$Uri = 'https://aka.ms/teams-samples'}
        thirdpartynotices   {$Uri = 'https://aka.ms/thirdpartynotices'}
        upgradecenter       {$Uri = 'https://aka.ms/upgradecenter'}
        vscode              {$Uri = 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user'}
        vse2022             {$Uri = 'https://aka.ms/vs/17/release/vs_enterprise.exe'}
        wac-insiders-feed   {$Uri = 'https://aka.ms/wac-insiders-feed'}
        wacdownload         {$Uri = 'https://aka.ms/WACDownload'}
        win10releaseinfo    {$Uri = 'https://aka.ms/win10releaseinfo'}
        win10releasenotes   {$Uri = 'https://aka.ms/win10releasenotes'}
        windows             {$Uri = 'https://aka.ms/windows'}
        windowsadmincenter  {$Uri = 'https://aka.ms/WindowsAdminCenter'}
        winserverdata       {$Uri = 'https://aka.ms/winserverdata'}
        yourpc              {$Uri = 'https://aka.ms/yourpc'}
    }

    if ($Uri)
    {
        try
        {
            $WebRequest = Invoke-WebRequest "$Uri" -UseBasicParsing -Method Head -MaximumRedirection 0 -ErrorAction SilentlyContinue
            if ($WebRequest.Headers.Location)
            {
                $WebRequest.Headers.Location
            }
        }
        catch
        {
            Write-Warning $_.Exception.Message
        }
    }
}