#!/bin/bash

kubectl delete service wordpress
kubectl delete deployment wordpress
kubectl delete pvc wordpress-volumeclaim
gcloud container clusters delete $CLUSTER_NAME
gcloud sql instances delete $INSTANCE_NAME



kubectl delete service wordpress
kubectl delete deployment wordpress
kubectl delete service wordpress-mysql
kubectl delete deployment wordpress-mysql
kubectl delete pvc wp-pv-claim
kubectl delete pvc mysql-pv-claim
gcloud container clusters delete $CLUSTER_NAME
