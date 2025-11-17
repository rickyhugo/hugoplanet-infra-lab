#!/usr/bin/env bash

helm install argo-cd charts/argo-cd/ --namespace argocd --create-namespace

argocd app create apps \
  --dest-namespace argocd \
  --dest-server https://kubernetes.default.svc \
  --repo https://github.com/rickyhugo/hugoplanet-infra-lab.git \
  --path apps
argocd app sync apps

# helm template apps | kubectl apply -f -

# kubectl delete secret -n argocd -l owner=helm,name=argo-cd
