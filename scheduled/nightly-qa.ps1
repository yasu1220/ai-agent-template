# nightly-qa.ps1
# 毎晩 23:00 に実行。整合性チェック・古いファイルの検出を行う。

$ErrorActionPreference = "Stop"
$base = "C:\Users\yasu\Documents\テスト会社\AIエージェント会社設立"
$today = Get-Date -Format "yyyy-MM-dd"

$logDir = "$base\logs\$today"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = "$logDir\nightly-qa.log"

function Write-Log($msg) {
    $ts = Get-Date -Format "HH:mm:ss"
    "[$ts] $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

Write-Log "=== nightly-qa 開始 ==="

# 1. task-board と obsidian-vault/04_projects/ の対応チェック
$boardFile = "$base\task-board\main-board.md"
$projectsDir = "$base\obsidian-vault\04_projects"

if (Test-Path $boardFile) {
    $content = Get-Content $boardFile -Raw -Encoding UTF8
    # DONE タスクのIDを抽出
    $doneIds = [regex]::Matches($content, '\[x\] \*\*T(\d{4})\*\*') |
        ForEach-Object { $_.Groups[1].Value }
    Write-Log "DONE タスク: $($doneIds.Count) 件"
}

# 2. 30日以上更新がない obsidian-vault/00_inbox/ のファイル
$staleCutoff = (Get-Date).AddDays(-30)
$staleFiles = Get-ChildItem "$base\obsidian-vault\00_inbox" -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $staleCutoff -and $_.Name -ne "_template.md" }

if ($staleFiles.Count -gt 0) {
    Write-Log "30日以上未処理の inbox: $($staleFiles.Count) 件"
    foreach ($f in $staleFiles) {
        Write-Log "  - $($f.Name) (最終更新: $($f.LastWriteTime.ToString('yyyy-MM-dd')))"
    }
}

# 3. logs ディレクトリの古いものをアーカイブ提案（30日超）
$oldLogs = Get-ChildItem "$base\logs" -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $staleCutoff }
if ($oldLogs.Count -gt 0) {
    Write-Log "アーカイブ候補のログフォルダ: $($oldLogs.Count) 件"
}

Write-Log "=== nightly-qa 完了 ==="
