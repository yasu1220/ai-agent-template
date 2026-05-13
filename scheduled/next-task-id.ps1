# next-task-id.ps1
# task-board/main-board.md から次のタスクIDを返す。
# 使い方: $id = & .\next-task-id.ps1

$ErrorActionPreference = "Stop"
$base = "C:\Users\yasu\Documents\テスト会社\AIエージェント会社設立"
$boardFile = "$base\task-board\main-board.md"

if (-not (Test-Path $boardFile)) {
    "T0001"
    exit 0
}

$content = Get-Content $boardFile -Raw -Encoding UTF8
$matches = [regex]::Matches($content, 'T(\d{4})')

if ($matches.Count -eq 0) {
    "T0001"
} else {
    $maxId = ($matches | ForEach-Object { [int]$_.Groups[1].Value } | Measure-Object -Maximum).Maximum
    "T{0:D4}" -f ($maxId + 1)
}
