#Import the OSD Module to initialize $OSDModuleResource
Import-Module OSD -Force

#Customize the OSDCloud Defaults
$OSDModuleResource.OSDCloud.Default.Activation = 'Retail'
$OSDModuleResource.OSDCloud.Default.Edition = 'Pro'
$OSDModuleResource.OSDCloud.Default.Language = 'en-gb'

#Start OSDCloud GUI
Start-OSDCloudGUI