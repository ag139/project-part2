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


    stages {

        stage('Clone') {
            steps {
                git branch: 'main',
                url: 'https://github.com/ag139/project-part2.git'
            }
        }


        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh """
                    docker build -t my-python-app .
                    """
                }
            }
        }


        stage('Push Docker Image') {
            steps {
                echo "Push image stage"
            }
        }


        stage('Deploy Kubernetes') {
            steps {
                sh """
                kubectl apply -f k8s/
                """
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
    }
}
