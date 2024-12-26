#!/bin/bash

set -e

# Update and upgrade the system
sudo apt update -y && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Install Java
sudo apt install -y openjdk-21-jdk
java --version

# Install Maven
sudo apt install -y maven

# Configure Maven environment
echo "export MAVEN_HOME=/usr/share/maven" | sudo tee /etc/profile.d/maven.sh
echo "export MAVEN_CONFIG=/etc/maven" | sudo tee -a /etc/profile.d/maven.sh
echo "export PATH=\$MAVEN_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/maven.sh
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# Add user to Docker group
sudo usermod -aG docker $USER

# Install AWS CLI
sudo snap install aws-cli --classic

# Restart Docker service
sudo systemctl restart docker

# Configure AWS ECS
export AWS_REGION="us-east-1"
export OS_PACKAGE="amd64.deb"

curl -O https://s3.${AWS_REGION}.amazonaws.com/amazon-ecs-agent-${AWS_REGION}/amazon-ecs-init-latest.${OS_PACKAGE}
sudo dpkg -i amazon-ecs-init-latest.${OS_PACKAGE}

sudo sed -i '/\[Unit\]/a After=cloud-final.service' /lib/systemd/system/ecs.service
echo "ECS_CLUSTER=new-cluster" | sudo tee /etc/ecs/ecs.config

sudo systemctl enable ecs
sudo systemctl daemon-reload
sudo systemctl restart ecs

# Reboot the system to apply kernel upgrades
sudo reboot

# JENKINS_URL??
#mkdir -p /var/lib/jenkins
#wget -O /tmp/agent.jar http://<JENKINS_URL>/jnlpJars/agent.jar
#
## shellcheck disable=SC2261
#java -jar /tmp/agent.jar -jnlpUrl http://<JENKINS_URL>/computer/spot-agent/slave-agent.jnlp -secret <SECRET> -workDir "/var/lib/jenkins"