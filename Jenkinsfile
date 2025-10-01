pipeline {
    agent { label 'win-dev' }

    environment {
        AWS_REGION = 'ap-south-1'
    }

    stages {
        stage('software versions') {
            steps {
                // bat 'set PATH=C:\\binaries\\terraform;%PATH%'
                // bat 'terraform --version'

                bat 'git --version'
                bat 'dotnet --version'
            }
        }

        stage('Checkout') {
            steps {
                cleanWs() // clear job workspace
                bat 'git --version'
                bat 'terraform --version'
                bat 'dotnet --version'
                dir("${env.WORKSPACE}\\arj-backend") {
                    bat 'git clone -b main https://github.com/sms-codecloud/arj-backend.git .'
                }
            }
        }

        stage('Build Lambda Zip') {
            steps {
                dir("${env.WORKSPACE}\\arj-backend") {
                    powershell(script: '.\\scripts\\build_and_zip.ps1')
                }
            }
        }

// stage('Validate Lambda Zip') {
//     steps {
//         dir("${env.WORKSPACE}\\arj-backend") {
//             powershell(script: '.\\scripts\\validate_zip.ps1', returnStatus: true)
//         }
//     }
// }

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