# register-morning-standup.ps1
# Run once (as Administrator on Windows / with pwsh on Mac/Linux) to register all scheduled tasks.
#
# Tasks registered:
#   AIAgent_MorningStandup   - daily at 09:00
#   AIAgent_SaturdayPush     - every Saturday at 22:00
#   AIAgent_StrategyReview   - every Sunday at 08:00

$ErrorActionPreference = "Stop"
$msScript = Join-Path $PSScriptRoot "morning-standup.ps1"
$spScript = Join-Path $PSScriptRoot "saturday-push.ps1"
$srScript = Join-Path $PSScriptRoot "generate-strategy-review.ps1"

# ===========================================================
# Windows: Task Scheduler
# ===========================================================
if ($IsWindows -or ($null -eq $IsWindows)) {

    # --- morning-standup (daily 09:00) ---
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

    Write-Host "[OK] AIAgent_MorningStandup -- daily 09:00"

    # --- saturday-push (every Saturday 22:00) ---
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

    Write-Host "[OK] AIAgent_SaturdayPush  -- every Saturday 22:00"

    # --- strategy-review (every Sunday 08:00) ---
    $srAction  = New-ScheduledTaskAction `
        -Execute  "powershell.exe" `
        -Argument "-NonInteractive -ExecutionPolicy Bypass -File `"$srScript`""
    $srTrigger  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "08:00"
    $srSettings = New-ScheduledTaskSettingsSet `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 30) `
        -StartWhenAvailable

    Register-ScheduledTask `
        -TaskName "AIAgent_StrategyReview" `
        -Action   $srAction `
        -Trigger  $srTrigger `
        -Settings $srSettings `
        -Force | Out-Null

    Write-Host "[OK] AIAgent_StrategyReview -- every Sunday 08:00"

# ===========================================================
# Mac: launchd
# ===========================================================
} elseif ($IsMacOS) {

    $launchAgents = [System.IO.Path]::Combine($env:HOME, "Library", "LaunchAgents")
    New-Item -ItemType Directory -Force -Path $launchAgents | Out-Null

    # pwsh のパスを確認（PS 5.1 互換: ?. 不使用）
    $_pwshInfo = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($_pwshInfo) { $pwshPath = $_pwshInfo.Source } else { $pwshPath = "/usr/local/bin/pwsh" }

    # --- morning-standup (daily 09:00) ---
    $msPlist = Join-Path $launchAgents "com.aiagent.morningstandup.plist"
    $msPlistContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.aiagent.morningstandup</string>
    <key>ProgramArguments</key>
    <array>
        <string>$pwshPath</string>
        <string>-NonInteractive</string>
        <string>-ExecutionPolicy</string>
        <string>Bypass</string>
        <string>-File</string>
        <string>$msScript</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$env:HOME/Library/Logs/aiagent-morningstandup.log</string>
    <key>StandardErrorPath</key>
    <string>$env:HOME/Library/Logs/aiagent-morningstandup.err</string>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
"@
    [System.IO.File]::WriteAllText($msPlist, $msPlistContent, [System.Text.Encoding]::UTF8)
    & launchctl unload $msPlist 2>$null
    & launchctl load $msPlist
    Write-Host "[OK] AIAgent_MorningStandup -- daily 09:00"
    Write-Host "     plist: $msPlist"

    # --- saturday-push (every Saturday 22:00) ---
    # launchd の Weekday: 0=日, 1=月, ... 6=土
    $spPlist = Join-Path $launchAgents "com.aiagent.saturdaypush.plist"
    $spPlistContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.aiagent.saturdaypush</string>
    <key>ProgramArguments</key>
    <array>
        <string>$pwshPath</string>
        <string>-NonInteractive</string>
        <string>-ExecutionPolicy</string>
        <string>Bypass</string>
        <string>-File</string>
        <string>$spScript</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>6</integer>
        <key>Hour</key>
        <integer>22</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$env:HOME/Library/Logs/aiagent-saturdaypush.log</string>
    <key>StandardErrorPath</key>
    <string>$env:HOME/Library/Logs/aiagent-saturdaypush.err</string>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
"@
    [System.IO.File]::WriteAllText($spPlist, $spPlistContent, [System.Text.Encoding]::UTF8)
    & launchctl unload $spPlist 2>$null
    & launchctl load $spPlist
    Write-Host "[OK] AIAgent_SaturdayPush  -- every Saturday 22:00"
    Write-Host "     plist: $spPlist"

    # --- strategy-review (every Sunday 08:00) ---
    # launchd の Weekday: 0=日
    $srPlist = Join-Path $launchAgents "com.aiagent.strategyreview.plist"
    $srPlistContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.aiagent.strategyreview</string>
    <key>ProgramArguments</key>
    <array>
        <string>$pwshPath</string>
        <string>-NonInteractive</string>
        <string>-ExecutionPolicy</string>
        <string>Bypass</string>
        <string>-File</string>
        <string>$srScript</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>0</integer>
        <key>Hour</key>
        <integer>8</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$env:HOME/Library/Logs/aiagent-strategyreview.log</string>
    <key>StandardErrorPath</key>
    <string>$env:HOME/Library/Logs/aiagent-strategyreview.err</string>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
"@
    [System.IO.File]::WriteAllText($srPlist, $srPlistContent, [System.Text.Encoding]::UTF8)
    & launchctl unload $srPlist 2>$null
    & launchctl load $srPlist
    Write-Host "[OK] AIAgent_StrategyReview -- every Sunday 08:00"
    Write-Host "     plist: $srPlist"

# ===========================================================
# Linux: cron
# ===========================================================
} elseif ($IsLinux) {

    $_pwshInfo = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($_pwshInfo) { $pwshPath = $_pwshInfo.Source } else { $pwshPath = "/usr/bin/pwsh" }

    $cronLines = @(
        "0 9 * * * $pwshPath -NonInteractive -ExecutionPolicy Bypass -File `"$msScript`"  # AIAgent_MorningStandup",
        "0 22 * * 6 $pwshPath -NonInteractive -ExecutionPolicy Bypass -File `"$spScript`"  # AIAgent_SaturdayPush",
        "0 8 * * 0 $pwshPath -NonInteractive -ExecutionPolicy Bypass -File `"$srScript`"  # AIAgent_StrategyReview"
    )
    $existing = & crontab -l 2>$null
    $newCron = ($existing + $cronLines) -join "`n"
    $newCron | & crontab -
    Write-Host "[OK] AIAgent_MorningStandup / AIAgent_SaturdayPush / AIAgent_StrategyReview -- cron registered"
}

Write-Host ""
Write-Host "Done. All tasks registered."
