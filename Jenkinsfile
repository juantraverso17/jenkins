pipeline {
    agent {
        node {
            label 'docker'
        }
    }

    environment {
        // Define la variable de versión con el formato requerido
        GIT_ASD = GIT_COMMIT.take(4)
        VERSION = "traversojm/nxtest:1.0.0-${GIT_ASD}"
        DOCKER_HUB_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS_ID = 'cf534e82-dca1-4026-b044-6453d84c6437' // Reemplaza con el ID de tus credenciales en Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                // Clona el repositorio desde el origen
                checkout scm
            }
        }
        stage('Check Docker Version') {
            steps {
                script {
                    sh 'docker --version'
                    echo "El valor de GIT_ASD es: ${GIT_ASD}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Construye la imagen de Docker y la etiqueta con la versión
                    docker.build env.VERSION, "-f Dockerfile ."
                }
            }
        }

        stage('Construir y Publicar Imagen') {
            steps {
                script {
                    // Autenticarse en Docker Hub utilizando las credenciales de Jenkins
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD ${DOCKER_HUB_REGISTRY}"
                    }

                    // Subir la imagen a Docker Hub
                    sh "docker push ${VERSION}"
                }
            }
        }
    }
}