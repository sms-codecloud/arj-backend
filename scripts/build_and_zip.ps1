param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RootDir  = Resolve-Path (Join-Path $PSScriptRoot '..') | Select-Object -ExpandProperty Path
$SrcDir   = Join-Path $RootDir 'src'
$ZipFile  = Join-Path $RootDir 'lambda.zip'

$csproj = Get-ChildItem -Path $SrcDir -Recurse -Filter *.csproj | Select-Object -First 1
$ProjectPath = $csproj.FullName
$PublishDir  = Join-Path $env:TEMP ("lambda_publish_" + [System.Guid]::NewGuid().ToString("N"))

dotnet restore $ProjectPath
dotnet publish $ProjectPath -c Release -r linux-x64 -o $PublishDir /p:PublishAot=true /p:StripSymbols=true

if (Test-Path $ZipFile) { Remove-Item $ZipFile -Force }
Compress-Archive -Path (Join-Path $PublishDir '*') -DestinationPath $ZipFile -Force
Remove-Item -Recurse -Force $PublishDir

Write-Host "Build complete: $ZipFile"
