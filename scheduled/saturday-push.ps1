# saturday-push.ps1
# 毎週土曜 22:00 に実行。progress-tracking の更新を GitHub に push する。

$ErrorActionPreference = "SilentlyContinue"
$base = Split-Path -Parent $PSScriptRoot
$today = Get-Date -Format "yyyy-MM-dd"

$logDir = "$base/logs/$today"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = "$logDir/saturday-push.log"

function Write-Log($msg) {
    $ts = Get-Date -Format "HH:mm:ss"
    "[$ts] $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
    Write-Host "[$ts] $msg"
}

Write-Log "=== saturday-push 開始 ==="

try {
    & git -C $base add -A
    & git -C $base commit -m "auto: saturday-push $today (progress-tracking update)"
    & git -C $base push
    Write-Log "git push: 完了（progress-tracking の更新を反映）"
} catch {
    Write-Log "git push: スキップ（変更なし or 認証エラー）"
}

Write-Log "=== saturday-push 完了 ==="