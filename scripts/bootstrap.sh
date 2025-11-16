#!/usr/bin/env bash

helm install argo-cd charts/argo-cd/ --namespace argo --create-namespace
helm template charts/root-app/ --namespace argo | kubectl apply -f -

kubectl delete secret -n argo -l owner=helm,name=argo-cd
