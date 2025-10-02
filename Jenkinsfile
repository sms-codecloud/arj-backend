pipeline {
  agent { label 'win-dev' }

  // --- Parameter to control Apply/Destroy ---
  parameters {
    booleanParam(
      name: 'TF_APPLY',
      defaultValue: true,
      description: 'If true: terraform apply. If false: terraform destroy.'
    )
  }

  environment {
    AWS_REGION = 'ap-south-1'
  }

  stages {
    stage('Tooling / Versions') {
      steps {
        withEnv(["PATH=C:\\binaries\\terraform;${env.PATH}"]) {
          bat 'git --version'
          bat 'dotnet --version'
          bat 'terraform --version'
        }
        bat 'dir /s /b *.csproj'
      }
    }

    stage('Restore & Build') {
      steps {
        dir('src/hello_world') {
          bat 'dotnet restore hello_world.csproj'
          bat 'dotnet build hello_world.csproj -c Release --no-restore'
        }
      }
    }

    stage('Publish & Zip Lambda') {
      steps {
        dir('src/hello_world') {
          powershell '''
            $publishDir = Join-Path $env:WORKSPACE 'publish'
            if (Test-Path $publishDir) { Remove-Item -Recurse -Force $publishDir }
            New-Item -ItemType Directory -Path $publishDir | Out-Null

            dotnet publish ".\\hello_world.csproj" -c Release -o "$publishDir" -r linux-x64 --self-contained false
            if ($LASTEXITCODE -ne 0) { Write-Error "dotnet publish failed with exit code $LASTEXITCODE"; exit $LASTEXITCODE }

            $zip = Join-Path $env:WORKSPACE 'lambda_deploy.zip'
            if (Test-Path $zip) { Remove-Item $zip -Force }
            Push-Location $publishDir
            Compress-Archive -Path * -DestinationPath $zip -Force
            Pop-Location

            Write-Host "Created $zip"
          '''
        }
        archiveArtifacts artifacts: 'lambda_deploy.zip', fingerprint: true
      }
    }

    stage('Deploy lambda') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws_secrets_shankar']]) {
          withEnv(["PATH=C:\\binaries\\terraform;${env.PATH}", "TF_APPLY=${params.TF_APPLY}"]) {
            powershell '''
              $ErrorActionPreference = "Stop"
              $env:AWS_DEFAULT_REGION = $env:AWS_REGION

              # ZIP to deploy
              $zip = Resolve-Path "$env:WORKSPACE\\lambda_deploy.zip"
              if (-not (Test-Path $zip)) { throw "Zip not found: $env:WORKSPACE\\lambda_deploy.zip" }

              # Terraform directory (CHANGE if your code is in 'lambda')
              $tfDir = "$env:WORKSPACE\\tf"
              if (-not (Test-Path $tfDir)) { throw "Terraform dir not found: $tfDir" }

              Write-Host "TF_APPLY = $env:TF_APPLY"
              terraform -chdir="$tfDir" init -upgrade -no-color -input=false

              if ($env:TF_APPLY -eq "true") {
                Write-Host "Running: terraform plan + apply"
                terraform -chdir="$tfDir" plan -no-color -input=false `
                  -var "aws_region=$env:AWS_REGION" `
                  -var "lambda_zip=$($zip.Path)"
                terraform -chdir="$tfDir" apply -no-color -input=false -auto-approve `
                  -var "aws_region=$env:AWS_REGION" `
                  -var "lambda_zip=$($zip.Path)"
              }
              else {
                Write-Host "Running: terraform plan -destroy + destroy"
                terraform -chdir="$tfDir" plan -destroy -no-color -input=false `
                  -var "aws_region=$env:AWS_REGION" `
                  -var "lambda_zip=$($zip.Path)"
                terraform -chdir="$tfDir" destroy -no-color -input=false -auto-approve `
                  -var "aws_region=$env:AWS_REGION" `
                  -var "lambda_zip=$($zip.Path)"
              }
            '''
          }
        }
      }
    }
  }

  post {
    success { echo 'Pipeline completed successfully!' }
    failure { echo 'Pipeline failed.' }
  }
}
