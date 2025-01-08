#!/bin/bash

set -e

# Update and upgrade
sudo apt update -y && sudo apt upgrade -y

# Installing docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Installing Java 21
sudo apt install -y openjdk-21-jdk
java --version

# Installing maven: latest
sudo apt install -y maven

# Setting paths for maven
echo "export MAVEN_HOME=/usr/share/maven" | sudo tee /etc/profile.d/maven.sh
echo "export MAVEN_CONFIG=/etc/maven" | sudo tee -a /etc/profile.d/maven.sh
echo "export PATH=\$MAVEN_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/maven.sh
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# Adding the user to docker(for non-sudo access)
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
echo "ECS_CLUSTER=<"CLUSTER_NAME">" | sudo tee /etc/ecs/ecs.config

sudo systemctl start ecs

sudo systemctl enable ecs
sudo systemctl daemon-reload

sudo rm /var/lib/ecs/data/agent.db
sudo rm /var/lib/ecs/data/ecs_agent_data.json

sudo systemctl restart ecs

sudo reboot
