#================================================
#   WinPE PostOS Sample
#   AutopilotOOBE Offline Staging
#================================================
Install-Module AutopilotOOBE -Force
Import-Module AutopilotOOBE -Force

$Params = @{
    Title = 'OSDeploy Autopilot Registration'
    GroupTag = 'Enterprise'
    GroupTagOptions = 'Development','Enterprise'
    Hidden = 'AddToGroup','AssignedComputerName','AssignedUser','PostAction'
    Assign = $true
    Run = 'NetworkingWireless'
}
AutopilotOOBE @Params