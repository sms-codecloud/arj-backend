param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Paths
$RootDir = Resolve-Path (Join-Path $PSScriptRoot '..') | Select-Object -ExpandProperty Path
$ZipPath = Join-Path $RootDir 'lambda.zip'
$TFDir = Join-Path $RootDir 'terraform'

Write-Host "Root: $RootDir"
Write-Host "Terraform dir: $TFDir"
Write-Host "Zip path: $ZipPath"

if (-not (Test-Path $ZipPath)) {
    Write-Error "Error: $ZipPath not found. Ensure build stage produced lambda.zip."
    exit 2
}

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error "Error: terraform not found in PATH."
    exit 3
}

# Ensure AWS credentials are present (Jenkins should inject them)
if (-not $env:AWS_ACCESS_KEY_ID) {
    Write-Error "AWS_ACCESS_KEY_ID is required (inject from Jenkins credentials)."
    exit 4
}
if (-not $env:AWS_SECRET_ACCESS_KEY) {
    Write-Error "AWS_SECRET_ACCESS_KEY is required (inject from Jenkins credentials)."
    exit 5
}

$AwsRegion = if ($env:AWS_REGION) { $env:AWS_REGION } else { 'ap-south-1' }
Write-Host "Using AWS region: $AwsRegion"

# Terraform commands will inherit environment variables in PowerShell
Push-Location $TFDir
try {
    terraform init -input=false
    terraform apply -auto-approve -var "lambda_zip=$ZipPath" -var "aws_region=$AwsRegion"
} finally {
    Pop-Location
}

Write-Host "Terraform apply completed."