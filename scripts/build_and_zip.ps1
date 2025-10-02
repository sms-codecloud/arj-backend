# after you locate $ProjectPath

$PublishDir = Join-Path $SrcDir 'publish'
if (Test-Path $PublishDir) { Remove-Item -Recurse -Force $PublishDir }

# framework-dependent build for linux (Lambda host is linux)
dotnet publish "$ProjectPath" -c Release -o "$PublishDir" -r linux-x64 --self-contained false

if ($LASTEXITCODE -ne 0) {
    Write-Error "dotnet publish failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

# zip the published contents
$ZipFile  = Join-Path $RootDir 'lambda.zip'
if (Test-Path $ZipFile) { Remove-Item $ZipFile -Force }
Push-Location $PublishDir
Compress-Archive -Path * -DestinationPath $ZipFile -Force
Pop-Location

Write-Host "Build complete: $ZipFile"
