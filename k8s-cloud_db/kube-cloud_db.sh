#!/bin/bash

# Set the default region and project ID
gcloud config set project gke-project-417209
gcloud config set compute/region europe-west6
WORKING_DIR=/home/ilja_pilipchuks/Project/k8s-cloud_db
PROJECT_ID=gke-project-417209
VPC_NETWORK=internal-vpc

# Enable the GKE and Cloud SQL Admin APIs
gcloud services enable container.googleapis.com sqladmin.googleapis.com

"""
# Create a VPC network
gcloud compute networks create $VPC_NETWORK \
    --subnet-mode custom \
    --project $PROJECT_ID

# Create a subnet for GKE cluster
gcloud compute networks subnets create gke-subnet \
    --network $VPC_NETWORK \
    --region $REGION \
    --range 10.0.0.0/24

# Create a subnet for Cloud SQL
gcloud compute networks subnets create sql-subnet \
    --network $VPC_NETWORK \
    --region $REGION \
    --range 10.0.1.0/24

# Allow traffic from GKE subnet to Cloud SQL subnet
gcloud compute firewall-rules create allow-gke-to-sql \
    --network $VPC_NETWORK \
    --allow tcp:3306 \
    --source-ranges 10.0.0.0/24 \
#    --target-tags sql

# Allow traffic from Cloud SQL subnet to GKE subnet
gcloud compute firewall-rules create allow-sql-to-gke \
    --network internal-vpc \
    --allow tcp:80,tcp:443 \
    --source-ranges 10.0.1.0/24 \
#    --target-tags gke
"""
# Create a GKE cluster named kube-cloud_db
export PROJECT_ID=gke-project-417209
REGION=europe-west6
CLUSTER_NAME=kube-cloud-db
gcloud container clusters create-auto $CLUSTER_NAME --region $REGION

# Get credentials for the cluster
gcloud container clusters get-credentials $CLUSTER_NAME

# Create a PVC for WordPress storage
kubectl apply -f $WORKING_DIR/wordpress-volumeclaim.yaml

# Create a Cloud SQL for MySQL instance
INSTANCE_NAME=mysql-wordpress-instance
gcloud sql instances create $INSTANCE_NAME --tier=db-f1-micro --region $REGION

# Set the instance connection name
export INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME --format='value(connectionName)')

# Create a database and user for WordPress
gcloud sql databases create wordpress --instance $INSTANCE_NAME
CLOUD_SQL_PASSWORD=sql_password
gcloud sql users create wordpress --host=% --instance $INSTANCE_NAME --password $CLOUD_SQL_PASSWORD

# Create a service account for the Cloud SQL proxy
gcloud iam service-accounts create cloudsql-proxy --display-name cloudsql-proxy
gcloud iam service-accounts list --filter=displayName:cloudsql-proxy
SA_EMAIL=$(gcloud iam service-accounts list --filter=displayName:cloudsql-proxy --format='value(email)')
gcloud projects add-iam-policy-binding $PROJECT_ID --role roles/cloudsql.client --member serviceAccount:$SA_EMAIL
gcloud iam service-accounts keys create $WORKING_DIR/secrets/key.json --iam-acocunt $SA_EMAIL

# Create Kubernetes secrets for MySQL credentials and service account
kubectl create secret generic cloudsql-db-credentials --from-literal username=wordpress --from-literal password=$CLOUD_SQL_PASSWORD
kubectl create secret generic cloudsql-instance-credentials --from-file $WORKING_DIR/secrets/key.json

# Deploy WordPress
#kubectl create -f ./wordpress-cloudsql.yaml
#kubectl get pod -l app=wordpress --watch
#kubectl get svc -l app=wordpress