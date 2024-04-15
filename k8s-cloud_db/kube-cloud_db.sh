#!/bin/bash

# Set the default region and project ID
gcloud config set project gke-project-417209
gcloud config set compute/region europe-west6
WORKING_DIR=./
PROJECT_ID=gke-project-417209

# Enable the GKE and Cloud SQL Admin APIs
gcloud services enable container.googleapis.com sqladmin.googleapis.com

# Create a GKE cluster named kube-cloud_db
export PROJECT_ID=gke-project-417209
REGION=europe-west6
CLUSTER_NAME=kube-cloud-db
gcloud container clusters create-auto $CLUSTER_NAME --region $REGION

# Get credentials for the cluster
gcloud container clusters get-credentials $CLUSTER_NAME

kubectl apply -f ./wordpress-volumeclaim.yaml
kubectl get persistentvolumeclaim

# Create a Cloud SQL for MySQL instance
INSTANCE_NAME=mysql-wordpress-instance
gcloud sql instances create $INSTANCE_NAME --region $REGION

# Set the instance connection name
export INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME --format='value(email)')

# Create a database and user for WordPress
gcloud sql databases create wordpress --instance $INSTANCE_NAME
CLOUD_SQL_PASSWORD=o40QgGz+dEMvqfI4idMWBypb
gcloud sql users create wordpress --host=% --instance $INSTANCE_NAME --password $CLOUD_SQL_PASSWORD

# Create a service account for the Cloud SQL proxy
gcloud iam service-accounts create cloudsql-proxy --display-name cloudsql-proxy
gcloud iam service-accounts list --filter=displayName:cloudsql-proxy
gcloud projects add-iam-policy-binding $PROJECT_ID --role roles/editor --member serviceAccount:cloudsql-proxy@gke-project-417209.iam.gserviceaccount.com
gcloud iam service-accounts keys create ./secrets/key.json --iam-account cloudsql-proxy@gke-project-417209.iam.gserviceaccount.com

# Create Kubernetes secrets for MySQL credentials and service account
kubectl create secret generic cloudsql-db-credentials --from-literal username=wordpress --from-literal password=$CLOUD_SQL_PASSWORD --from-literal address=$INSTANCE_CONNECTION_NAME
kubectl create secret generic cloudsql-instance-credentials --from-file ./secrets/key.json

# Deploy WordPress
#kubectl create -f ./wordpress-cloudsql.yaml
#kubectl get pod -l app=wordpress --watch
#kubectl create -f ./wordpress-service.yaml
#kubectl get svc -l app=wordpress --watch