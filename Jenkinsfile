pipeline {
    agent { label 'win-dev' }

    // environment {
    //     AWS_REGION = 'ap-south-1'
    // }

    stages {
        stage('Tooling') {
            steps {
                withEnv(["PATH=C:\\binaries\\terraform;${env.PATH}"]) {
                bat 'git --version'
                bat 'dotnet --version'
                bat 'terraform --version'
                }
            }
        }

        stage('Checkout') {
            steps {
                cleanWs() // clear job workspace
                dir("${env.WORKSPACE}\\arj-backend") {
                    bat 'git clone -b main https://github.com/sms-codecloud/arj-backend.git .'
                }
            }
        }

        stage('Locate project') {
            steps {
                // Find the first .csproj anywhere under the workspace and persist its path
                powershell '''
                $proj = Get-ChildItem -Path "$env:WORKSPACE" -Recurse -Filter *.csproj | Select-Object -First 1
                if (-not $proj) {
                    Write-Error "No .csproj found under $env:WORKSPACE"
                    exit 1
                }
                $proj.FullName | Out-File -FilePath "$env:WORKSPACE\\csproj_path.txt" -Encoding ascii -Force
                Write-Host "Found project: $($proj.FullName)"
                '''
            }
        }

        stage('Restore & Build & Test') {
            steps {
                script {
                    env.CSPROJ = readFile('csproj_path.txt').trim()
                }
                powershell '''
                Write-Host "Using project: $env:CSPROJ"
                dotnet restore "$env:CSPROJ"
                dotnet build "$env:CSPROJ" -c Release --no-restore

                # Optional: run tests if you have a test project
                $testProj = Get-ChildItem -Path "$env:WORKSPACE" -Recurse -Filter *.Tests.csproj | Select-Object -First 1
                if ($testProj) {
                    dotnet test "$($testProj.FullName)" -c Release --no-build
                } else {
                    Write-Host "No test project found. Skipping tests."
                }
                '''
            }
        }

    stage('Publish & Zip') {
      steps {
        script {
          env.CSPROJ = readFile('csproj_path.txt').trim()
        }
        powershell '''
          $publishDir = Join-Path $env:WORKSPACE 'publish'
          if (Test-Path $publishDir) { Remove-Item -Recurse -Force $publishDir }
          New-Item -ItemType Directory -Path $publishDir | Out-Null

          # For AWS Lambda on Linux
          dotnet publish "$env:CSPROJ" -c Release -o "$publishDir" -r linux-x64 --self-contained false
          if ($LASTEXITCODE -ne 0) { Write-Error "dotnet publish failed with exit code $LASTEXITCODE"; exit $LASTEXITCODE }

          $zip = Join-Path $env:WORKSPACE 'lambda.zip'
          if (Test-Path $zip) { Remove-Item $zip -Force }
          Push-Location $publishDir
          Compress-Archive -Path * -DestinationPath $zip -Force
          Pop-Location

          Write-Host "Created $zip"
        '''
        archiveArtifacts artifacts: 'lambda.zip', fingerprint: true
      }
    }

        // stage('Deploy To Lambda') {
        //     steps {
        //         withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws_secrets_shankar']]) {
        //             dir("${env.WORKSPACE}\\arj-backend\\lambda") {
        //                 bat """
        //                     set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
        //                     set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%

        //                     set PATH=C:\\binaries\\terraform;%PATH%

        //                     terraform init -no-color
        //                     terraform plan -no-color -var="lambda_zip=$($zip.Path)"
        //                 """
        //             }
        //         }
        //     }
        // }

        
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}