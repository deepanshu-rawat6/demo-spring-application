ARG DOCKER_PLATFORM="linux/amd64"
ARG ALPINE_VERSION="3.21"
ARG JDK_VERSION="jdk21"
ARG MAVEN_VERSION="3.9.9"

FROM jenkins/inbound-agent:alpine${ALPINE_VERSION}-${JDK_VERSION}

# Switch to root to install dependencies
USER root

# Install system dependencies including Docker
RUN apk add --no-cache \
    wget \
    git \
    python3 \
    py3-pip \
    bash \
    docker \
    docker-cli \
    aws-cli \
    docker-engine \
    openrc \
    && rc-update add docker boot

# Install Maven
RUN mkdir -p /opt/maven && \
    wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz -O /tmp/maven.tar.gz && \
    tar -zxvf /tmp/maven.tar.gz -C /opt/maven --strip-components=1 && \
    rm /tmp/maven.tar.gz

# Configure environment variables properly
ENV MAVEN_HOME=/opt/maven
ENV MAVEN_CONFIG=/home/jenkins/.m2
ENV PATH=${MAVEN_HOME}/bin:${PATH}

# Create Maven configuration directory and set permissions
RUN mkdir -p ${MAVEN_CONFIG} && \
    chown -R jenkins:jenkins ${MAVEN_CONFIG} && \
    chown -R jenkins:jenkins ${MAVEN_HOME}

# Add environment variables to profile
RUN echo "export MAVEN_HOME=${MAVEN_HOME}" >> /etc/profile.d/maven.sh && \
    echo "export MAVEN_CONFIG=${MAVEN_CONFIG}" >> /etc/profile.d/maven.sh && \
    echo "export PATH=${MAVEN_HOME}/bin:\${PATH}" >> /etc/profile.d/maven.sh && \
    chmod +x /etc/profile.d/maven.sh

# Source profile in .bashrc and .profile
RUN echo "source /etc/profile.d/maven.sh" >> /home/jenkins/.bashrc && \
    echo "source /etc/profile.d/maven.sh" >> /home/jenkins/.profile && \
    chown jenkins:jenkins /home/jenkins/.bashrc /home/jenkins/.profile

# Create necessary directories and set permissions for Docker
RUN mkdir -p /var/run/docker && \
    chown jenkins:jenkins /var/run/docker && \
    addgroup jenkins docker

# Verify installations
RUN source /etc/profile.d/maven.sh && \
    java --version && \
    mvn --version && \
    git --version && \
    python3 --version && \
    docker --version && \
    aws --version

# Clean up
RUN rm -rf /var/cache/apk/*

# Switch back to jenkins user
USER jenkins

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/jenkins-agent"]