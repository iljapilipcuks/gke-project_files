#!/bin/bash

# Setting up the default region and project ID
PROJECT_ID=gke-project-417209
REGION=europe-west6
CLUSTER_NAME=kube-stateful-db
gcloud config set project $PROJECT_ID       
gcloud config set compute/region $REGION
gcloud services enable container.googleapis.com sqladmin.googleapis.com

gcloud container clusters create-auto $CLUSTER_NAME --region $REGION

# Get credentials for the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION

kubectl apply -k ./
kubectl get svc -l app=wordpress