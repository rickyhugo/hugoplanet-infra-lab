#!/usr/bin/env bash

helm install argo-cd charts/argo-cd/
helm template apps | kubectl apply -f -

kubectl delete secret -n argo -l owner=helm,name=argo-cd
