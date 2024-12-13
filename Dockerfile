ARG DOCKER_PLATFORM="linux/amd64"
ARG ALPINE_VERSION="3.21"
ARG JDK_VERSION="jdk21"
#ARG MAVEN_VERSION=3.9.9
#ARG BASE_URL=https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz

FROM jenkins/inbound-agent:alpine${ALPINE_VERSION}-${JDK_VERSION}

# Being a root user to install dependencies
USER root

# Install wget
RUN apk add --no-cache \
    wget \
    git \
    python3 \
    py3-pip

# Maven installation
RUN mkdir -p /opt/maven && \
    wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz -O /tmp/maven.tar.gz && \
    tar -zxvf /tmp/maven.tar.gz -C /opt/maven --strip-components=1 && \
    rm /tmp/maven.tar.gz

ENV MAVEN_HOME=/opt/maven
ENV MAVEN_CONFIG="/home/jenkins/.m2"
ENV PATH=$MAVEN_HOME/bin:$PATH

# AWS-cli just in case
#RUN pip3 install --no-cache-dir awscli
#RUN apk add --no-cache-dir awscli

# Docker -> just in case
#RUN apk add --no-cache docker-cli

RUN java --version && \
    mvn --version && \
    git --version && \
    python3 --version

RUN rm -rf /var/cache/apk/*

USER jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]