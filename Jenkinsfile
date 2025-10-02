pipeline {
  agent { label 'win-dev' }

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

            $zip = Join-Path $env:WORKSPACE 'lambda.zip'
            if (Test-Path $zip) { Remove-Item $zip -Force }
            Push-Location $publishDir
            Compress-Archive -Path * -DestinationPath $zip -Force
            Pop-Location

            Write-Host "Created $zip"
          '''
        }
        archiveArtifacts artifacts: 'lambda.zip', fingerprint: true
      }
    }

    // stage('Terraform Init/Plan/Apply') {
    //   steps {
    //     withEnv(["PATH=C:\\binaries\\terraform;${env.PATH}"]) {
    //       dir('lambda') {
    //         powershell '''
    //           $zip = Resolve-Path "$env:WORKSPACE\\lambda.zip"
    //           terraform init
    //           terraform plan  -var="aws_region=%AWS_REGION%" -var="lambda_zip=$($zip.Path)"
    //           terraform apply -auto-approve -var="aws_region=%AWS_REGION%" -var="lambda_zip=$($zip.Path)"
    //         '''
    //       }
    //     }
    //   }
    // }
  }

  post {
    success { echo 'Pipeline completed successfully!' }
    failure { echo 'Pipeline failed.' }
  }
}
