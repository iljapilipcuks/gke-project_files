#!/bin/bash

REGION=europe-west3
CLUSTER_NAME=k8s-stateful-db
gcloud container clusters create-auto $CLUSTER_NAME --region $REGION

# Get credentials for the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION

cat <<EOF >./kustomization.yaml
secretGenerator:
- name: mysql-pass
  literals:
  - password=SQL_PASS
resources:
  - mysql-deployment.yaml
  - wordpress-deployment.yaml
EOF

# Create a PVC for WordPress storage
kubectl apply -f mysql-deployment.yaml

kubectl apply -f wordpress-deployment.yaml
