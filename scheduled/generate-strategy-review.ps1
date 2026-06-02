# generate-strategy-review.ps1
# 毎週日曜 08:00 に実行。
# progress-tracking + OKR + main-board を読み込み、
# claude --print (非インタラクティブ) で戦略レビューを生成して
# obsidian-vault/00_inbox/strategy-review-YYYY-MM-DD.md に保存する。
#
# 対応OS: Windows (PS 5.1+) / macOS / Linux (pwsh 7+)

$ErrorActionPreference = "Stop"
$base  = Split-Path -Parent $PSScriptRoot
$today = Get-Date -Format "yyyy-MM-dd"

# ---- ログ設定 -------------------------------------------------------
$logDir  = "$base/logs/$today"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = "$logDir/generate-strategy-review.log"

function Write-Log($msg) {
    $ts = Get-Date -Format "HH:mm:ss"
    "[$ts] $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
    Write-Host "[$ts] $msg"
}

Write-Log "=== generate-strategy-review 開始 ==="

# ---- 出力先ファイル --------------------------------------------------
$inboxDir = "$base/obsidian-vault/00_inbox"
$outFile  = "$inboxDir/strategy-review-$today.md"

if (Test-Path $outFile) {
    Write-Log "strategy-review-$today.md は既に存在します（スキップ）"
    exit 0
}

# ---- 入力ファイルを読み込む -----------------------------------------
$yearMonth     = Get-Date -Format "yyyy-MM"
$prevYearMonth = (Get-Date).AddMonths(-1).ToString("yyyy-MM")
$progressFile  = "$base/obsidian-vault/05_strategy/progress-tracking-$yearMonth.md"
$prevPF        = "$base/obsidian-vault/05_strategy/progress-tracking-$prevYearMonth.md"
$okrFile       = "$base/obsidian-vault/05_strategy/okr-2026.md"
$boardFile     = "$base/task-board/main-board.md"

# progress-tracking: 当月 → 前月 の順で探す
if (Test-Path $progressFile) {
    $progressContent = Get-Content $progressFile -Raw -Encoding UTF8
    $progressLabel   = "progress-tracking-$yearMonth.md（今月）"
    Write-Log "progress-tracking: 今月ファイルを使用"
} elseif (Test-Path $prevPF) {
    $progressContent = Get-Content $prevPF -Raw -Encoding UTF8
    $progressLabel   = "progress-tracking-$prevYearMonth.md（前月・今月未作成）"
    Write-Log "progress-tracking: 前月ファイルを使用（今月ファイル未作成）"
} else {
    $progressContent = "（progress-tracking ファイルが見つかりません）"
    $progressLabel   = "（データなし）"
    Write-Log "WARNING: progress-tracking ファイルなし"
}

$okrContent = if (Test-Path $okrFile) {
    Get-Content $okrFile -Raw -Encoding UTF8
} else {
    "（okr-2026.md が見つかりません）"
}
Write-Log "OKR: $(if (Test-Path $okrFile) { '読込済' } else { 'ファイルなし' })"

$boardContent = if (Test-Path $boardFile) {
    Get-Content $boardFile -Raw -Encoding UTF8
} else {
    "（main-board.md が見つかりません）"
}
Write-Log "main-board: $(if (Test-Path $boardFile) { '読込済' } else { 'ファイルなし' })"

# ---- 日付計算 --------------------------------------------------------
$lastWeekStart = (Get-Date).AddDays(-7).ToString("MM/dd")
$lastWeekEnd   = (Get-Date).AddDays(-1).ToString("MM/dd")
$nextWeekStart = (Get-Date).ToString("MM/dd")
$nextWeekEnd   = (Get-Date).AddDays(6).ToString("MM/dd")

# ---- プロンプト構築 --------------------------------------------------
$prompt = @"
# システム指示（最優先）
このプロンプトはPowerShellスクリプトによる完全自動実行です。
CLAUDE.md の FIRST ACTION は実行しないでください。
ファイルの読み書きツールは使用しないでください。
出力は「# 戦略レビュー」から始まる Markdown のみ出力してください。
前置き・説明・コードブロック記号（``````）は不要です。

---

# 戦略レビュー生成依頼

あなたはビジネス戦略アドバイザーです。
以下のデータを分析し、$today（日曜日）付けの週次戦略レビューを生成してください。

---

## 入力データ1: $progressLabel

$progressContent

---

## 入力データ2: okr-2026.md（年次OKR・月次目標）

$okrContent

---

## 入力データ3: main-board.md（現在のタスク状況）

$boardContent

---

# 出力フォーマット（以下の構造を厳密に守って出力してください）

# 戦略レビュー $today

## 今週の振り返り（${lastWeekStart}〜${lastWeekEnd}）

### 完了タスク
main-board.md の ✅ DONE セクションから今週完了したタスクを列挙する。
なければ「なし」と書く。

### 未完了・継続中
IN PROGRESS と NEW のタスクのうち、今週動きがあったものまたは重要なものを列挙する。

### 所見
進捗全体を見て、フェーズ目標に対する位置づけを3〜5行で述べる。

---

## 戦略修正案（変更が必要な部分のみ）

okr-2026.md の戦略と現在の進捗を比較して、修正が必要な点を記述する。
修正不要なら「現時点で修正不要」と書いた上で補足コメントを添える。

---

## 来週の定量目標（${nextWeekStart}〜${nextWeekEnd}）

| 指標 | 来週の目標 | 計算根拠 |
|---|---|---|
| 月商 | （値） | （月目標÷残週数・現状加味） |
| 法人案件 | （内容） | （根拠） |
| 個人案件 | （内容） | （根拠） |
| IGフォロワー | （増加数） | （根拠） |
| コンテンツ発信 | （本数） | （根拠） |
"@

# ---- claude コマンドを検出 -------------------------------------------
# PATH にある場合はそれを優先（スケジュールタスクでは PATH が限られる場合あり）
$claudeCmd = $null

$_claudeInfo = Get-Command claude -ErrorAction SilentlyContinue
if ($_claudeInfo) { $claudeCmd = $_claudeInfo.Source }

if (-not $claudeCmd) {
    # Windows / Mac / Linux それぞれの既知パスを探す
    $claudeCandidates = @(
        # Windows (npm global / nvm4w / installer)
        "$env:APPDATA/npm/claude.cmd",
        "$env:APPDATA/npm/claude",
        "$env:LOCALAPPDATA/Programs/claude/claude.exe",
        # Mac / Linux (npm global / homebrew)
        "/usr/local/bin/claude",
        "/opt/homebrew/bin/claude",
        "$env:HOME/.local/bin/claude"
    )
    foreach ($c in $claudeCandidates) {
        if ($c -and (Test-Path $c -ErrorAction SilentlyContinue)) {
            $claudeCmd = $c
            break
        }
    }
}
if (-not $claudeCmd) { $claudeCmd = "claude" }  # 最終フォールバック
Write-Log "claude コマンド: $claudeCmd"

# ---- プロンプトを一時ファイルに書き出し、TEMP から claude を実行 -------
# GetTempPath() から実行することで CLAUDE.md が読み込まれるのを防ぐ
$tempDir  = [System.IO.Path]::GetTempPath()
$tempFile = [System.IO.Path]::Combine($tempDir, "strategy-review-prompt-$today.txt")
try {
    [System.IO.File]::WriteAllText($tempFile, $prompt, [System.Text.Encoding]::UTF8)

    Write-Log "claude --print 実行中（数分かかる場合があります）..."

    # Claude の出力を UTF-8 として受け取るために OutputEncoding を一時変更
    $prevEncoding = [Console]::OutputEncoding
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    Push-Location $tempDir
    try {
        $rawLines = Get-Content $tempFile -Raw | & $claudeCmd --print
    } finally {
        Pop-Location
        [Console]::OutputEncoding = $prevEncoding
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Log "ERROR: claude 終了コード $LASTEXITCODE"
        exit 1
    }

    # $rawLines は行の配列になる場合があるので文字列に統合
    $rawOutput = if ($rawLines -is [array]) { $rawLines -join "`n" } else { [string]$rawLines }
    Write-Log "claude 実行完了（出力: $($rawOutput.Length) 文字）"

} catch {
    Write-Log "ERROR: claude 実行例外: $_"
    exit 1
} finally {
    Remove-Item $tempFile -ErrorAction SilentlyContinue
}

# ---- 出力から戦略レビュー部分を抽出 ---------------------------------
# FIRST ACTION が余分な出力を出した場合に備えて
# マーカー行 "*このファイルは" から始まる行以降を抽出する
$outputLines = $rawOutput -split "(?:\r?\n)"
$startIdx    = -1

for ($i = 0; $i -lt $outputLines.Count; $i++) {
    if ($outputLines[$i].Trim().StartsWith("*このファイルはClaudeとのチャットで")) {
        $startIdx = $i
        break
    }
}

# マーカー未検出 → "# 戦略レビュー" を探す
if ($startIdx -lt 0) {
    Write-Log "NOTE: マーカー行未検出。'# 戦略レビュー' を検索します"
    for ($i = 0; $i -lt $outputLines.Count; $i++) {
        if ($outputLines[$i].Trim() -match "^# 戦略レビュー") {
            $startIdx = $i
            break
        }
    }
}

$finalOutput = if ($startIdx -ge 0) {
    ($outputLines[$startIdx..($outputLines.Count - 1)]) -join "`n"
} else {
    Write-Log "WARNING: 開始位置を特定できません。出力全体を保存します"
    $rawOutput
}

# ---- ファイルに保存 --------------------------------------------------
$utf8Bom = [System.Text.UTF8Encoding]::new($true)
[System.IO.File]::WriteAllText($outFile, $finalOutput, $utf8Bom)
Write-Log "保存完了: $outFile"
Write-Log "=== generate-strategy-review 完了 ==="
