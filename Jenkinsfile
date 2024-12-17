pipeline {
    agent none
    environment {
        JAR_NAME = "demo-spring-application.jar"
        S3_BUCKET = "jenkins-spring-boot-build"
        AWS_REGION = "us-east-1"
    }
    stages {
        stage('Checkout to Master and Agents') {
                    agent { label 'spot-build-agents' }
                    steps {
                        git branch: 'master', url: 'https://github.com/deepanshu-rawat6/demo-spring-application'
                    }
        }

        stage('Starting build process') {
            agent { label 'spot-build-agents' }
            steps {
                sh 'java --version'
                sh 'mvn --version'
            }
        }

        stage('Build') {
            agent { label 'spot-build-agents' }
            steps {
                sh 'mvn clean && mvn install'
            }
        }

        stage('Comprehensive JAR Search') {
            agent { label 'spot-build-agents' }
            steps {
                script {
                    sh '''
                        echo "Searching for JAR files in multiple locations:"

                        echo "1. Current Working Directory:"
                        find . -name "*.jar"

                        echo "\\n2. Maven Local Repository:"
                        find ~/.m2 -name "*.jar"

                        echo "\\n3. Target Directory:"
                        find target -name "*.jar"

                        echo "\\n4. Detailed Search with File Information:"
                        find . -name "*.jar" -exec sh -c 'echo "File: {}"; ls -l "{}"; file "{}"; echo "---"' \\;
                    '''
                }
            }
        }

        stage('Testing Docker on Spot Instance') {
            agent { label 'spot-build-agents' }
            steps {
                sh '''
                    docker --version
                    sudo docker run hello-world
                '''
            }
        }
    }

    post {
        success {
            script {
                sh '''
                    echo "Final JAR File Verification:"
                    JAR_FILE=$(find . -name "${JAR_NAME}" | head -n 1)
                    if [ -n "$JAR_FILE" ]; then
                        echo "Found JAR: $JAR_FILE"
                        ls -l "$JAR_FILE"
                        file "$JAR_FILE"
                    else
                        echo "ERROR: JAR file ${JAR_NAME} not found!"
                        exit 1
                    fi
                '''
            }
        }
    }
}