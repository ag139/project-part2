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
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - sleep
    args:
    - infinity
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
        string(
            name: 'EMAIL',
            defaultValue: '',
            description: 'Email address for notifications'
        )
    }
    environment {
        IMAGE_NAME = 'my-python-app'
        DOCKER_CREDENTIALS = 'dockerhub-creds'
        SONAR_PROJECT_KEY = 'python-project'
    }
    stages {
        stage('Clone') {
            steps {
                echo "Cloning repository..."
                git(
                    branch: 'main',
                    url: "${params.REPO_URL}"
                )
            }
        }
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
                    echo "Building Docker image..."
                    docker build -t ${IMAGE_NAME}:latest .
                    '''
                }
            }
        }
        stage('Deploy Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                    echo "Deploying application to Kubernetes..."
                    kubectl apply -f k8s/
                    kubectl get pods
                    '''
                }
            }
        }
    }
    post {
        success {
            echo "Pipeline finished successfully"
        }
        failure {
            echo "Pipeline failed"
        }
        always {
            echo "Pipeline finished."
        }
    }
}
