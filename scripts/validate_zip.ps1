param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Validate that lambda.zip exists and contains expected published files (.dll)
$RootDir = Resolve-Path (Join-Path $PSScriptRoot '..') | Select-Object -ExpandProperty Path
$ZipPath = Join-Path $RootDir 'lambda.zip'

Write-Host "Root: $RootDir"
Write-Host "Zip path: $ZipPath"

if (-not (Test-Path $ZipPath)) {
    Write-Error "Error: $ZipPath not found."
    exit 2
}

# Use .NET ZipFile to inspect entries
Add-Type -AssemblyName System.IO.Compression.FileSystem

try {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
        $entries = $zip.Entries | ForEach-Object { $_.FullName }
    } finally {
        $zip.Dispose()
    }
} catch {
    Write-Error "Failed to read zip file: $_"
    exit 3
}

if (-not $entries -or $entries.Count -eq 0) {
    Write-Error "Zip file is empty."
    exit 4
}

Write-Host "Zip contains $($entries.Count) entries. Sample entries:"
$entries | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" }

# Ensure at least one DLL exists in the root or subfolders
$hasDll = $entries | Where-Object { $_ -match '\.dll$' }
if (-not $hasDll) {
    Write-Error "No .dll files found inside lambda.zip. Verify publish output."
    exit 5
}

Write-Host "Validation successful: lambda.zip looks valid."
exit 0