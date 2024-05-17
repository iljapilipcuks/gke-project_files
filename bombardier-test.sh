#!/bin/bash

# Packages installed for testing:
# apt-get update
# apt-get install bombardier
# apt-get install default-mysql-client
# apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# $1-ip address of tested application
SRVADD=$1

# Pull the latest version of bombardier program image
docker pull alpine/bombardier:latest

# Bombarding our service for 10s using 2500 requests
docker run -ti --rm alpine/bombardier -c 2500 -d 60s -l $SRVADD >> bombardier_250.txt

# Bombarding our service for 30s using 5000 requests
docker run -ti --rm alpine/bombardier -c 2500 -d 60s -l $SRVADD >> bombardier_500.txt

# Bombarding our service for 30s using 10000 requests
docker run -ti --rm alpine/bombardier -c 5000 -d 60s -l $SRVADD >> bombardier_1000.txt
