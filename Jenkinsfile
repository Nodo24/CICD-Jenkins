@Library('jenkins-shared-library') _

pipeline {
    agent any
    tools {
        nodejs 'newNode'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build and Push') {
            steps {
                script {
                    buildAndPush(
                        version: 'v1.0',
                        dockerUser: 'nkobauri',
                        repoName: 'my-react-app',
                        credentialsId: 'dockerhub-credentials'
                    )
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
