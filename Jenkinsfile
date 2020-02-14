void setBuildStatus(String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/officerJones/docker-compose"],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

pipeline {
    agent {
        label 'docker-slave'
    }
    environment {
        HOME="${env.WORKSPACE}"
        PATH="$PATH:${HOME}/.local/bin"
        NAME_TAG="docker-compose"
    }
    stages {
        stage('Build') {
            steps {
                sh 'docker build --tag ${NAME_TAG}:test .'
            }
        }
        stage('Push') {
            when{
                branch 'master'
            }
                steps {
                    script {
                        def version = readFile file:"version"
                        sh 'docker tag ${NAME_TAG}:test ${NAME_TAG}:{version}'
                        // TODO: Decide which registry to push to
                    }

                }
        }
    }
    post {
        success {
            setBuildStatus("Build succeeded", "SUCCESS");
        }
        failure {
            setBuildStatus("Build failed", "FAILURE");
        }
    }
}
