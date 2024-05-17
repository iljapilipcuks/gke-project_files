#!/bin/bash

# Setting up the default region and project ID
gcloud config set project gke-project-417209
gcloud config set compute/region europe-west6
PROJECT_ID=gke-project-417209
REGION=europe-west6

# Enable the GKE and Cloud SQL Admin APIs
gcloud services enable container.googleapis.com sqladmin.googleapis.com

# Create a GKE cluster named k8s-wordpress
CLUSTER_NAME=k8s-wordpress
gcloud container clusters create-auto $CLUSTER_NAME --region $REGION

# Get credentials for the cluster
gcloud container clusters get-credentials $CLUSTER_NAME

# Create a Cloud SQL for MySQL instance
INSTANCE_NAME=mysql-instance
gcloud sql instances create $INSTANCE_NAME --region $REGION --network=default --authorized-networks=0.0.0.0/0

# Set the instance connection private address
SQL_ADDRESS=$(gcloud sql instances list --filter=name:$INSTANCE_NAME --format="value(PRIVATE_ADDRESS)")

# Create a database and user for WordPress
CLOUD_SQL_PASSWORD=sqlpassword
gcloud sql databases create wordpress --instance $INSTANCE_NAME
gcloud sql users create wordpress --host=% --instance $INSTANCE_NAME --password $CLOUD_SQL_PASSWORD

# Create secret for database credentials, name and address
kubectl create secret generic cloudsql-db-credentials --from-literal username=wordpress --from-literal password=$CLOUD_SQL_PASSWORD --from-literal db_host=$SQL_ADDRESS --from-literal database=wordpress

# Deploy WordPress config files
kubectl create -f ./wordpress-cloudsql.yaml
kubectl get pod -l app=wordpress
kubectl get svc -l app=wordpress