pipeline {
    agent {
        label 'spot-build-agents'
    }

    environment {
        JAR_NAME = "demo-spring-application.jar"
        TARGET_DIR = "/home/jenkins/deployments"
        AGENT_LABEL = "deepanshu-jenkins-agent"
    }


    stages {
        stage('Starting build process') {
            agent { label "${AGENT_LABEL}"}
            steps {
                sh 'java --version'
                sh 'mvn --version'
            }
        }

       stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/deepanshu-rawat6/demo-spring-application'
            }

       }

       stage('Build') {
        steps {
            sh 'mvn clean && mvn install'
            sh 'mkdir -d target-jar && cp target/*.jar target-jar/${JAR_NAME}'
        }
       }

       stage('Testing docker on spot instance') {
        steps {
            sh '''
            docker --version
            sudo docker run hello-world
            '''
        }
       }

        stage('Deploy JAR to ECS Agent') {
            agent { label "${AGENT_LABEL}" }
            steps {
                script {
                    echo "Transferring the JAR file to the deployment directory..."
                    sh """
                        mkdir -p ${TARGET_DIR}
                        scp -o StrictHostKeyChecking=no -r ${WORKSPACE}/target-jar/${JAR_NAME} ${TARGET_DIR}/${JAR_NAME}
                    """

                    echo "Running the JAR file on the target agent..."
                    sh """
                        nohup java -jar ${TARGET_DIR}/${JAR_NAME} > ${TARGET_DIR}/application.log 2>&1 &
                    """
                }
            }
        }
    }
}