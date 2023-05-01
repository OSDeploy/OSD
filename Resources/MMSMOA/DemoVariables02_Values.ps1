#Import the OSD Module to initialize $OSDModuleResource
Import-Module OSD -Force

#Customize the OSDCloud Defaults
$OSDModuleResource.OSDCloud.Default.Activation = 'Retail'
$OSDModuleResource.OSDCloud.Default.Edition = 'Pro'
$OSDModuleResource.OSDCloud.Default.Language = 'en-gb'

#Customize the OSDCloud Values
$OSDModuleResource.OSDCloud.Values.Activation = 'Retail'
$OSDModuleResource.OSDCloud.Values.ReleaseID = '22H2','22H2'
$OSDModuleResource.OSDCloud.Values.Edition = 'Home','Pro'
$OSDModuleResource.OSDCloud.Values.Name = 'Windows 11 22H2 x64','Windows 11 21H2 x64','Windows 10 22H2 x64'
$OSDModuleResource.OSDCloud.Values.Language = 'en-gb'

#Start OSDCloud GUI
Start-OSDCloudGUI