function osdcloud-HPBIOSSetSetting {
    [CmdletBinding()]
Param (
	[Parameter(Mandatory=$true)]
	$SettingName,
	[Parameter(Mandatory=$true)]
	$Value,
	[Parameter(Mandatory=$false)]
	$BIOSPW
	)

<# Testing
$SettingName = "SVM CPU Virtualization"
$Value = "Enable"
$BIOSPW = 'P@ssw0rd'
#>

$BIOS= Get-WmiObject -class hp_biossettinginterface -Namespace "root\hp\instrumentedbios"
$BIOSSetting = Get-CimInstance -class hp_biossetting -Namespace "root\hp\instrumentedbios"
$CurrentValue = ($BIOSSetting | ?{ $_.Name -eq $SettingName }).CurrentValue

if ($CurrentValue -ne $Null)
    {
    if ($CurrentValue -eq $Value)
        {
        Write-Output "BIOS Setting: $SettingName already configured to Requested Value: $Value"
        }
    else
        {
        If (($BIOSSetting | ?{ $_.Name -eq 'Setup Password' }).IsSet -eq 0){
            $Result = $BIOS.SetBIOSSetting($SettingName,$Value)
            }
        else{
            $PW = "<utf-16/>$BIOSPW"
            $Result = $BIOS.SetBIOSSetting($SettingName,$Value,$PW)
            }
        if ($Result.Return -eq 0){
            Write-Output "Successfully Updated: $SettingName to: $Value"
            }
        else{
            $BIOSSetting = Get-CimInstance -class hp_biossetting -Namespace "root\hp\instrumentedbios"
            $CurrentValue = ($BIOSSetting | ?{ $_.Name -eq $SettingName }).CurrentValue
            Write-Output "Failed to Update BIOS Setting: $SettingName to: $Value"
            Write-Output "Current Value: $CurrentValue"
            }
        }
    }
else
    {
    Write-Output "BIOS Setting: $SettingName is NOT Available on this Hardware"
    }
}