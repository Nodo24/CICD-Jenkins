pipeline {
    agent any
    tools {
        nodejs 'newNode'
    }
    environment {
        DOCKER_USER = "nkobauri"
        REPO_NAME = "my-react-app"
        VERSION = "v1.0"
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
                        env.IMAGE_TAG = "main-${VERSION}"
                        env.DEPLOY_JOB = "Deploy_to_main"
                    } else if (env.BRANCH_NAME == 'dev') {
                        env.APP_PORT = "3001"
                        env.IMAGE_TAG = "dev-${VERSION}"
                        env.DEPLOY_JOB = "Deploy_to_dev"
                    }
                    env.FULL_IMAGE = "${DOCKER_USER}/${REPO_NAME}:${IMAGE_TAG}"
                }
            }
        }
        stage('Build Application') {
            steps {
                sh "chmod +x scripts/build.sh"
                sh "./scripts/build.sh"
            }
        }
        stage('Test Application') {
            steps {
                sh "chmod +x scripts/test.sh"
                sh "./scripts/test.sh"
            }
        }
        stage('Lint Dockerfile - Hadolint') {
            steps {
                sh """
                    docker run --rm -i hadolint/hadolint < Dockerfile
                """
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${FULL_IMAGE} ."
            }
        }
        stage('Security Scan - Trivy') {
            steps {
                script {
                    sh """
                        trivy image --exit-code 1 \\
                          --severity HIGH,CRITICAL \\
                          --skip-dirs /usr/local \\
                          ${env.FULL_IMAGE}
                    """
                }
            }
        }
        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        '''
                    }
                }
            }
        }
        stage('Push Image to Docker Hub') {
            steps {
                sh "docker push ${FULL_IMAGE}"
            }
        }
        stage('Trigger Environment Deployment') {
            steps {
                script {
                    build job: env.DEPLOY_JOB, 
                          wait: false, 
                          parameters: [
                              string(name: 'IMAGE_TAG', value: env.IMAGE_TAG),
                              string(name: 'APP_PORT', value: env.APP_PORT)
                          ]
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
