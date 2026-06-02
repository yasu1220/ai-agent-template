# Scheduled Tasks

Windows タスクスケジューラに登録する PowerShell スクリプト群。

## スクリプト一覧

| ファイル | 実行頻度 | 役割 |
|---|---|---|
| `morning-standup.ps1` | 毎朝 9:00 | daily 生成・タスク選定・git push |
| `saturday-push.ps1` | 毎週土曜 22:00 | progress-tracking の git push |
| `task-dispatch.ps1` | 1時間ごと | inbox→タスク自動振り分け |
| `weekly-strategy-brief.ps1` | 毎週月曜 7:00 | 戦略ブリーフ生成 |
| `nightly-qa.ps1` | 毎晩 23:00 | 整合性チェック |
| `next-task-id.ps1` | 都度呼出 | 次のタスクIDを返す |
| `register-morning-standup.ps1` | 初回のみ | タスクスケジューラに登録 |

## タスクスケジューラへの登録

PowerShell を **管理者権限で開いて**、リポジトリのルートで以下を実行：

```powershell
& ".\scheduled\register-morning-standup.ps1"
```

これで2つのタスクが登録されます：

| タスク名 | 実行タイミング | 役割 |
|---|---|---|
| `AIAgent_MorningStandup` | 毎日 09:00 | daily ファイル生成・タスク選定・git push |
| `AIAgent_SaturdayPush` | 毎週土曜 22:00 | progress-tracking の git push |

## 削除する場合

```powershell
Unregister-ScheduledTask -TaskName "AIAgent_MorningStandup" -Confirm:$false
Unregister-ScheduledTask -TaskName "AIAgent_SaturdayPush" -Confirm:$false
```

## 注意

各スクリプトは **現状ログ生成までしか実装していません**。  
実際にAIエージェントを呼び出す部分は、Claude Code または Cowork のCLI機能と連携して書く必要があります（次フェーズで対応）。
