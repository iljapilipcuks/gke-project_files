#!/bin/bash

# Packages installed for testing:
# sudo apt-get update
# sudo apt-get install -y bombardier
# sudo apt-get install -y default-mysql-client
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# $1-ip address of tested application
SRVADD=$1

# Pull the latest version of bombardier program image
docker pull alpine/bombardier:latest

# Bombarding our service for 10s using 2500 requests
docker run -ti --rm alpine/bombardier -c 2500 -d 60s -l $SRVADD >> bombardier_2500.txt

# Bombarding our service for 30s using 5000 requests
docker run -ti --rm alpine/bombardier -c 5000 -d 60s -l $SRVADD >> bombardier_5000.txt

# Bombarding our service for 30s using 10000 requests
docker run -ti --rm alpine/bombardier -c 10000 -d 60s -l $SRVADD >> bombardier_10000.txt
