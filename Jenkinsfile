#!/usr/bin/env groovy

pipeline {
  agent {
    label 'ruby'
  }

  environment {
    DATABASE_NAME = "jenkins_lost_and_found_${env.BRANCH_NAME.toLowerCase()}_${BUILD_ID}"
    DATABASE_URL = "mysql2://root:root@db/${DATABASE_NAME}"
    RACK_ENV = "test"
    RAILS_ENV = "test"
  }

  stages {
    stage("Build") {
      steps {
        sh 'printenv | sort'
        sh 'gem install bundler'
        sh 'bundle install'
        sh 'bundle exec -- rails db:setup'
      }
    }


/*
Passing parameter --ignore CVE-2015-9284 to bundle check in order to resolve security vulnerability
per documentation https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
*/
    stage("Test") {
      parallel {
        stage('audit') {
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              sh 'gem install bundler-audit'
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
            sh 'bundle exec -- rspec'
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

  options {
    ansiColor("xterm")
    timeout(time: 10, unit: "MINUTES")
  }
}
