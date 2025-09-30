param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Paths
$RootDir = Resolve-Path (Join-Path $PSScriptRoot '..') | Select-Object -ExpandProperty Path
$ProjectDir = Join-Path $RootDir 'src\HelloWorld'
$PublishDir = Join-Path $ProjectDir 'bin\Release\net6.0\publish'
$ZipFile = Join-Path $RootDir 'lambda.zip'

Write-Host "Root: $RootDir"
Write-Host "Project: $ProjectDir"
Write-Host "Publish dir: $PublishDir"
Write-Host "Zip file: $ZipFile"

# Validate tooling
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error "dotnet not found in PATH."
    exit 2
}
# Compress-Archive is built-in on modern Windows PowerShell. No external zip required.

# Clean previous publish
if (Test-Path $PublishDir) {
    Remove-Item -Recurse -Force $PublishDir
}
New-Item -ItemType Directory -Force -Path $PublishDir | Out-Null

Write-Host "Restoring project..."
dotnet restore $ProjectDir

Write-Host "Publishing project for linux-x64 (Lambda runtime uses linux)..."
dotnet publish $ProjectDir -c Release -r linux-x64 --self-contained false -o $PublishDir

# Create (or overwrite) zip at repo root
if (Test-Path $ZipFile) {
    Write-Host "Overwriting existing zip: $ZipFile"
    Remove-Item -Force $ZipFile
}

Write-Host "Creating zip archive..."
# Compress contents so that published assembly files are at root of zip
$items = Get-ChildItem -Path $PublishDir -Recurse
if ($items.Count -eq 0) {
    Write-Error "Publish directory is empty. Nothing to zip."
    exit 4
}
# Use Compress-Archive with wildcard to avoid adding top-level folder
Compress-Archive -Path (Join-Path $PublishDir '*') -DestinationPath $ZipFile -Force

if (Test-Path $ZipFile) {
    $size = (Get-Item $ZipFile).Length
    Write-Host "Created $ZipFile (size: $size bytes)"
} else {
    Write-Error "Error: zip file was not created."
    exit 5
}

Write-Host "Build and packaging completed."