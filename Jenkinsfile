pipeline {

    agent {
        label 'docker-agent'
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
            description: 'Email address for build notifications'
        )
    }

    environment {

        IMAGE_NAME = 'my-python-app'

        DOCKER_CREDENTIALS = 'dockerhub-creds'

        SONAR_PROJECT_KEY = 'python-project'
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out repository..."

                git(
                    branch: 'main',
                    url: "${params.REPO_URL}"
                )
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


        stage('SonarQube Scan') {
            steps {

                withSonarQubeEnv('sonarqube') {

                    script {

                        def scannerHome = tool 'sonar-scanner'

                        sh """
                            echo "Running SonarQube analysis..."

                            ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.projectName=${SONAR_PROJECT_KEY} \
                                -Dsonar.sources=.
                        """
                    }
                }
            }
        }


        stage('Unit Tests') {
            steps {

                sh '''
                    echo "Running unit tests..."

                    TEST_FILES=$(find . -type f \\( \
                        -name "test_*.py" \
                        -o \
                        -name "*_test.py" \
                    \\))

                    if [ -n "$TEST_FILES" ]; then
                        pytest
                    else
                        echo "No tests found - skipping tests"
                    fi
                '''
            }
        }


        stage('Python Lint') {
            steps {

                sh '''
                    echo "Running Flake8..."

                    flake8 . || true
                '''
            }
        }


        stage('Build Docker Image') {
            steps {

                sh '''
                    echo "Building Docker image..."

                    docker build \
                        -t ${IMAGE_NAME}:latest \
                        .
                '''
            }
        }


        stage('Docker Security Scan') {
            steps {

                sh '''
                    echo "Running Trivy security scan..."

                    trivy image \
                        --skip-version-check \
                        ${IMAGE_NAME}:latest
                '''
            }
        }


        stage('Push Docker Image') {
            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: "${DOCKER_CREDENTIALS}",
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                        echo "Logging into Docker Hub..."

                        echo "$DOCKER_PASS" | docker login \
                            --username "$DOCKER_USER" \
                            --password-stdin

                        echo "Tagging Docker image..."

                        docker tag \
                            ${IMAGE_NAME}:latest \
                            ${DOCKER_USER}/${IMAGE_NAME}:latest

                        echo "Pushing Docker image..."

                        docker push \
                            ${DOCKER_USER}/${IMAGE_NAME}:latest

                        echo "Docker image pushed successfully."
                    '''
                }
            }
        }
    }


    post {

        success {

            echo 'Pipeline completed successfully.'

            script {

                if (params.EMAIL?.trim()) {

                    emailext(
                        to: params.EMAIL,
                        subject: "Jenkins SUCCESS - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                        body: """
Pipeline completed successfully.

Repository:
${params.REPO_URL}

Build Number:
${env.BUILD_NUMBER}

Result:
SUCCESS
"""
                    )
                }
            }
        }


        failure {

            echo 'Pipeline failed.'

            script {

                if (params.EMAIL?.trim()) {

                    emailext(
                        to: params.EMAIL,
                        subject: "Jenkins FAILED - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                        body: """
Pipeline failed.

Repository:
${params.REPO_URL}

Build Number:
${env.BUILD_NUMBER}

Result:
FAILED
"""
                    )
                }
            }
        }


        always {
            echo 'Pipeline finished.'
        }
    }
}
