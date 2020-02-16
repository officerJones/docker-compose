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
        USER="officerjones"
        DOCKER_HUB_PASS=credentials('docker_hub_password')
        NAME_TAG="docker-compose"
        TEST_TAG="${NAME_TAG}:test"
        BUILD_TAG="${USER}/${NAME_TAG}"
        def IMAGE_VERSION=readFile "version"
    }
    stages {
/*
        TODO: make it work in jenkins (cmd works on host cli)
        stage('Syntax check') {
            steps {
                // Check the syntax with dockerlint image
                sh 'docker run -i --rm -v "$PWD/Dockerfile":/Dockerfile ${USER}/dockerlint'
            }
        }
*/
        stage('Build') {
            steps {
                // Build the image with a test tag
                sh 'docker build --tag ${TEST_TAG} .'
            }
        }
        stage('Push') {
            when{
                branch 'master'
            }
                steps {
                    script {
                        // Tag test image with production tag
                        sh """
                            echo 'Tagging with version ${IMAGE_VERSION}'
                            docker tag ${TEST_TAG} ${BUILD_TAG}:${IMAGE_VERSION}
                            docker image rm ${TEST_TAG}
                            echo '${DOCKER_HUB_PASS}' | docker login --username ${USER} --password-stdin
                            docker push ${BUILD_TAG}:${IMAGE_VERSION}
                            docker logout
                        """

                        // TODO: push to github packages
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
