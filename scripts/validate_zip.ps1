Param([string]$ZipPath = "$PSScriptRoot\..\lambda.zip")

if (-not (Test-Path $ZipPath)) { Write-Error "Zip not found: $ZipPath"; exit 1 }

Add-Type -AssemblyName System.IO.Compression.FileSystem
$tmp = Join-Path $env:TEMP ("lz_" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $tmp)

  $dll = Get-ChildItem $tmp -Filter hello_world.dll -Recurse | Select-Object -First 1
  $deps = Get-ChildItem $tmp -Filter hello_world.deps.json -Recurse | Select-Object -First 1
  $rcfg = Get-ChildItem $tmp -Filter hello_world.runtimeconfig.json -Recurse | Select-Object -First 1

  if (-not $dll)  { Write-Error "hello_world.dll missing in zip root"; exit 2 }
  if (-not $deps) { Write-Error "hello_world.deps.json missing in zip root"; exit 3 }
  if (-not $rcfg) { Write-Error "hello_world.runtimeconfig.json missing in zip root"; exit 4 }

  # Ensure they are at ZIP ROOT (no subfolders)
  if ($dll.DirectoryName -ne $tmp -or $deps.DirectoryName -ne $tmp -or $rcfg.DirectoryName -ne $tmp) {
    Write-Error "Assemblies are inside a folder in the zip. They must be at ZIP ROOT."
    exit 5
  }

  Write-Host "ZIP OK: dll/deps/runtimeconfig present at root."
}
finally {
  Remove-Item -Recurse -Force $tmp
}
