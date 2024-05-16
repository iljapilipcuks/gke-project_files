#!/bin/bash

# Set the default region and project ID
gcloud config set project gke-project-417209
gcloud config set compute/region europe-west6
# $1-ip address of tested application
SRVADD=$1

# Pull the latest version of bombardier program image
docker pull alpine/bombardier:latest

# Bombarding our service for 10s using 250 connections
docker run -ti --rm alpine/bombardier -c 250 -d 10s -l $SRVADD >> container_250_01.txt

# Bombarding our service for 30s using 500 connections
docker run -ti --rm alpine/bombardier -c 500 -d 30s -l $SRVADD >> container_500_02.txt

# Bombarding our service for 30s using 1000 connections
docker run -ti --rm alpine/bombardier -c 1000 -d 60s -l $SRVADD >> container_1000_03.txt
