function Show-MsSettings {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateSet(
            'About',
            'AdvancedScaling',
            'DateTime',
            'DefaultApps',
            'Display',
            'Ethernet',
            'Graphics',
            'Language',
            'Network',
            'NetworkStatus',
            'Notifications',
            'OptionalFeatures',
            'PowerSleep',
            'Privacy',
            'Proxy',
            'Region',
            'Sound',
            'SoundDevices',
            'VPN',
            'WiFi',
            'WiFiAvailable',
            'WiFiNetworks'
        )]
        $Setting
    )
    #=======================================================================
    #	Block
    #=======================================================================
    Block-WinPE
    #=======================================================================
    #	Start-Process
    #=======================================================================
    switch ($Setting)
    {
        $null               {Start-Process ms-settings:}
        About               {Start-Process ms-settings:about}
        AdvancedScaling     {Start-Process ms-settings:display-advanced}
        DateTime            {Start-Process ms-settings:dateandtime}
        DefaultApps         {Start-Process ms-settings:defaultapps}
        Display             {Start-Process ms-settings:display}
        Ethernet            {Start-Process ms-settings:network-ethernet}
        Graphics            {Start-Process ms-settings:display-advancedgraphics}
        Language            {Start-Process ms-settings:regionlanguage}
        Network             {Start-Process ms-settings:network}
        NetworkStatus       {Start-Process ms-settings:network-status}
        Notifications       {Start-Process ms-settings:notifications}
        OptionalFeatures    {Start-Process ms-settings:optionalfeatures}
        PowerSleep          {Start-Process ms-settings:powersleep}
        Privacy             {Start-Process ms-settings:privacy}
        Proxy               {Start-Process ms-settings:network-proxy}
        Region              {Start-Process ms-settings:regionformatting}
        Sound               {Start-Process ms-settings:sound}
        SoundDevices        {Start-Process ms-settings:sounddevices}
        VPN                 {Start-Process ms-settings:network-vpn}
        WiFi                {Start-Process ms-settings:network-wifi}
        WiFiAvailable       {Start-Process ms-availablenetworks:}
        WiFiNetworks        {Start-Process ms-settings:network-wifisettings}
    }
    #=======================================================================
}