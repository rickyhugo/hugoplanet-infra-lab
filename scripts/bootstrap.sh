#!/usr/bin/env bash

helm template root-app/ | kubectl apply -f -
