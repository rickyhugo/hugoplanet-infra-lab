#!/usr/bin/env bash

curl -sfL https://get.k3s.io | sh -s - --disable=servicelb --disable=traefik --disable=metrics-server

sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$USER":"$USER" "$HOME/.kube/config"
sudo chmod 600 "$HOME/.kube/config"
