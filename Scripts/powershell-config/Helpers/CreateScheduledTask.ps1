# Path: Scripts/powershell-config/CreateScheduledTask.ps1

# Define the action to run the PowerShell script
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$ProfileDir\Scripts\powershell-config\UpdateApps.ps1`""

# Define the trigger to run daily at 2 AM
$trigger = New-ScheduledTaskTrigger -Daily -At "2:00AM"

# Define the principal (user) under which the task will run
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount

# Register the scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "UpdateAppsTask" -Description "Updates applications daily at 2 AM"