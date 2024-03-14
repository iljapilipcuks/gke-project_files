#!/bin/bash

# Set the default region and project ID
#gcloud config set compute/region europe-west1
#export PROJECT_ID=project-diss2024
mkdir ./kube-cloud_db
cd kube-cloud_db
git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/quickstarts/wordpress-persistent-disks/ .
WORKING_DIR=/kube-cloud_db/wordpress-persistent-disks

# Enable the GKE and Cloud SQL Admin APIs
#gcloud services enable container.googleapis.com sqladmin.googleapis.com

# Create a GKE cluster named 'kube-cloud_db'
CLUSTER_NAME=kube-cloud-db
gcloud container clusters create-auto $CLUSTER_NAME

# Get credentials for the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --region europe-west1

# Create a PVC for WordPress storage
kubectl apply -f wordpress-volumeclaim.yaml

# Create a Cloud SQL for MySQL instance
INSTANCE_NAME=wordpress-cloud-sql
gcloud sql instances create $INSTANCE_NAME

# Set the instance connection name
export INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME --format='value(connectionName)')

# Create a database and user for WordPress
gcloud sql databases create wordpress --instance $INSTANCE_NAME
CLOUD_SQL_PASSWORD=SQL_PASS
gcloud sql users create wordpress --host=% --instance $INSTANCE_NAME --password $CLOUD_SQL_PASSWORD

# Create a service account for the Cloud SQL proxy
SA_NAME=cloudsql-proxy
gcloud iam service-accounts create $SA_NAME --display-name $SA_NAME
SA_EMAIL=$(gcloud iam service-accounts list --filter=displayName:$SA_NAME --format='value(email)')
gcloud projects add-iam-policy-binding $PROJECT_ID --role roles/cloudsql.client --member serviceAccount:$SA_EMAIL
gcloud iam service-accounts keys create key.json --iam-account $SA_EMAIL

# Create Kubernetes secrets for MySQL credentials and service account
kubectl create secret generic cloudsql-db-credentials --from-literal username=wordpress --from-literal password=$CLOUD_SQL_PASSWORD
kubectl create secret generic cloudsql-instance-credentials --from-file key.json

# Deploy WordPress
cat $WORKING_DIR/wordpress_cloudsql.yaml.template | envsubst > $WORKING_DIR/wordpress_cloudsql.yaml
kubectl create -f $WORKING_DIR/wordpress_cloudsql.yaml

# Expose the WordPress service
kubectl create -f wordpress-service.yaml

# Clean up resources (uncomment to use)
# kubectl delete service wordpress
# kubectl delete deployment wordpress
# kubectl delete pvc wordpress-volumeclaim
# gcloud container clusters delete $CLUSTER_NAME
# gcloud sql instances delete $INSTANCE_NAME
# gcloud projects remove-iam-policy-binding $PROJECT_ID --role roles/cloudsql.client --member serviceAccount:$SA_EMAIL
# gcloud iam service-accounts delete $SA_EMAIL
