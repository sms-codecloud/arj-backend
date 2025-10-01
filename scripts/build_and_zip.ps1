param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Build and package .NET Lambda into lambda.zip at repo root.
# Uses projects under /src. If multiple projects exist, selects the first .csproj found.
# Overwrites existing lambda.zip.

$RootDir = Resolve-Path (Join-Path $PSScriptRoot '..') | Select-Object -ExpandProperty Path
$SrcDir  = Join-Path $RootDir 'src'
$ZipFile = Join-Path $RootDir 'lambda.zip'

Write-Host "Root: $RootDir"
Write-Host "Source dir: $SrcDir"
Write-Host "Zip file: $ZipFile"

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error "dotnet not found in PATH."
    exit 2
}

if (-not (Test-Path $SrcDir)) {
    Write-Error "Source directory '$SrcDir' not found. Nothing to build."
    exit 3
}

# Locate a csproj under src (first match)
$csproj = Get-ChildItem -Path $SrcDir -Recurse -Filter '*.csproj' -File -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $csproj) {
    Write-Error "No .csproj found under '$SrcDir'. Ensure your project is located under /src."
    exit 4
}

$ProjectPath = $csproj.DirectoryName
Write-Host "Selected project: $($csproj.FullName)"
$PublishDir = Join-Path $ProjectPath 'bin\Release\net6.0\publish'

# Clean previous publish
if (Test-Path $PublishDir) {
    Remove-Item -Recurse -Force $PublishDir
}
New-Item -ItemType Directory -Force -Path $PublishDir | Out-Null

Write-Host "Restoring project..."
dotnet restore $csproj.FullName

Write-Host "Publishing project for linux-x64 (Lambda runtime uses linux)..."
dotnet publish $csproj.FullName -c Release -r linux-x64 --self-contained false -o $PublishDir

# Create or overwrite lambda.zip at repo root
if (Test-Path $ZipFile) {
    Write-Host "Overwriting existing zip: $ZipFile"
    Remove-Item -Force $ZipFile
}

Write-Host "Creating zip archive from published output..."
# Force array output so .Count works even when a single file is returned
$items = @(Get-ChildItem -Path $PublishDir -Recurse -File -ErrorAction SilentlyContinue)
if ($items.Count -eq 0) {
    Write-Error "Publish directory is empty: $PublishDir"
    exit 5
}

# Use Compress-Archive to put published files at root of zip
Compress-Archive -Path (Join-Path $PublishDir '*') -DestinationPath $ZipFile -Force

if (Test-Path $ZipFile) {
    $size = (Get-Item $ZipFile).Length
    Write-Host "Created $ZipFile (size: $size bytes)"
} else {
    Write-Error "Failed to create zip file."
    exit 6
}

Write-Host "Build and packaging completed."