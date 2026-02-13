pipeline {
    agent any

    tools {
        nodejs 'newNode'
    }

    environment {
        DOCKER_REPO = "nkobauri/my-react-app"
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
                        env.IMAGE_NAME = "nodemain:${VERSION}"
                    } else if (env.BRANCH_NAME == 'dev') {
                        env.APP_PORT = "3001"
                        env.IMAGE_NAME = "nodedev:${VERSION}"
                    }

                    env.FULL_IMAGE = "${DOCKER_REPO}/${IMAGE_NAME}"
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
                    docker run --rm \
                      -i hadolint/hadolint < Dockerfile
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
                sh """
                    trivy image --exit-code 1 --severity HIGH,CRITICAL ${FULL_IMAGE}
                """
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nkobauri',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    """
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
                    if (env.BRANCH_NAME == 'main') {
                        build job: 'Deploy_to_main'
                    } else if (env.BRANCH_NAME == 'dev') {
                        build job: 'Deploy_to_dev'
                    }
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
