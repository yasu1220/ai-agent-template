# weekly-strategy-brief.ps1
# 毎週月曜 7:00 に実行。先週の状況サマリと今週の方針を生成する。

$ErrorActionPreference = "Stop"
$base = Split-Path -Parent $PSScriptRoot
$today = Get-Date -Format "yyyy-MM-dd"
$weekNum = [System.Globalization.ISOWeek]::GetWeekOfYear((Get-Date))

$logDir = "$base\logs\$today"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = "$logDir\weekly-strategy-brief.log"

function Write-Log($msg) {
    $ts = Get-Date -Format "HH:mm:ss"
    "[$ts] $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

Write-Log "=== weekly-strategy-brief 開始 (Week $weekNum) ==="

# 出力先
$briefFile = "$base\obsidian-vault\03_decisions\weekly-brief-$(Get-Date -Format 'yyyy')-W$($weekNum.ToString('00')).md"

# 直近7日分の logs を集計
$weekStart = (Get-Date).AddDays(-7)
$weekLogs = Get-ChildItem "$base\logs" -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $weekStart }

$totalLogLines = 0
foreach ($d in $weekLogs) {
    Get-ChildItem $d.FullName -Filter "*.log" | ForEach-Object {
        $totalLogLines += (Get-Content $_.FullName | Measure-Object -Line).Lines
    }
}

# task-board の現状
$boardFile = "$base\task-board\main-board.md"
$inProgress = 0
$blocked = 0
$done = 0
if (Test-Path $boardFile) {
    $content = Get-Content $boardFile -Raw -Encoding UTF8
    $inProgress = ([regex]::Matches($content, '## 🔄 IN PROGRESS[\s\S]*?(?=##|$)') |
        ForEach-Object { ([regex]::Matches($_.Value, '\[ \]')).Count } | Measure-Object -Sum).Sum
    $blocked = ([regex]::Matches($content, '## 🛑 BLOCKED[\s\S]*?(?=##|$)') |
        ForEach-Object { ([regex]::Matches($_.Value, '\[ \]')).Count } | Measure-Object -Sum).Sum
    $done = ([regex]::Matches($content, '\[x\]')).Count
}

# ブリーフ生成
$brief = @"
# 週次戦略ブリーフ Week $weekNum / $(Get-Date -Format 'yyyy')

**生成日**: $today
**期間**: $($weekStart.ToString('yyyy-MM-dd')) 〜 $today

---

## 📊 先週のサマリ（自動集計）

- 進行中タスク: $inProgress 件
- ブロック中: $blocked 件
- 完了済み: $done 件
- AI実行ログ行数: $totalLogLines 行

## 🎯 今週の推奨アクション

> ※ ここは business-strategy エージェントに後で書かせる
> 現状は手動で記入してください

1.
2.
3.

## ⚠️ 懸念事項

> ※ blocked が長期化しているタスクの確認等

## 📌 ADR候補

> ※ 戦略変更が必要な事項があれば、別途 YYYY-MM-DD-decisions.md に起票

---

*このブリーフは weekly-strategy-brief.ps1 によって自動生成されました。*
*業界ニュース集計・推奨アクション生成は business-strategy エージェントの実装後に対応予定。*
"@

Set-Content -Path $briefFile -Value $brief -Encoding UTF8
Write-Log "ブリーフ生成: $briefFile"
Write-Log "=== weekly-strategy-brief 完了 ==="

Write-Host "`n生成されました: $briefFile"
