#!/usr/bin/env bash
set -euo pipefail

# Deploy packaged lambda.zip to AWS Lambda via Terraform.
# Expects Jenkins to inject AWS credentials into environment:
#   AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, (optional) AWS_SESSION_TOKEN
# AWS_REGION is read from env (set in Jenkinsfile).

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZIP_PATH="$ROOT_DIR/lambda.zip"
TF_DIR="$ROOT_DIR/terraform"

echo "Root: $ROOT_DIR"
echo "Terraform dir: $TF_DIR"
echo "Zip path: $ZIP_PATH"

if [ ! -f "$ZIP_PATH" ]; then
  echo "Error: $ZIP_PATH not found. Ensure build stage produced lambda.zip."
  exit 2
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "Error: terraform not found in PATH."
  exit 3
fi

# Ensure AWS credentials are present (injected by Jenkins)
: "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID is required (inject from Jenkins credentials)}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY is required (inject from Jenkins credentials)}"
AWS_REGION="${AWS_REGION:-ap-south-1}"

export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_REGION

echo "Using AWS region: $AWS_REGION"
cd "$TF_DIR"

terraform init -input=false
terraform apply -auto-approve -var "lambda_zip=${ZIP_PATH}" -var "aws_region=${AWS_REGION}"

echo "Terraform apply completed."