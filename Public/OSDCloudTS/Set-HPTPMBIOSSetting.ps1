function Set-HPTPMBIOSSettings {
    Set-HPBIOSSetting -SettingName 'TPM Device' -Value 'Available'
    Set-HPBIOSSetting -SettingName 'TPM State' -Value 'Enable'
    Set-HPBIOSSetting -SettingName 'TPM Activation Policy' -Value 'No Prompts'
}