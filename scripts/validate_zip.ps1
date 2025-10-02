Param(
  [string]$ZipPath = "$PSScriptRoot\..\lambda.zip"
)

if (-not (Test-Path $ZipPath)) {
  Write-Error "Zip not found: $ZipPath"
  exit 1
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$tmp = Join-Path $env:TEMP ("lz_" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $tmp)
  $dll = Get-ChildItem -Path $tmp -Recurse -Filter hello_world.dll | Select-Object -First 1
  if (-not $dll) {
    Write-Error "hello_world.dll not found inside zip. Ensure publish produced correct artifacts."
    exit 2
  }
  Write-Host "Zip looks good. Found: $($dll.FullName)"
} finally {
  Remove-Item -Recurse -Force $tmp
}
