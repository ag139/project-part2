pipeline {
    agent {
        label 'docker-agent'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Getting code from GitHub'
                checkout scm
            }
        }

        stage('Docker Build Backend') {
            steps {
                echo 'Building backend image'
                sh 'docker build -t project-part2-backend .'
            }
        }

        stage('Docker Images') {
            steps {
                echo 'Checking Docker images'
                sh 'docker images'
            }
        }

        stage('Docker Containers') {
            steps {
                echo 'Checking running containers'
                sh 'docker ps'
            }
        }
    }
}
