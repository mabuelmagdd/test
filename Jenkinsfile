pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')  
        IMAGE_NAME = "nginx-test"
        IMAGE_TAG = "${BUILD_NUMBER}"  
        REGISTRY = "docker.io"
        DEPLOYMENT_FILE = "deployment.yaml"
        OC_SERVER = "https://api.ocp-training.ivolve-test.com:6443"
        OC_NAMESPACE = "maryamabualmaged"  // Replace with your OpenShift namespace
        OC_TOKEN = credentials('oc-jenkins-token')  // OpenShift token stored in Jenkins
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
                    sh 'docker build -f Dockerfile -t ${REGISTRY}/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:latest .'
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    }
                    sh 'docker push ${REGISTRY}/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:latest'
                }
            }
        }

        stage('Deploy to OpenShift') {
            steps {
                script {
                    sh '''
                    # Log in to OpenShift using Jenkins ServiceAccount token
                    oc login ${OC_SERVER} --token=${OC_TOKEN} --insecure-skip-tls-verify=true
                    
                    # Switch to the target namespace
                    oc project ${OC_NAMESPACE}

                    # Deploy using the deployment file
                    if [ -f "${DEPLOYMENT_FILE}" ]; then
                        oc apply -f "${DEPLOYMENT_FILE}"
                    else
                        echo "Error: Deployment file '${DEPLOYMENT_FILE}' not found. Exiting."
                        exit 1
                    fi
                    
                    # Verify deployment
                    #oc rollout status deployment/${IMAGE_NAME} --timeout=60s
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'docker rmi ${REGISTRY}/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:latest'
            }
        }
    }
}
