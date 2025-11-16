#!/usr/bin/env bash

helm install argo-cd charts/argo-cd/
helm template charts/root-app/ | kubectl apply -f -

kubectl delete secret -l owner=helm,name=argo-cd
