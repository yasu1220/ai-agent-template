# _run-all-tests.ps1
# Full 1-week simulation test for これもテスト directory.
# Dates: 2026-06-07 (Sun) through 2026-06-14 (next Sun)

$ErrorActionPreference = "SilentlyContinue"
$base = Split-Path -Parent $PSScriptRoot
$standupScript = Join-Path $PSScriptRoot "morning-standup.ps1"
$satPushScript = Join-Path $PSScriptRoot "saturday-push.ps1"
$pass = 0; $fail = 0

function Write-Section($title) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
}

function Check($label, $condition) {
    if ($condition) {
        Write-Host "  [PASS] $label" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "  [FAIL] $label" -ForegroundColor Red
        $script:fail++
    }
}

function Run-Standup($dateStr) {
    $src = Get-Content $standupScript -Raw -Encoding UTF8
    $ym  = $dateStr.Substring(0, 7)

    $patched = $src `
        -replace 'Get-Date -Format "yyyy-MM-dd"',  "`"$dateStr`"" `
        -replace 'Get-Date -Format "yyyy-MM"',      "`"$ym`"" `
        -replace '\(Get-Date\)\.DayOfWeek',  "([DateTime]`"$dateStr`").DayOfWeek" `
        -replace '\(Get-Date\)\.Year',       "([DateTime]`"$dateStr`").Year" `
        -replace '\(Get-Date\)\.Month',      "([DateTime]`"$dateStr`").Month"

    $tmp = Join-Path $PSScriptRoot "_temp-standup.ps1"
    $utf8bom = [System.Text.UTF8Encoding]::new($true)
    [System.IO.File]::WriteAllText($tmp, $patched, $utf8bom)
    & $tmp 2>&1 | Out-Null
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}

# ===========================================================================
# TEST 0: 日曜 8:00 — strategy-review をinboxに生成（リモートエージェント模擬）
# ===========================================================================
Write-Section "TEST 0: 日曜8:00 - strategy-review 生成 (2026-06-07)"

$reviewFile = "$base\obsidian-vault\00_inbox\strategy-review-2026-06-07.md"
$reviewContent = @"
# strategy-review -- 2026-06-07

## 今週の振り返り

### 進捗
- T0003 AIエージェント構成の設計ドキュメントを書く: 50%進捗
- T0004 Obsidian vaultのコンテキストファイルを記入する: 作業中

### 良かったこと
- Claude Code の活用に慣れてきた

### 改善点
- 法人向けアプローチをまだ開始できていない

## 戦略修正案

修正不要。現在のフォーカスを継続する。

## 来週の定量目標

| 指標 | 目標 |
|---|---|
| 月商 | 20万円 |
| 法人案件 | 1社アプローチ |
| 個人案件 | 2人 |
"@
$utf8bom = [System.Text.UTF8Encoding]::new($true)
[System.IO.File]::WriteAllText($reviewFile, $reviewContent, $utf8bom)
Check "strategy-review-2026-06-07.md がinboxに生成された" (Test-Path $reviewFile)

# ===========================================================================
# TEST 1: 日曜 9:00 — morning-standup（日曜モード）
# ===========================================================================
Write-Section "TEST 1: 日曜9:00 - morning-standup (2026-06-07 Sunday)"

Run-Standup "2026-06-07"
$daily = "$base\daily\2026-06-07.md"
Check "daily/2026-06-07.md が生成された" (Test-Path $daily)
if (Test-Path $daily) {
    $dc = Get-Content $daily -Raw -Encoding UTF8
    Check "今日やることに「日曜戦略セッション」が含まれる"   ($dc -match "日曜戦略セッション")
    Check "strategy-reviewファイル名が記載されている"        ($dc -match "strategy-review-2026-06-07")
    Check "main-boardのタスクが含まれる"                    ($dc -match "main-board#\^t")
    Check "morning-standupサマリーが追記された"             ($dc -match "morning-standup 実行結果")
}
$ptFile = "$base\obsidian-vault\05_strategy\progress-tracking-2026-06.md"
Check "progress-tracking-2026-06.md が生成された" (Test-Path $ptFile)
if (Test-Path $ptFile) {
    $ptc = Get-Content $ptFile -Raw -Encoding UTF8
    Check "OKRから月商目標が自動入力されている" ($ptc -match "40万円")
    Check "フェーズ名が自動判定されている"       ($ptc -match "フェーズ1")
}

# ===========================================================================
# TEST 2: 月曜 9:00
# ===========================================================================
Write-Section "TEST 2: 月曜9:00 - morning-standup (2026-06-08 Monday)"

Run-Standup "2026-06-08"
$daily = "$base\daily\2026-06-08.md"
Check "daily/2026-06-08.md が生成された" (Test-Path $daily)
if (Test-Path $daily) {
    $dc = Get-Content $daily -Raw -Encoding UTF8
    Check "日曜・土曜セクションが含まれない" (-not ($dc -match "日曜戦略セッション|progress-tracking 更新"))
    Check "main-boardのタスクが含まれる"     ($dc -match "main-board#\^t")
    Check "morning-standupサマリーが追記"    ($dc -match "morning-standup 実行結果")
}

# ===========================================================================
# TEST 3: 火曜 9:00
# ===========================================================================
Write-Section "TEST 3: 火曜9:00 - morning-standup (2026-06-09 Tuesday)"

Run-Standup "2026-06-09"
$daily = "$base\daily\2026-06-09.md"
Check "daily/2026-06-09.md が生成された" (Test-Path $daily)
if (Test-Path $daily) {
    $dc = Get-Content $daily -Raw -Encoding UTF8
    Check "通常モード（特別セクションなし）" (-not ($dc -match "日曜戦略セッション|progress-tracking 更新"))
    Check "morning-standupサマリーが追記"    ($dc -match "morning-standup 実行結果")
}

# ===========================================================================
# TEST 4: 水曜 9:00
# ===========================================================================
Write-Section "TEST 4: 水曜9:00 - morning-standup (2026-06-10 Wednesday)"

Run-Standup "2026-06-10"
Check "daily/2026-06-10.md が生成された" (Test-Path "$base\daily\2026-06-10.md")

# ===========================================================================
# TEST 5: 木曜 9:00
# ===========================================================================
Write-Section "TEST 5: 木曜9:00 - morning-standup (2026-06-11 Thursday)"

Run-Standup "2026-06-11"
Check "daily/2026-06-11.md が生成された" (Test-Path "$base\daily\2026-06-11.md")

# ===========================================================================
# TEST 6: 金曜 9:00
# ===========================================================================
Write-Section "TEST 6: 金曜9:00 - morning-standup (2026-06-12 Friday)"

Run-Standup "2026-06-12"
Check "daily/2026-06-12.md が生成された" (Test-Path "$base\daily\2026-06-12.md")

# ===========================================================================
# TEST 7: 土曜 9:00
# ===========================================================================
Write-Section "TEST 7: 土曜9:00 - morning-standup (2026-06-13 Saturday)"

Run-Standup "2026-06-13"
$daily = "$base\daily\2026-06-13.md"
Check "daily/2026-06-13.md が生成された" (Test-Path $daily)
if (Test-Path $daily) {
    $dc = Get-Content $daily -Raw -Encoding UTF8
    Check "今日やることに「progress-tracking 更新」が含まれる" ($dc -match "progress-tracking")
    Check "更新テーブルが含まれる"                            ($dc -match "月商.*更新する値")
    Check "main-boardタスクが含まれる"                        ($dc -match "main-board#\^t")
    Check "morning-standupサマリーが追記"                     ($dc -match "morning-standup 実行結果")
}

# ===========================================================================
# TEST 8: 土曜 22:00 — saturday-push
# ===========================================================================
Write-Section "TEST 8: 土曜22:00 - saturday-push"

$logDir = "$base\logs\2026-06-13"
New-Item -ItemType Directory -Force $logDir | Out-Null
& $satPushScript 2>&1 | Out-Null
$logFile = "$logDir\saturday-push.log"
Check "saturday-push.log が生成された" (Test-Path $logFile)
if (Test-Path $logFile) {
    $lc = Get-Content $logFile -Raw -Encoding UTF8
    Check "saturday-push 開始/完了ログが記録された" ($lc -match "saturday-push 開始" -and $lc -match "saturday-push 完了")
}

# ===========================================================================
# TEST 9: 翌日曜 8:00 — 次週の strategy-review 生成
# ===========================================================================
Write-Section "TEST 9: 翌日曜8:00 - 次週 strategy-review 生成 (2026-06-14)"

$reviewFile2 = "$base\obsidian-vault\00_inbox\strategy-review-2026-06-14.md"
$reviewContent2 = @"
# strategy-review -- 2026-06-14

## 今週の振り返り

### 進捗
- T0003: 完了
- T0004: 完了

### 良かったこと
- 1週間通してdailyを使いこなせた

### 改善点
- 法人アプローチをそろそろ開始する

## 戦略修正案

修正不要。

## 来週の定量目標

| 指標 | 目標 |
|---|---|
| 月商 | 30万円 |
| 法人案件 | 1社クロージング |
| 個人案件 | 3人 |
"@
[System.IO.File]::WriteAllText($reviewFile2, $reviewContent2, $utf8bom)
Check "strategy-review-2026-06-14.md がinboxに生成された" (Test-Path $reviewFile2)

# ===========================================================================
# SUMMARY
# ===========================================================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "  TEST SUMMARY" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "  PASS: $pass" -ForegroundColor Green
Write-Host "  FAIL: $fail" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Red" })
Write-Host ""
if ($fail -eq 0) {
    Write-Host "  All tests passed!" -ForegroundColor Green
} else {
    Write-Host "  $fail test(s) failed. Check output above." -ForegroundColor Red
}