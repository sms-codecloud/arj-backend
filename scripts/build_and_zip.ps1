Param(
  [string]$ProjectPath = "$PSScriptRoot\..\src\hello_world\hello_world.csproj",
  [string]$OutputZip   = "$PSScriptRoot\..\lambda.zip"
)

$PublishDir = Join-Path $PSScriptRoot "..\publish"
if (Test-Path $PublishDir) { Remove-Item -Recurse -Force $PublishDir }
New-Item -ItemType Directory -Path $PublishDir | Out-Null

dotnet publish $ProjectPath -c Release -o $PublishDir -r linux-x64 --self-contained $false
if ($LASTEXITCODE -ne 0) { Write-Error "dotnet publish failed with exit code $LASTEXITCODE"; exit $LASTEXITCODE }

if (Test-Path $OutputZip) { Remove-Item $OutputZip -Force }
Push-Location $PublishDir
Compress-Archive -Path * -DestinationPath $OutputZip -Force
Pop-Location

Write-Host "Created $OutputZip"
