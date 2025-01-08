ARG DOCKER_PLATFORM="linux/amd64"
ARG ALPINE_VERSION="3.21"
ARG JDK_VERSION="jdk21"
ARG MAVEN_VERSION="3.9.9"
ARG AWS_CLI_VERSION="2.12.2" # Specify the version of AWS CLI to install

FROM jenkins/inbound-agent:alpine${ALPINE_VERSION}-${JDK_VERSION}

USER root

# Update libcurl and install Docker client
RUN apk add --no-cache -u libcurl curl

# Install system dependencies including Docker
RUN apk add --no-cache \
    wget \
    python3 \
    py3-pip \
    docker \
    aws-cli \
    docker-cli 

# Install Maven
RUN mkdir -p /opt/maven && \
    wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz   -O /tmp/maven.tar.gz && \ 
    tar -zxvf /tmp/maven.tar.gz -C /opt/maven --strip-components=1 && \
    rm /tmp/maven.tar.gz

# Configure environment variables for Maven
ENV MAVEN_HOME=/opt/maven
ENV MAVEN_CONFIG=/home/jenkins/.m2
ENV PATH=${MAVEN_HOME}/bin:${PATH}

# Create Maven config directory and set permissions
RUN mkdir -p ${MAVEN_CONFIG} && \
    chown -R jenkins:jenkins ${MAVEN_CONFIG} ${MAVEN_HOME}

RUN echo "export MAVEN_HOME=${MAVEN_HOME}" >> /etc/profile.d/maven.sh && \
    echo "export MAVEN_CONFIG=${MAVEN_CONFIG}" >> /etc/profile.d/maven.sh && \
    echo "export PATH=${MAVEN_HOME}/bin:\${PATH}" >> /etc/profile.d/maven.sh && \
    chmod +x /etc/profile.d/maven.sh

RUN echo "source /etc/profile.d/maven.sh" >> /home/jenkins/.bashrc && \
    echo "source /etc/profile.d/maven.sh" >> /home/jenkins/.profile && \
    chown jenkins:jenkins /home/jenkins/.bashrc /home/jenkins/.profile

# Ensure that 'jenkins' user is added to the 'docker' group
RUN apk add --no-cache shadow && \
    mkdir -p /var/run/docker && \
    chown jenkins:jenkins /var/run/docker && \
    addgroup jenkins docker && \
    chmod 666 /var/run/docker.sock

RUN source /etc/profile.d/maven.sh && \
    java --version && \
    mvn --version && \
    git --version && \
    python3 --version && \
    docker --version && \
    aws --version

RUN touch /debug-flag

USER jenkins
