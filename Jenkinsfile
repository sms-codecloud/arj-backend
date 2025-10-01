pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs() // clear job workspace
                bat 'git --version'
                dir("${env.WORKSPACE}") {
                    bat 'git clone -b main https://github.com/sms-codecloud/arj-backend.git .'
                }
            }
        }

      stage('Build Lambda Zip') {
      steps {
        powershell '''
          Write-Host "🔨 Building .NET 8 Lambda"
          .\\arj-backend\\scripts\\build_and_zip.ps1
        '''
      }
    }

    stage('Validate Lambda Zip') {
      steps {
        powershell '''
          Write-Host "🔎 Validating lambda.zip"
          .\\arj-backend\\scripts\\validate_zip.ps1 -ZipFile .\\arj-backend\\lambda.zip
        '''
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
        //                     terraform plan -no-color
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