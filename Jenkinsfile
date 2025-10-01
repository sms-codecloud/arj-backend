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

       stage('Build and Zip') {
            steps {
                script {
                    def file_path = 'scripts\\build_and_zip.ps1'
                    if (!fileExists(file_path)) {
                        error "build_and_zip.ps1 not found."
                    }
                    bat "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"${file_path}\""
                }
            }
        }

        stage('Validate .zip availability') {
            steps {
                script {
                    def file_path = 'scripts\\validate_zip.ps1'
                    if (!fileExists(file_path)) {
                        error "validate_zip.ps1 not found."
                    }
                    bat "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"${file_path}\""
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