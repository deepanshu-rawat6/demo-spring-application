#!/bin/bash

set -e

# Update and upgrade
sudo apt update -y 

# Installing Java 21
sudo apt install -y openjdk-21-jdk maven

# Setting paths for maven
echo "export MAVEN_HOME=/usr/share/maven" | sudo tee /etc/profile.d/maven.sh
echo "export MAVEN_CONFIG=/etc/maven" | sudo tee -a /etc/profile.d/maven.sh
echo "export PATH=\$MAVEN_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/maven.sh
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# Adding the user to docker(for non-sudo access)
sudo usermod -aG docker $USER
