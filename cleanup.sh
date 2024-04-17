#!/bin/bash

kubectl delete service wordpress
kubectl delete deployment wordpress
kubectl delete pvc wordpress-volumeclaim
gcloud container clusters delete $CLUSTER_NAME
gcloud sql instances delete $INSTANCE_NAME