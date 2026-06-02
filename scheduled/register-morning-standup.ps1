# register-morning-standup.ps1
# Run once (as Administrator) to register both scheduled tasks in Windows Task Scheduler.
#
# Tasks registered:
#   AIAgent_MorningStandup  - daily at 09:00
#   AIAgent_SaturdayPush    - every Saturday at 22:00

$ErrorActionPreference = "Stop"

# --- morning-standup (daily 09:00) ---
$msScript  = Join-Path $PSScriptRoot "morning-standup.ps1"
$msAction  = New-ScheduledTaskAction `
    -Execute  "powershell.exe" `
    -Argument "-NonInteractive -ExecutionPolicy Bypass -File `"$msScript`""
$msTrigger  = New-ScheduledTaskTrigger -Daily -At "09:00"
$msSettings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10) `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName "AIAgent_MorningStandup" `
    -Action   $msAction `
    -Trigger  $msTrigger `
    -Settings $msSettings `
    -Force | Out-Null

Write-Host "[OK] AIAgent_MorningStandup -- daily 09:00 -> $msScript"

# --- saturday-push (every Saturday 22:00) ---
$spScript  = Join-Path $PSScriptRoot "saturday-push.ps1"
$spAction  = New-ScheduledTaskAction `
    -Execute  "powershell.exe" `
    -Argument "-NonInteractive -ExecutionPolicy Bypass -File `"$spScript`""
$spTrigger  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Saturday -At "22:00"
$spSettings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName "AIAgent_SaturdayPush" `
    -Action   $spAction `
    -Trigger  $spTrigger `
    -Settings $spSettings `
    -Force | Out-Null

Write-Host "[OK] AIAgent_SaturdayPush  -- every Saturday 22:00 -> $spScript"
Write-Host ""
Write-Host "Done. Verify with:"
Write-Host "  Get-ScheduledTask -TaskName AIAgent_MorningStandup"
Write-Host "  Get-ScheduledTask -TaskName AIAgent_SaturdayPush"