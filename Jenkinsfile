pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-agent
spec:
  serviceAccountName: jenkins
  containers:
  - name: docker
    image: docker:latest
    command:
    - sleep
    args:
    - infinity
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }

    parameters {
        string(
            name: 'REPO_URL',
            defaultValue: 'https://github.com/ag139/project-part2',
            description: 'Git repository URL'
        )
        booleanParam(
            name: 'TRIGGER_CD',
            defaultValue: false,
            description: 'Trigger the CD job automatically after a successful build'
        )
    }

    environment {
        IMAGE_NAME  = 'my-python-app'
        DOCKER_REPO = 'ayeletgeulayev/my-python-app'
        CD_JOB_NAME = 'my-python-app-cd'
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {

        stage('Check Files') {
            steps {
                sh '''
                echo "Checking project files"
                ls -la
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh '''
                    set -e
                    echo "Building ${IMAGE_NAME}:${BUILD_NUMBER} ..."
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                        set -e
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_REPO}:${BUILD_NUMBER}
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_REPO}:latest

                        echo "Pushing ${DOCKER_REPO}:${BUILD_NUMBER} ..."
                        docker push ${DOCKER_REPO}:${BUILD_NUMBER}
                        docker push ${DOCKER_REPO}:latest

                        docker logout
                        '''
                    }
                }
            }
        }

        stage('Trigger CD') {
            when {
                expression { return params.TRIGGER_CD }
            }
            steps {
                script {
                    echo "Handing off ${DOCKER_REPO}:${BUILD_NUMBER} to ${CD_JOB_NAME}"
                    build(
                        job: env.CD_JOB_NAME,
                        wait: false,
                        parameters: [
                            string(name: 'IMAGE_TAG', value: env.BUILD_NUMBER)
                        ]
                    )
                }
            }
        }
    }

    post {
        success {
            echo "CI finished successfully - pushed ${DOCKER_REPO}:${BUILD_NUMBER}"
        }
        failure {
            echo "CI failed"
        }
        always {
            echo "CI pipeline finished."
        }
    }
}
