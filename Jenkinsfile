pipeline {
    agent { label 'win-dev' }

    // environment {
    //     AWS_REGION = 'ap-south-1'
    // }

    stages {
        stage('Versions') {
            steps {
                bat 'git --version'
                bat 'dotnet --version'
                bat 'set PATH=C:\\binaries\\terraform;%PATH%'
                bat 'terraform --version'
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

        stage('Restore & Test') {
            steps {
                dir('src/hello_world') {
                    bat 'dotnet restore'
                    bat 'dotnet build -c Release'
                }
                dir('test/HelloWorld.Tests') {
                    bat 'dotnet test -c Release --no-build'
                }
            }
        }

        

        stage('Publish & Zip') {
            steps {
                powershell '.\\scripts\\build_and_zip.ps1'
                powershell '.\\scripts\\validate_zip.ps1'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'lambda.zip', fingerprint: true
                }
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