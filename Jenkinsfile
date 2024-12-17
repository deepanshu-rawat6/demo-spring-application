pipeline {
    agent none
    environment {
        JAR_NAME = "demo-spring-application.jar"
        S3_BUCKET = "jenkins-spring-boot-build"
        AWS_REGION = "us-east-1"
    }
    stages {
        stage('Checkout to Master') {
            agent {
                node 'master-node'
            }
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
                sh '''
                    # Set the JAR name in pom.xml
                    sed -i 's/<finalName>.*<\\/finalName>/<finalName>${JAR_NAME}<\\/finalName>/' pom.xml

                    # Clean and install with custom JAR name
                    mvn clean install -Djar.finalName=${JAR_NAME}
                '''
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
            node('master-node') {
                script {
                    sh '''
                        echo "Final JAR File Verification on Master Node:"
                        JAR_FILE=$(find . -name "${JAR_NAME}" | head -n 1)
                        if [ -n "$JAR_FILE" ]; then
                            echo "Found JAR: $JAR_FILE"
                            ls -l "$JAR_FILE"
                            file "$JAR_FILE"

                            # Optional: Copy JAR to a specific location on master
                            mkdir -p /path/to/jar/storage
                            cp "$JAR_FILE" /path/to/jar/storage/
                        else
                            echo "ERROR: JAR file ${JAR_NAME} not found!"
                            exit 1
                        fi
                    '''
                }
            }
        }
    }
}