def projectName = "example"
pipeline{
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
        sh "echo 'Do something!'"
      }
    }
  }
}
