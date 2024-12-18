pipeline {
    agent {
        label 'terraform-agents'
    }
    environment {
        JAR_NAME = 'demo-spring-application.jar'
        S3_BUCKET = 'jenkins-spring-boot-build'
        AWS_REGION = 'us-east-1'
        SPOT_INSTACES = 'ec2-spot-fleet-agents'
        TERRAFORM_INSTANCES = 'terraform-agents'
        FARGATE_INSTANCES = 'deepanshu-jenkins-agent'
        MASTER_NODE = 'master-node'
    }
    stages {
        stage('Checkout to Master') {
            // agent {
            //     node "${MASTER_NODE}"
            // }
            steps {
                git branch: 'master', url: 'https://github.com/deepanshu-rawat6/demo-spring-application'
            }
        }

        stage('Validate Tools') {
            agent { label "${TERRAFORM_INSTANCES}" }
            steps {
                sh '''
                    echo "Validating Java and Maven tools:"
                    java --version || { echo "Java not found!"; exit 1; }
                    mvn --version || { echo "Maven not found!"; exit 1; }
                '''
            }
        }

        stage('Build Application') {
            // agent { label "${TERRAFORM_INSTANCES}" }
            steps {
                sh '''
                    echo "Setting up JAR name dynamically in pom.xml"
                    sed -i 's/<finalName>.*<\\/finalName>/<finalName>${JAR_NAME}<\\/finalName>/' pom.xml

                    echo "Starting build process..."
                    mvn clean install -Djar.finalName=${JAR_NAME}
                    ls -la
                '''
            }
        }
        stage('Find Generated JAR') {
            // agent { label "${TERRAFORM_INSTANCES}" }
            steps {
                script {
                    sh '''
                        echo "Searching for generated JAR:"
                        find target -name "*.jar" -exec ls -lh {} \\;
                    '''
                }
            }
        }

        stage('Verify and Run Docker') {
            // agent { label "${TERRAFORM_INSTANCES}" }
            steps {
                sh '''
                    echo "Verifying Docker installation..."
                    sudo docker --version || { echo "Docker not found!"; exit 1; }

                    echo "Testing a secure Docker container:"
                    sudo docker run hello-world
                '''
            }
        }

        stage('Upload JAR to S3') {
            // agent { label "${TERRAFORM_INSTANCES}" }
            steps {
                sh '''
                    echo "Uploading JAR to secure S3 bucket..."
                    ls ./target
                    aws s3 cp ./target/SpringBootFirst-0.0.1-SNAPSHOT.jar s3://${S3_BUCKET}/my-builds/build.jar --sse AES256
                '''
            }
            post {
                success {
                    echo 'JAR uploaded to S3.'
                }
                failure {
                    echo 'JAR upload failed. Please check the logs.'
                }
            }
        }
    }
}
