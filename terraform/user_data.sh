#!/bin/bash

# Update and upgrade
sudo apt update -y && sudo apt upgrade -y && sudo apt install -y docker.io openjdk-21-jdk maven

sudo systemctl enable docker

# Setting paths for maven
echo "export MAVEN_HOME=/usr/share/maven" | sudo tee /etc/profile.d/maven.sh
echo "export MAVEN_CONFIG=/etc/maven" | sudo tee -a /etc/profile.d/maven.sh
echo "export PATH=\$MAVEN_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/maven.sh
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# Adding the user to docker(for non-sudo access)
sudo usermod -aG docker $USER

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS ECS
export AWS_REGION="us-east-1"
export OS_PACKAGE="amd64.deb"

# Installing ECS-Init Agent to register the EC2 Instances as Container Instances for ECS Cluster to run tasks
curl -O https://s3.${AWS_REGION}.amazonaws.com/amazon-ecs-agent-${AWS_REGION}/amazon-ecs-init-latest.${OS_PACKAGE}
sudo dpkg -i amazon-ecs-init-latest.${OS_PACKAGE}

sudo sed -i '/\[Unit\]/a After=cloud-final.service' /lib/systemd/system/ecs.service
echo "ECS_CLUSTER=<"CLUSTER_NAME">" | sudo tee /etc/ecs/ecs.config

sudo systemctl enable ecs
sudo systemctl daemon-reload

sudo systemctl start docker
sudo systemctl start ecs

sudo systemctl reboot
