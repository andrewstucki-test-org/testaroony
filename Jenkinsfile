def projectName = "example"
pipeline{
  agent any

  environment {
    COMPOSE_PROJECT_NAME = "$projectName"
  }
  stages {
    stage("test") {
      steps{
        sh "make test"
      }
    }

    stage("deploy") {
      steps{
        sh "make deploy"
      }
    }
  }
  post {
    always {
      sh "make clean"
    }
  }
}
