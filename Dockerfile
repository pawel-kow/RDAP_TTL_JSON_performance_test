FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    gcc \
    libjson-c-dev \
    openjdk-11-jdk \
    wget \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz && \
    rm go1.21.5.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/root/go

# Download Gson library for Java
RUN mkdir -p /opt/java/lib && \
    wget https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar \
    -O /opt/java/lib/gson-2.10.1.jar

# Set working directory
WORKDIR /app

# Copy test files
COPY src/python/ /app/python/
COPY src/c/ /app/c/
COPY src/java/ /app/java/
COPY src/go/ /app/go/
COPY data/ /data/

# Make Python script executable
RUN chmod +x /app/python/test_performance.py

# Compile C program
RUN gcc -O3 -o /app/c/test_performance /app/c/test_performance.c -ljson-c

# Compile Java program
RUN javac -encoding UTF-8 -cp /opt/java/lib/gson-2.10.1.jar /app/java/TestPerformance.java

# Build Go program
RUN cd /app/go && go build -o test_performance test_performance.go

# Create entrypoint script
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
