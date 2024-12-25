#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

sudo apt install -y openjdk-21-jdk

java --version

sudo apt install -y maven

export MAVEN_HOME="/usr/share/maven"
export MAVEN_CONFIG="/etc/maven"
export PATH="$MAVEN_HOME/bin:$PATH"

# shellcheck disable=SC2129
sudo echo "export MAVEN_HOME=/usr/share/maven" >> /etc/profile.d/maven.sh
sudo echo "export MAVEN_CONFIG=/etc/maven" >> /etc/profile.d/maven.sh
sudo echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> /etc/profile.d/maven.sh
sudo chmod +x /etc/profile.d/maven.sh
sudo source /etc/profile.d/maven.sh

sudo usermod -aG docker $USER

sudo snap install aws-cli --classic

sudo systemctl restart docker

export AWS_REGION="us-east-1"
export OS_PACKAGE="amd64.deb"

curl -O https://s3.${AWS_REGION}.amazonaws.com/amazon-ecs-agent-${AWS_REGION}/amazon-ecs-init-latest.${OS_PACKAGE}
sudo dpkg -i amazon-ecs-init-latest.${OS_PACKAGE}

sudo sed -i '/\[Unit\]/a After=cloud-final.service' /lib/systemd/system/ecs.service

echo "ECS_CLUSTER=ecs-jenkins-cluster" | sudo tee /etc/ecs/ecs.config

sudo systemctl enable ecs
sudo systemctl daemon-reload
sudo systemctl restart ecs
sudo systemctl reboot

# JENKINS_URL??
#mkdir -p /var/lib/jenkins
#wget -O /tmp/agent.jar http://<JENKINS_URL>/jnlpJars/agent.jar
#
## shellcheck disable=SC2261
#java -jar /tmp/agent.jar -jnlpUrl http://<JENKINS_URL>/computer/spot-agent/slave-agent.jnlp -secret <SECRET> -workDir "/var/lib/jenkins"