#!/usr/bin/env groovy

def app = dockerize()

pipeline {
  agent none

  stages {
    stage('Test') {
      agent {
        docker {
          args '--network ci_services_network'
          image app.imageName()
        }
      }

      environment {
        DATABASE_URL = "mysql2://root:root@mysql/jenkins_${BUILD_TAG.split('%2F')[-1]}"
      }

      steps {
        sh 'setup'
        sh 'rake'
      }

      post {
        always {
          sh 'rails db:drop || true'
          junit 'tmp/specs.xml'
          publishBrakeman 'tmp/brakeman.json'
        }
      }
    }

    stage('Push') {
      agent {
        label 'docker'
      }

      steps {
        script {
          docker.withRegistry(DOCKER_REGISTRY_URL, DOCKER_REGISTRY_CREDENTIALS_ID) {
            app.push('latest')
          }
        }
      }
    }
  }

  post {
    success {
      script {
        slackSend color: 'good',
                  message: """
                  |Success!
                  |
                  |Build:  <${env.BUILD_URL}|${env.JOB_NAME.replaceAll('%2F', '/')}/${env.BUILD_NUMBER}>
                  |Repo:   `${env.GIT_URL}`
                  """.stripMargin()
      }
    }

    failure {
      script {
        slackSend color: 'danger',
                  message: """
                  |Failure!
                  |
                  |Build:  <${env.BUILD_URL}|${env.JOB_NAME.replaceAll('%2F', '/')}/${env.BUILD_NUMBER}>
                  |Repo:   `${env.GIT_URL}`
                  """.stripMargin()
      }
    }
  }

  options {
    ansiColor('xterm')
    disableConcurrentBuilds()
    disableResume()
    timeout(time: 10, unit: 'MINUTES')
  }
}
