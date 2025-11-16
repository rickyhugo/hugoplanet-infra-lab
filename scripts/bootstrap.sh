#!/usr/bin/env bash

helm install argo-cd charts/argo-cd/
helm template charts/root-app/ | kubectl apply -f -
