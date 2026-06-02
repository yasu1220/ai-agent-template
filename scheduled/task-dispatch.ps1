# task-dispatch.ps1
# 1時間ごとに実行。inbox の新規メモをスキャンし、状況をログに残す。
# （実際のAI呼び出しは次フェーズで実装）

$ErrorActionPreference = "Stop"
$base = Split-Path -Parent $PSScriptRoot
$today = Get-Date -Format "yyyy-MM-dd"

$logDir = "$base/logs/$today"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = "$logDir/task-dispatch.log"

function Write-Log($msg) {
    $ts = Get-Date -Format "HH:mm:ss"
    "[$ts] $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

Write-Log "=== task-dispatch スキャン開始 ==="

# inbox の未処理メモを検出（"processed:" タグがないもの）
$inboxDir = "$base/obsidian-vault/00_inbox"
$unprocessed = @()

Get-ChildItem $inboxDir -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne "_template.md" } |
    ForEach-Object {
        $content = Get-Content $_.FullName -Raw -Encoding UTF8
        if ($content -notmatch 'processed:') {
            $unprocessed += $_.Name
        }
    }

Write-Log "未処理メモ: $($unprocessed.Count) 件"
foreach ($file in $unprocessed) {
    Write-Log "  - $file"
}

# 注意: 実際のタスク変換と main-board.md への書き込みは
# Claude Code/Cowork のCLI連携を実装してから対応する
if ($unprocessed.Count -gt 0) {
    Write-Log "TODO: AIエージェントによる自動タスク化（次フェーズで実装）"
}

Write-Log "=== task-dispatch スキャン完了 ==="
