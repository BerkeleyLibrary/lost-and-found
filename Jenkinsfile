#!/usr/bin/env groovy

pipeline {
  agent {
    dockerfile {
      args "--network ci_services_network"
    }
  }

  environment {
    DATABASE_URL = "mysql2://root:root@mysql/jenkins_${BUILD_TAG}"
    RAILS_ENV = "test"
  }

  stages {
    stage("Setup") {
      steps {
        sh 'env | sort'
        sh 'setup'
      }
    }

    stage("Test") {
      parallel {
        stage('audit') {
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              /* Passing parameter --ignore CVE-2015-9284 to bundle check in order to resolve
               * security vulnerability per documentation
               * @see https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
               */
              sh 'bundle-audit update'
              sh 'bundle-audit check --ignore CVE-2015-9284'
            }
          }
        }

        stage('brakeman') {
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              sh 'brakeman'
            }
          }

          post {
            always {
              publishBrakeman 'tmp/brakeman.json'
            }
          }
        }

        stage('rspec') {
          steps {
            sh 'rspec'
          }

          post {
            always {
              junit 'tmp/specs.xml'
            }
          }
        }
      }
    }
  }

  post {
    always {
      sh 'rails db:drop || true'
    }

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
    ansiColor("xterm")
    disableConcurrentBuilds()
    disableResume()
    timeout(time: 10, unit: "MINUTES")
  }
}
