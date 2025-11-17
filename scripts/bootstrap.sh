#!/usr/bin/env bash

helm install argo-cd charts/argo-cd/ --namespace argocd --create-namespace

kubectl config set-context --current --namespace=argocd
argocd login --core
argocd app create apps \
  --dest-namespace argocd \
  --dest-server https://kubernetes.default.svc \
  --repo https://github.com/rickyhugo/hugoplanet-infra-lab.git \
  --revision main \
  --path apps
argocd app sync apps

kubectl delete secret -n argocd -l owner=helm,name=argo-cd
