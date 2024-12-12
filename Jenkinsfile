pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')  
        OC_TOKEN = credentials('openshift-token')  
        IMAGE_NAME = "python-app"  
        IMAGE_TAG = "${BUILD_NUMBER}"  // Use Jenkins build number as the image tag
        REGISTRY = "docker.io"
        DEPLOYMENT_FILE = "deployment.yaml"  
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/mabuelmagdd/iVolve-Training/Jenkins/Lab23 - Application Deployment.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image from the Dockerfile, tag it with build number
                    sh 'docker build -t ${REGISTRY}/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${IMAGE_TAG} .'
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    }

                    // Push the Docker image to Docker Hub, use the build number in the tag
                    sh 'docker push ${REGISTRY}/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${IMAGE_TAG}'
                }
            }
        }

        stage('Update Image Version in deployment.yaml') {
            steps {
                script {
                    // Replace image version in deployment.yaml using sed or similar tools
                    sh """
                    sed -i 's|image:.*|image: ${REGISTRY}/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${IMAGE_TAG}|' ${DEPLOYMENT_FILE}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Login to OpenShift using the token
                    withCredentials([string(credentialsId: 'openshift-token', variable: 'OC_TOKEN')]) {
                        sh 'oc login --token=$OC_TOKEN --server=https://your-openshift-cluster-url'
                    }

                    // Apply the updated deployment.yaml file to Kubernetes
                    sh 'oc apply -f ${DEPLOYMENT_FILE}'
                }
            }
        }
    }

    post {
        always {
            script {
                // Post action: Clean up the Docker image
                sh 'docker rmi ${REGISTRY}/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }
    }
}
