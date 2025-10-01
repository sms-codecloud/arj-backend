param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RootDir  = Resolve-Path (Join-Path $PSScriptRoot '..') | Select-Object -ExpandProperty Path
$SrcDir   = Join-Path $RootDir 'src'
$ZipFile  = Join-Path $RootDir 'lambda.zip'

$csproj = Get-ChildItem -Path $SrcDir -Recurse -Filter *.csproj | Select-Object -First 1
if (-not $csproj) {
    Write-Error "No .csproj found under $SrcDir"
    exit 1
}
$ProjectPath = $csproj.FullName

$PublishDir  = Join-Path $env:TEMP ("lambda_publish_" + [System.Guid]::NewGuid().ToString("N"))
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $PublishDir
New-Item -ItemType Directory -Path $PublishDir | Out-Null

Write-Host "Restoring..."
dotnet restore $ProjectPath

Write-Host "Publishing for .NET 8 (linux-x64, AOT)..."
dotnet publish $ProjectPath -c Release -r linux-x64 -o $PublishDir /p:PublishAot=true /p:StripSymbols=true --self-contained false

if ($LASTEXITCODE -ne 0) {
    Write-Error "dotnet publish failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

if (Test-Path $ZipFile) { Remove-Item $ZipFile -Force }

Write-Host "Creating ZIP..."
Push-Location $PublishDir
Compress-Archive -Path * -DestinationPath $ZipFile -Force
Pop-Location

if (Test-Path $ZipFile) {
    $size = (Get-Item $ZipFile).Length
    Write-Host "Created $ZipFile (size: $size bytes)"
} else {
    Write-Error "Failed to create zip file."
    exit 6
}

Remove-Item -Recurse -Force $PublishDir
Write-Host "✅ Build and packaging completed."
