pipeline {
    agent none
    environment {
        JAR_NAME = 'demo-spring-application.jar'
        S3_BUCKET = 'jenkins-spring-boot-build'
        AWS_REGION = 'us-east-1'
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
            agent { label 'ec2-spot-fleet-agents' }
            steps {
                sh 'java --version'
                sh 'mvn --version'
            }
        }

        stage('Build') {
            agent { label 'ec2-spot-fleet-agents' }
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
            agent { label 'ec2-spot-fleet-agents' }
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
            agent { label 'ec2-spot-fleet-agents' }
            steps {
                sh '''
                    docker --version
                    sudo docker run hello-world
                '''
            }
        }

        stage('Push the jar to S3') {
            agent {
                label 'ec2-spot-fleet-agents'
            }
            steps {
                sh '''
                    aws s3 cp ./target/SpringBootFirst-0.0.1-SNAPSHOT.jar s3://jenkins-spring-boot-build/my-builds/my-app.jar
                '''
            }
        }
    }
}

