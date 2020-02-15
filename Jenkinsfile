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
        // Reads in the docker_hub_credentials into variable DOCKER_CREDENTIALS
        //  and also creates DOCKER_CREDENTIALS_USR & DOCKER_CREDENTIALS_PSW
        DOCKER_CREDENTIALS=credentials('docker_hub_credentials')
        NAME_TAG="docker-compose"
        TEST_TAG="${NAME_TAG}:test"
        BUILD_TAG="${DOCKER_CREDENTIALS_USR}/${NAME_TAG}"
    }
    stages {
        stage('Syntax check') {
            steps {
                // Check the syntax with dockerlint image
                sh 'docker run -i --rm -v "$PWD/Dockerfile":/Dockerfile:ro ${DOCKER_CREDENTIALS_USR}/dockerlint'
            }
        }
        stage('Build') {
            steps {
                // Build the image with a test tag
                sh 'docker build --tag ${TEST_TAG} .'
            }
        }
        stage('Push') {
/*
            when{
                branch 'master'
            }
*/
                steps {
                    script {
                        // Tag test image with production tag
                        def version = readFile file:"version"
                        sh 'echo ${version}'
                        sh 'docker tag ${TEST_TAG} ${BUILD_TAG}:${version}'

                        // Cleanup test tag
                        sh 'docker image rm ${TEST_TAG}'

                        // Login & push & logout docker hub
                        sh 'docker login -u ${DOCKER_CREDENTIALS_USR} -p ${DOCKER_CREDENTIALS_PSW}'
                        sh 'docker push ${BUILD_TAG}:${version}'
                        sh 'docker logout'
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
