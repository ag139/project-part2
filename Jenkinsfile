pipeline {

    agent {
        label 'docker-agent'
    }

    parameters {
        string(
            name: 'REPO_URL',
            defaultValue: 'https://github.com/ag139/project-part2.git',
            description: 'Git repository URL'
        )

        string(
            name: 'EMAIL',
            defaultValue: '',
            description: 'Email address for notifications'
        )
    }


    stages {

        stage('Checkout') {
            steps {
                script {
                    if (!params.REPO_URL?.trim()) {
                        error("REPO_URL parameter is empty")
                    }

                    git branch: 'main',
                        url: "${params.REPO_URL}"
                }
            }
        }


        stage('Check Files') {
            steps {
                sh '''
                echo "Project files:"
                ls -la
                '''
            }
        }


        stage('Unit Tests') {
            steps {
                sh '''
                if find . -name "test_*.py" -o -name "*_test.py" | grep -q .; then
                    pytest
                else
                    echo "No tests found - skipping"
                fi
                '''
            }
        }


        stage('Python Lint') {
            steps {
                sh '''
                flake8 . || true
                '''
            }
        }


        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t my-python-app .
                '''
            }
        }


        stage('Docker Security Scan') {
            steps {
                sh '''
                trivy image my-python-app
                '''
            }
        }


        stage('Push Docker Image') {
            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                    echo $DOCKER_PASS | docker login \
                    -u $DOCKER_USER \
                    --password-stdin


                    docker tag my-python-app \
                    $DOCKER_USER/my-python-app:latest


                    docker push \
                    $DOCKER_USER/my-python-app:latest
                    '''
                }
            }
        }

    }


    post {

        success {
            echo "Pipeline completed successfully"
        }


        failure {
            echo "Pipeline failed"
        }


        always {
            echo "Pipeline finished"
        }

    }
}
