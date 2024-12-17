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

stage('Advanced JAR Search on Master') {
    agent { node 'master-node' }
    steps {
        script {
            sh '''
                echo "Comprehensive JAR Search on Master Node:"

                # Define search paths
                SEARCH_PATHS="
                    .
                    $HOME
                    $HOME/.m2
                    $WORKSPACE
                    /opt/jenkins
                "

                # Track found JARs
                FOUND_JARS=""

                # Search across multiple paths
                for path in $SEARCH_PATHS; do
                    echo "Searching in: $path"
                    JAR_RESULTS=$(find "$path" -name "${JAR_NAME}" 2>/dev/null)
                    if [ -n "$JAR_RESULTS" ]; then
                        echo "Found JAR(s) in $path:"
                        echo "$JAR_RESULTS"
                        FOUND_JARS="${FOUND_JARS}${JAR_RESULTS}
"
                    fi
                done

                # Verify and display JAR details
                if [ -n "$FOUND_JARS" ]; then
                    echo "\\nDetailed JAR Information:"
                    echo "$FOUND_JARS" | while read -r jar; do
                        if [ -n "$jar" ]; then
                            echo "File: $jar"
                            ls -l "$jar"
                            file "$jar"
                            md5sum "$jar"
                            echo "---"
                        fi
                    done
                else
                    echo "No JAR file named ${JAR_NAME} found!"
                    exit 1
                fi
            '''
        }
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