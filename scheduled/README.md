# Scheduled Tasks

Windows タスクスケジューラに登録する PowerShell スクリプト群。

## スクリプト一覧

| ファイル | 実行頻度 | 役割 |
|---|---|---|
| `morning-standup.ps1` | 毎朝 7:00 | 今日の状況サマリ生成 |
| `task-dispatch.ps1` | 1時間ごと | inbox→タスク自動振り分け |
| `weekly-strategy-brief.ps1` | 毎週月曜 7:00 | 戦略ブリーフ生成 |
| `nightly-qa.ps1` | 毎晩 23:00 | 整合性チェック |
| `next-task-id.ps1` | 都度呼出 | 次のタスクIDを返す |

## タスクスケジューラへの登録

PowerShell を **管理者権限で開いて** 実行：

```powershell
$base = "C:\Users\yasu\Documents\テスト会社\AIエージェント会社設立\scheduled"

# 朝のスタンドアップ（毎朝 7:00）
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$base\morning-standup.ps1`""
$trigger = New-ScheduledTaskTrigger -Daily -At 7:00am
Register-ScheduledTask -TaskName "AI-MorningStandup" -Action $action -Trigger $trigger -RunLevel Limited

# task-dispatch（1時間ごと）
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$base\task-dispatch.ps1`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1)
Register-ScheduledTask -TaskName "AI-TaskDispatch" -Action $action -Trigger $trigger -RunLevel Limited

# 週次戦略ブリーフ（毎週月曜 7:00）
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$base\weekly-strategy-brief.ps1`""
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 7:00am
Register-ScheduledTask -TaskName "AI-WeeklyBrief" -Action $action -Trigger $trigger -RunLevel Limited

# 夜間QA（毎晩 23:00）
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$base\nightly-qa.ps1`""
$trigger = New-ScheduledTaskTrigger -Daily -At 23:00
Register-ScheduledTask -TaskName "AI-NightlyQA" -Action $action -Trigger $trigger -RunLevel Limited
```

## 削除する場合

```powershell
Unregister-ScheduledTask -TaskName "AI-MorningStandup" -Confirm:$false
Unregister-ScheduledTask -TaskName "AI-TaskDispatch" -Confirm:$false
Unregister-ScheduledTask -TaskName "AI-WeeklyBrief" -Confirm:$false
Unregister-ScheduledTask -TaskName "AI-NightlyQA" -Confirm:$false
```

## 注意

各スクリプトは **現状ログ生成までしか実装していません**。  
実際にAIエージェントを呼び出す部分は、Claude Code または Cowork のCLI機能と連携して書く必要があります（次フェーズで対応）。
