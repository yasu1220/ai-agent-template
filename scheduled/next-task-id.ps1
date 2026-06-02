# next-task-id.ps1
# task-board/main-board.md から次のタスクIDを返す。
# 使い方: $id = & .\next-task-id.ps1

$ErrorActionPreference = "Stop"
$base = Split-Path -Parent $PSScriptRoot
$boardFile = "$base/task-board/main-board.md"

if (-not (Test-Path $boardFile)) {
    "T0001"
    exit 0
}

$content = Get-Content $boardFile -Raw -Encoding UTF8
$taskMatches = [regex]::Matches($content, 'T(\d{4})')

if ($taskMatches.Count -eq 0) {
    "T0001"
} else {
    $maxId = ($taskMatches | ForEach-Object { [int]$_.Groups[1].Value } | Measure-Object -Maximum).Maximum
    "T" + ([int]$maxId + 1).ToString().PadLeft(4, '0')
}
