#!/usr/bin/env bash

source scripts/init_secrets.sh

helm install argo-cd charts/argo-cd/ \
  --namespace argocd \
  --create-namespace \
  --wait

kubectl config set-context --current --namespace=argocd
argocd login --core
argocd app create apps \
  --dest-namespace argocd \
  --dest-server https://kubernetes.default.svc \
  --repo https://github.com/rickyhugo/hugoplanet-infra-lab.git \
  --revision main \
  --path apps
argocd app sync apps
