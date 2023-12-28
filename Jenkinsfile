pipeline {
  agent any
  stages {
    stage('pwd') {
      steps {
        sh '''#!/bin/bash

pwd'''
      }
    }

    stage('Fin') {
      steps {
        echo 'Finalizó con exito'
      }
    }

  }
  environment {
    name = 'Juan Traverso'
  }
}