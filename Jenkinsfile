pipeline {
    agent {
        node {
            label 'docker'
        }
    }
    environment {
        // Define la variable de versión con el formato requerido
        VERSION = "traversojm/nxtest:1.0.0-${env.GIT_COMMIT}"
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

        stage('Push Docker Image') {
            steps {
                script {
                    // Utiliza las credenciales de Docker Hub almacenadas en Jenkins
                    withCredentials([dockerRegistry(credentialsId: 'cf534e82-dca1-4026-b044-6453d84c6437', url: 'https://index.docker.io/v1/')]) {
                        // Publica la imagen en Docker Hub
                        docker.withRegistry('https://index.docker.io/v1/', 'cf534e82-dca1-4026-b044-6453d84c6437') {
                            docker.image(env.VERSION).push()
                        }
                    }
                }
            }
        }
    }
}