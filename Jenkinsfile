pipeline {
  agent any
  stages {
    stage('Echo') {
      steps {
        sh '''#!/bin/bash

echo "hola $name" >> /srv/docker/jenkinsfile.txt'''
      }
    }

    stage('Fin') {
      steps {
        echo 'Finaliz� con exito'
      }
    }

  }
  environment {
    name = 'Juan Traverso'
  }
}