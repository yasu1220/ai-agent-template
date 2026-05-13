# morning-standup.ps1
# 毎朝 7:00 に実行。前夜のAI作業結果と今日のTop3を集計し、daily/に書き出す。

$ErrorActionPreference = "Stop"
$base = "C:\Users\yasu\Documents\テスト会社\AIエージェント会社設立"
$today = Get-Date -Format "yyyy-MM-dd"
$yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")

# ログ準備
$logDir = "$base\logs\$today"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = "$logDir\morning-standup.log"

function Write-Log($msg) {
    $ts = Get-Date -Format "HH:mm:ss"
    "[$ts] $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
    Write-Host "[$ts] $msg"
}

Write-Log "=== morning-standup 開始 ==="

# 1. 今日のdaily/が存在しなければ_template.mdからコピー
$dailyFile = "$base\daily\$today.md"
if (-not (Test-Path $dailyFile)) {
    $template = "$base\daily\_template.md"
    if (Test-Path $template) {
        Copy-Item $template $dailyFile
        # YYYY-MM-DD を実際の日付に置換
        (Get-Content $dailyFile -Raw -Encoding UTF8) -replace 'YYYY-MM-DD', $today |
            Set-Content $dailyFile -Encoding UTF8
        Write-Log "daily/$today.md を生成しました"
    }
}

# 2. inbox の未処理件数をカウント
$inboxDir = "$base\obsidian-vault\00_inbox"
$inboxCount = (Get-ChildItem $inboxDir -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne "_template.md" }).Count
Write-Log "未処理 inbox: $inboxCount 件"

# 3. task-board からP0タスクを抽出
$boardFile = "$base\task-board\main-board.md"
$p0Count = 0
$p1Count = 0
if (Test-Path $boardFile) {
    $content = Get-Content $boardFile -Raw -Encoding UTF8
    $p0Count = ([regex]::Matches($content, '#P0')).Count
    $p1Count = ([regex]::Matches($content, '#P1')).Count
    Write-Log "P0タスク: $p0Count 件 / P1タスク: $p1Count 件"
}

# 4. 昨日のlogs/から完了タスクを集計
$yesterdayLogDir = "$base\logs\$yesterday"
$completedCount = 0
if (Test-Path $yesterdayLogDir) {
    $logs = Get-ChildItem $yesterdayLogDir -Filter "*.log" -ErrorAction SilentlyContinue
    foreach ($log in $logs) {
        $logContent = Get-Content $log.FullName -Raw -ErrorAction SilentlyContinue
        $completedCount += ([regex]::Matches($logContent, 'completed|done')).Count
    }
}
Write-Log "昨日の完了タスク（推定）: $completedCount 件"

# 5. サマリを daily/$today.md に追記
$summary = @"

---

## 📊 morning-standup 実行結果 ($(Get-Date -Format "HH:mm"))

- **未処理inbox**: $inboxCount 件
- **P0タスク**: $p0Count 件 / **P1タスク**: $p1Count 件
- **昨日の完了タスク（推定）**: $completedCount 件

> 詳細は task-board/main-board.md を参照してください。
> AIエージェント実行の本格実装は次フェーズで対応予定。

"@
Add-Content -Path $dailyFile -Value $summary -Encoding UTF8

Write-Log "=== morning-standup 完了 ==="
Write-Host ""
Write-Host "今日のdaily: $dailyFile"
