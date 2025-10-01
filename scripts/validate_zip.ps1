param(
    [string]$ZipFile = "..\\lambda.zip"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$FullPath = Resolve-Path $ZipFile -ErrorAction SilentlyContinue

if (-not $FullPath) {
    Write-Error "❌ Zip file not found: $ZipFile"
    exit 1
}

$size = (Get-Item $FullPath).Length
if ($size -le 0) {
    Write-Error "❌ Zip file is empty: $FullPath"
    exit 1
}

try {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($FullPath)
    $entries = $zip.Entries.Count
    $zip.Dispose()
    if ($entries -eq 0) {
        Write-Error "❌ Zip file contains no entries!"
        exit 1
    }
    Write-Host "✅ Zip file is valid ($entries files, size: $size bytes): $FullPath"
}
catch {
    Write-Error "❌ Failed to open zip file: $_"
    exit 1
}
