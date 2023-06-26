#Requires -Modules @{ ModuleName="OSD"; ModuleVersion="23.5.26.1" }
#Requires -PSEdition Desktop
#Requires -RunAsAdministrator

#How To: Remove Appx Provisioned Packages by Match

$RemoveAppx = "CommunicationsApps","OfficeHub","People","Skype","Solitaire","Xbox","ZuneMusic","ZuneVideo"
foreach ($Item in $RemoveAppx) {
    Remove-AppxOnline -Name $Item -Verbose
}