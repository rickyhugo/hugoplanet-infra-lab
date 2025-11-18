#!/usr/bin/env bash

source .env

kubectl create namespace tailscale
kubectl create secret generic operator-oauth \
  -n tailscale \
  --from-literal=client_id="$TAILSCALE_CLIENT_ID" \
  --from-literal=client_secret="$TAILSCALE_CLIENT_SECRET"
