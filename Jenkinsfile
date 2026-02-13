pipeline {
    agent any

    tools {
        nodejs 'node'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Set Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        env.APP_PORT = "3000"
                    } else {
                        env.APP_PORT = "3001"
                    }
                    env.IMAGE_NAME = "my-react-app:${env.BRANCH_NAME}"
                }
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
                sh "docker build -t ${env.IMAGE_NAME} ."
            }
        }

        stage('Deploy') {
            steps {
                sh """
                    docker stop my-react-app-${env.BRANCH_NAME} || true
                    docker rm my-react-app-${env.BRANCH_NAME} || true
            
                    docker run -d \
                      -p ${env.APP_PORT}:3000 \
                      --name my-react-app-${env.BRANCH_NAME} \
                      -e HOST=0.0.0.0 \
                      ${env.IMAGE_NAME}
                """
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
