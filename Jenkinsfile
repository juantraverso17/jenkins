pipeline {
    agent any

    environment {
        // Define la variable de versión con el formato requerido
        VERSION = "nxtest:1.0.0-${env.GIT_COMMIT}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Clona el repositorio desde el origen
                checkout scm
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

        stage('Push Docker Image') {
            steps {
                script {
                    // Cambia las credenciales de Docker según sea necesario
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        // Inicia sesión en Docker Hub
                        docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                            // Publica la imagen en Docker Hub
                            docker.image(env.VERSION).push()
                        }
                    }
                }
            }
        }
    }
}
