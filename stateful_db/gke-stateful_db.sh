#!/bin/bash

# Setting up the default region and project ID
gcloud config set compute/region $REGION
gcloud config set project gke-project-417209
REGION=europe-west6
CLUSTER_NAME=kube-stateful-db
gcloud services enable container.googleapis.com sqladmin.googleapis.com

gcloud container clusters create $CLUSTER_NAME \
  --num-nodes 1 \
  --machine-type n1-standard-2 \
  --region $REGION

# Get credentials for the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION

kubectl apply -k ./
kubectl get svc -l app=wordpress