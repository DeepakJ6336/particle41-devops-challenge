pipeline {
    agent any

    environment {
        IMAGE_NAME = "simple-time-service"
        AWS_REGION = "us-east-1"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-creds',
                            usernameVariable: 'DOCKERHUB_USERNAME',
                            passwordVariable: 'DOCKERHUB_PASSWORD'
                        )
                    ]) {
                        sh """
                          echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                          cd app
                          docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:latest .
                          docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:latest
                        """
                    }
                }
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh """
                          cd terraform
                          export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                          export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                          export AWS_DEFAULT_REGION=$AWS_REGION

                          terraform init
                          terraform fmt -check
                          terraform plan
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
    }
}

