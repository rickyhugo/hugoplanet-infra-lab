#!/usr/bin/env bash

source .env

kubectl create namespace tailscale
kubectl create secret generic operator-oauth \
  -n tailscale \
  --from-literal=client_id="$TAILSCALE_CLIENT_ID" \
  --from-literal=client_secret="$TAILSCALE_CLIENT_SECRET"

kubectl create namespace cert-manager
kubectl -n cert-manager create secret generic cloudflare-api-token \
  --from-literal=api-token="$CLOUDFLARE_API_TOKEN"

kubectl create namespace external-dns
kubectl -n external-dns create secret generic cloudflare-api-token \
  --from-literal=api-token="$CLOUDFLARE_API_TOKEN"
