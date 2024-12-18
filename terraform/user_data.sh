#!/bin/bash

apt update -y && apt upgrade -y

apt install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker "$USER"

apt install -y openjdk-21-jdk

java --version

apt install -y maven

export MAVEN_HOME="/usr/share/maven"
export MAVEN_CONFIG="/etc/maven"
export PATH="$MAVEN_HOME/bin:$PATH"

# shellcheck disable=SC2129
echo "export MAVEN_HOME=/usr/share/maven" >> /etc/profile.d/maven.sh
echo "export MAVEN_CONFIG=/etc/maven" >> /etc/profile.d/maven.sh
echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> /etc/profile.d/maven.sh
chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

mvn --version

# JENKINS_URL??
#mkdir -p /var/lib/jenkins
#wget -O /tmp/agent.jar http://<JENKINS_URL>/jnlpJars/agent.jar
#
## shellcheck disable=SC2261
#java -jar /tmp/agent.jar -jnlpUrl http://<JENKINS_URL>/computer/spot-agent/slave-agent.jnlp -secret <SECRET> -workDir "/var/lib/jenkins"