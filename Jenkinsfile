pipeline {
    agent {
        label 'deepanshu-jenkins-agent'
    }

    stages {
       stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/deepanshu-rawat6/demo-spring-application'
            }
       }

       stage('Build') {
        steps {
            sh 'mvn clean && mvn install'
        }
       }
    }
}