pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')  
        IMAGE_NAME = "python-app"
        IMAGE_TAG = "${BUILD_NUMBER}"  
        REGISTRY = "docker.io"
        DEPLOYMENT_FILE = "deployment.yaml"
        MINIKUBE_TOKEN = credentials('minikube-token')  // Use the token as Jenkins credential
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/mabuelmagdd/test.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image from the Dockerfile, tag it with build number
                    sh 'docker build -f Dockerfile -t ${REGISTRY}/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${IMAGE_TAG} .'
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    }
                    sh 'docker push ${REGISTRY}/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${IMAGE_TAG}'
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    // Use the token as authentication for Minikube
                    // sh '''
                    // mkdir -p "$WORKSPACE/.kube"
                    // echo "$MINIKUBE_TOKEN" > "$WORKSPACE/.kube/token"
                    // kubectl config set-credentials jenkins --token=$(cat "$WORKSPACE/.kube/token")
                    // kubectl config set-context minikube --user=jenkins --cluster=minikube
                    // kubectl config use-context minikube
                    // kubectl apply -f "${DEPLOYMENT_FILE}" --validate=false
                    // '''
                    sh '''
                    mkdir -p "$WORKSPACE/.kube"
                    echo "$MINIKUBE_TOKEN" > "$WORKSPACE/.kube/token"
                    
                    kubectl config set-credentials jenkins --token=$(cat "$WORKSPACE/.kube/token")
                    kubectl config set-context minikube --user=jenkins --cluster=minikube --namespace=default
                    kubectl config use-context minikube
                    
                    if ! kubectl auth can-i apply --token=$(cat "$WORKSPACE/.kube/token"); then
                        echo "Error: Insufficient permissions for token. Exiting."
                        exit 1
                    fi
                    
                    if [ -z "$DEPLOYMENT_FILE" ]; then
                        echo "Error: DEPLOYMENT_FILE is not set. Exiting."
                        exit 1
                    fi
                    
                    if [ ! -f "$DEPLOYMENT_FILE" ]; then
                        echo "Error: Deployment file '$DEPLOYMENT_FILE' does not exist. Exiting."
                        exit 1
                    fi
                    
                    kubectl apply -f "$DEPLOYMENT_FILE" --validate=false
                    '''
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
