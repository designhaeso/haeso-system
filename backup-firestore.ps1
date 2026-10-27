# 해소 시스템 Firestore 데이터 자동 백업
# 매일 실행되어 현재 클라우드 데이터를 backups 폴더에 날짜별 JSON으로 저장한다.

$ErrorActionPreference = "Stop"

$backupDir = Join-Path $PSScriptRoot "backups"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$outFile = Join-Path $backupDir "backup_$timestamp.json"

$url = "https://firestore.googleapis.com/v1/projects/haeso-system/databases/(default)/documents/haeso/data"

try {
    Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing
    Write-Output "백업 완료: $outFile"
} catch {
    Write-Output "백업 실패: $($_.Exception.Message)"
    exit 1
}

# 오래된 백업 정리 (3일 지난 파일 삭제 — 매시간 저장되므로 최근 3일치면 충분)
Get-ChildItem -Path $backupDir -Filter "backup_*.json" |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-3) } |
    Remove-Item -Force
