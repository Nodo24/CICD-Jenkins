pipeline {
    agent any
    tools {
        nodejs 'node'
    }
    environment {
        APP_PORT = "${env.BRANCH_NAME == 'main' ? '3000' : '3001'}"
        IMAGE_NAME = "my-react-app:${env.BRANCH_NAME}"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                sh "chmod +x scripts/build.sh"
                sh "./scripts/build.sh"
            }
        }
        stage('Test') {
            steps {
                sh "chmod +x scripts/test.sh"
                sh "./scripts/test.sh"
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }
    }
}
