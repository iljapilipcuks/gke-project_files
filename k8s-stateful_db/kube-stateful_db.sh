#!/bin/bash

REGION=europe-west6
gcloud config set compute/region $REGION
WORKING_DIR=/home/ilja_pilipchuks/Project/k8s-stateful_db/
PROJECT_ID=gke-project-417209
CLUSTER_NAME=kube-stateful-db
gcloud services enable container.googleapis.com sqladmin.googleapis.com

gcloud container clusters create-auto $CLUSTER_NAME --region $REGION

# Get credentials for the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION

kubectl apply -k ./