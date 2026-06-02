# morning-standup.ps1
# 毎朝 9:00 に実行。daily を生成し、main-board から優先タスクを選定して書き込む。

$ErrorActionPreference = "Stop"
$base = Split-Path -Parent $PSScriptRoot
$today = "2026-06-12"

$logDir = "$base\logs\$today"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = "$logDir\morning-standup.log"

function Write-Log($msg) {
    $ts = Get-Date -Format "HH:mm:ss"
    "[$ts] $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
    Write-Host "[$ts] $msg"
}

Write-Log "=== morning-standup 開始 ==="

# 1. 日曜のみ GitHub から最新を取得（週次エージェントの strategy-review を受け取る）
if (([DateTime]"2026-06-12").DayOfWeek -eq 'Sunday') {
    try {
        $gitResult = & git -C $base pull
        Write-Log "git pull: $gitResult"
    } catch {
        Write-Log "git pull スキップ（認証エラーの可能性）"
    }
}

# 2. 当月の progress-tracking が未作成なら生成（月初に自動作成）
$yearMonth = "2026-06"
$progressFile = "$base\obsidian-vault\05_strategy\progress-tracking-$yearMonth.md"
if (-not (Test-Path $progressFile)) {
    $monthLabel = ([DateTime]"2026-06-12").Year.ToString() + "年" + ([DateTime]"2026-06-12").Month.ToString() + "月"
    $daysInMonth = [DateTime]::DaysInMonth(([DateTime]"2026-06-12").Year, ([DateTime]"2026-06-12").Month)

    # 現在フェーズを月番号から自動判定
    $monthNum = ([DateTime]"2026-06-12").Month
    $phaseText = switch ($monthNum) {
        { $_ -in 5, 6, 7 } { "フェーズ1 仕込み期（5〜7月）" }
        { $_ -in 8, 9 }    { "フェーズ2 バズ期（8〜9月）" }
        { $_ -in 10, 11 }  { "フェーズ3 仕組み化（10〜11月）" }
        default             { "フェーズ4 ビジネスアイドル期（12月〜）" }
    }

    # okr-2026.md から当月の目標値を取得
    $okrFile = "$base\obsidian-vault\05_strategy\okr-2026.md"
    $targetRevenue  = "（okr-2026.md を確認）"
    $targetCorp     = "（okr-2026.md を確認）"
    $targetPersonal = "（okr-2026.md を確認）"
    $targetIG       = "（okr-2026.md を確認）"

    if (Test-Path $okrFile) {
        $okrContent = Get-Content $okrFile -Raw -Encoding UTF8
        $rowMatch = [regex]::Match($okrContent,
            "\| ${monthNum}月 \| [^|]+ \| ([^|]+) \| ([^|]+) \| ([^|]+) \| ([^|]+) \|")
        if ($rowMatch.Success) {
            $targetRevenue  = $rowMatch.Groups[1].Value.Trim()
            $targetCorp     = $rowMatch.Groups[2].Value.Trim()
            $targetPersonal = $rowMatch.Groups[3].Value.Trim()
            $targetIG       = $rowMatch.Groups[4].Value.Trim()
            Write-Log "okr-2026.md から ${monthNum}月の目標値を取得しました"
        } else {
            Write-Log "okr-2026.md に${monthNum}月のデータなし（プレースホルダーを使用）"
        }
    } else {
        Write-Log "okr-2026.md が見つかりません（プレースホルダーを使用）"
    }

    $progressContent = @"
# 進捗トラッキング $monthLabel

> 毎週土〜日曜に「今月累計」列を更新する。月が変わったら新しいファイルが自動生成される。

---

## 最終更新: $today（月初）

## 現在フェーズ: $phaseText

---

## $monthLabel の進捗

| 指標 | 月目標 | 今月累計 |
|---|---|---|
| 月商 | $targetRevenue | 0万円 |
| 法人案件 | $targetCorp | 0件 |
| 個人案件 | $targetPersonal | 0人 |
| IGフォロワー | $targetIG | 0人 |
| コンテンツ発信 | — | 0本 |

---

## 週次メモ（任意・何があったか一言）

- W1（1〜7日）:
- W2（8〜14日）:
- W3（15〜21日）:
- W4（22〜${daysInMonth}日）:

---

## 更新方法

1. 毎週土〜日曜に「今月累計」列の数値を書き換える
2. 「最終更新」の日付と週次メモも更新する
"@
    $utf8Bom = [System.Text.UTF8Encoding]::new($true)
    [System.IO.File]::WriteAllText($progressFile, $progressContent, $utf8Bom)
    Write-Log "progress-tracking-$yearMonth.md を新規生成しました"
} else {
    Write-Log "progress-tracking-$yearMonth.md は既に存在します（スキップ）"
}

# 2.5. daily が未作成なら _template.md からコピー
$dailyFile = "$base\daily\$today.md"
if (-not (Test-Path $dailyFile)) {
    $template = "$base\daily\_template.md"
    if (Test-Path $template) {
        Copy-Item $template $dailyFile
        (Get-Content $dailyFile -Raw -Encoding UTF8) -replace 'YYYY-MM-DD', $today |
            Set-Content $dailyFile -Encoding UTF8
        Write-Log "daily/$today.md を生成しました"
    }
} else {
    Write-Log "daily/$today.md は既に存在します（スキップ）"
}

# 3. main-board の [x] タスクを DONE セクションに移動
$boardFile = "$base\task-board\main-board.md"

if (Test-Path $boardFile) {
    $raw = Get-Content $boardFile -Raw -Encoding UTF8
    $lines = $raw -split "\r?\n"
    $currentSection = ""
    $movedLines = @()
    $outputLines = @()
    $doneHeaderIdx = -1

    foreach ($line in $lines) {
        if ($line -match "^## ") { $currentSection = $line }

        if ($currentSection -notmatch "✅ DONE" -and $line -match "^- \[x\].*\^t\d{4}") {
            $doneLine = $line
            if ($doneLine -notmatch "✅\d{4}-\d{2}-\d{2}") {
                $doneLine = $doneLine -replace "^(- \[x\] [^#^]+?)\s+(#|\^)", "`$1 ✅$today `$2"
            }
            $movedLines += $doneLine
        } else {
            if ($line -match "^## ✅ DONE") { $doneHeaderIdx = $outputLines.Count }
            $outputLines += $line
        }
    }

    if ($movedLines.Count -gt 0 -and $doneHeaderIdx -ge 0) {
        $before = $outputLines[0..$doneHeaderIdx]
        $insertIdx = $doneHeaderIdx + 1
        $after = if ($insertIdx -lt $outputLines.Count) { $outputLines[$insertIdx..($outputLines.Count - 1)] } else { @() }
        $newContent = ($before + @("") + $movedLines + $after) -join "`n"
        $utf8Bom = [System.Text.UTF8Encoding]::new($true)
        [System.IO.File]::WriteAllText($boardFile, $newContent, $utf8Bom)
        $movedAnchors = $movedLines | ForEach-Object { if ($_ -match '\^(t\d{4})') { $Matches[1] } }
        Write-Log "DONEに移動: $($movedLines.Count) 件 ($($movedAnchors -join ', '))"
    } else {
        Write-Log "移動対象の完了タスクなし"
    }
}

# 4. main-board.md からタスクを優先順に選定
$boardContent = ""
$selectedAnchors = @()
$p0Count = 0
$p1Count = 0

if (Test-Path $boardFile) {
    $boardContent = Get-Content $boardFile -Raw -Encoding UTF8
    $p0Count = ([regex]::Matches($boardContent, '#P0')).Count
    $p1Count = ([regex]::Matches($boardContent, '#P1')).Count

    function Get-Section($content, $header) {
        $m = [regex]::Match($content, "(?s)## $header.*?(?=\n## |\z)")
        if ($m.Success) { $m.Value } else { "" }
    }

    function Get-Anchors($sectionContent, $priority) {
        [regex]::Matches($sectionContent, "- \[ \] .+$priority.+\^(t\d{4})") |
            ForEach-Object { $_.Groups[1].Value }
    }

    $inProgress = Get-Section $boardContent "🔄 IN PROGRESS"
    $newTasks   = Get-Section $boardContent "📥 NEW / UNASSIGNED"

    $selectedAnchors += Get-Anchors $inProgress "#P0"
    $selectedAnchors += Get-Anchors $inProgress "#P1"
    $selectedAnchors += Get-Anchors $newTasks   "#P0"
    $selectedAnchors += Get-Anchors $newTasks   "#P1"

    # 最大3件に絞る（優先度順で先頭3件）
    $selectedAnchors = $selectedAnchors | Select-Object -First 3

    Write-Log "選定タスク: $($selectedAnchors.Count) 件 ($($selectedAnchors -join ', '))"
} else {
    Write-Log "main-board.md が見つかりません"
}

# 5. daily の「今日やること」セクションにタスクを書き込む
if (Test-Path $dailyFile) {
    $dailyContent = Get-Content $dailyFile -Raw -Encoding UTF8

    # 土曜のみ：progress-tracking 更新リマインダーを「今日やること」の先頭に追加
    $saturdayPrefix = ""
    if (([DateTime]"2026-06-12").DayOfWeek -eq 'Saturday') {
        $yearMonth = "2026-06"
        $progressFileName = "progress-tracking-$yearMonth.md"
        $saturdayPrefix = @"
### 📊 今週の実績を記録する（最優先）

``obsidian-vault/05_strategy/$progressFileName`` を開いて「今月累計」を更新してください。

| 指標 | 更新する値 |
|---|---|
| 月商 | 今月の売上合計（万円） |
| 法人案件 | 今月の受注件数 |
| 個人案件 | 今月の参加人数 |
| IGフォロワー | 現在のフォロワー数 |
| コンテンツ発信 | 今月の投稿本数 |

> 💡 この数字が明朝（日曜8:00）のリモートエージェントに読まれ、来週の目標計算に使われます。

### 📋 main-boardタスク

"@
        Write-Log "土曜：progress-tracking 更新リマインダーを「今日やること」に追加しました"
    }

    # 日曜のみ：戦略セッション手順を「今日やること」の先頭に追加
    $sundayPrefix = ""
    if (([DateTime]"2026-06-12").DayOfWeek -eq 'Sunday') {
        $strategyReviewFile = Get-ChildItem "$base\obsidian-vault\00_inbox" -Filter "strategy-review-*.md" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $reviewNote = if ($strategyReviewFile) {
            "> 📄 今週の戦略レビューファイル: ``$($strategyReviewFile.Name)`` が届いています。"
        } else {
            "> ⚠️ strategy-review ファイルが見つかりません。リモートエージェントの実行を確認してください。"
        }
        $sundayPrefix = @"
### 🗓️ 日曜戦略セッション（最優先）⏱️ 15〜30分

$reviewNote

**手順（順番通りに）：**

1. Claude Code を起動する
2. チャットに **「日曜戦略セッションを開始して」** と入力する
3. strategy-review の内容が提示される → 「OK」か「この点を変えて」と伝える
4. OKR変更あり→ 「OK」でClaudeが更新 / OKR変更なし → 自動スキップ
5. task-proposals.md が生成されてチャットで提示される → 「OK」か修正を伝える（ファイルも随時更新）
6. 「OK」で main-board に自動追加される

> 💡 ファイルは自分で触らなくていい。「OK」か修正を言うだけ。

### 📋 main-boardタスク

"@
        Write-Log "日曜：戦略セッション手順を「今日やること」に追加しました"
    }

    $dayPrefix = $saturdayPrefix + $sundayPrefix
    if ($selectedAnchors.Count -gt 0) {
        $transcludeLines = ($selectedAnchors | ForEach-Object { "![[task-board/main-board#^$_]]" }) -join "`r`n"
        $replacement = $dayPrefix + $transcludeLines
        $dailyContent = $dailyContent -replace [regex]::Escape("<!-- main-board から選定。件数は問わない。形式: ![[task-board/main-board#^tXXXX]] -->"), $replacement
        Write-Log "タスクをdailyに書き込みました"
    } else {
        $noTask = if ($dayPrefix) { $dayPrefix + "（main-boardに着手タスクなし）" } else { "今日は予定なし" }
        $dailyContent = $dailyContent -replace [regex]::Escape("<!-- main-board から選定。件数は問わない。形式: ![[task-board/main-board#^tXXXX]] -->"), $noTask
        Write-Log "選定タスクなし"
    }

    [System.IO.File]::WriteAllText($dailyFile, $dailyContent, [System.Text.Encoding]::UTF8)
}

# 6. inbox の未処理件数をカウント
$inboxDir = "$base\obsidian-vault\00_inbox"
$inboxCount = (Get-ChildItem $inboxDir -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne "_template.md" }).Count
Write-Log "未処理 inbox: $inboxCount 件"

# 7. サマリを daily に追記
$summary = @"

---

## 📊 morning-standup 実行結果 ($(Get-Date -Format "HH:mm"))

- **未処理inbox**: $inboxCount 件
- **P0タスク**: $p0Count 件 / **P1タスク**: $p1Count 件

"@
if (Test-Path $dailyFile) {
    Add-Content -Path $dailyFile -Value $summary -Encoding UTF8
}

# 9. GitHub に自動 push（毎日）
# ※ 2>$null は $ErrorActionPreference=Stop と競合するため使用しない
try {
    & git -C $base add -A
    & git -C $base commit -m "auto: morning-standup $today"
    & git -C $base push
    Write-Log "git push: 完了"
} catch {
    Write-Log "git push: スキップ（変更なし or 認証エラー）"
}

Write-Log "=== morning-standup 完了 ==="
Write-Host "`n今日のdaily: $dailyFile"
