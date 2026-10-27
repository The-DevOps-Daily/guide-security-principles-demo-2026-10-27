#!/usr/bin/env bash
# Part 1 on a kind cluster
# Generated from the guide source: every command below is shown in the guide,
# and its output there comes from the captures this script writes.
set -uo pipefail
source "$(dirname "$(readlink -f "$0")")/lib.sh"
capture p1-k8s-01 0 <<'__CMD__'
docker buildx imagetools inspect python:3.14.7-alpine3.24 | sed -n 1,3p
__CMD__
capture p1-k8s-02 0 <<'__CMD__'
cd ~/security-principles-demo/part01
__CMD__
capture p1-k8s-03 0 <<'__CMD__'
kind create cluster --config kind.yaml --quiet
__CMD__
capture p1-k8s-04 0 <<'__CMD__'
kubectl wait --for=condition=Ready nodes --all --timeout=180s >/dev/null
__CMD__
capture p1-k8s-05 0 <<'__CMD__'
kubectl get nodes -L topology.kubernetes.io/zone
__CMD__
capture p1-k8s-06 0 <<'__CMD__'
kubectl create namespace shop
__CMD__
capture p1-k8s-07 0 <<'__CMD__'
kubectl apply -f postgres.yaml -f worker.yaml
__CMD__
capture p1-k8s-08 0 <<'__CMD__'
kubectl -n shop create configmap api-code --from-file=server.py
__CMD__
capture p1-k8s-09 1 <<'__CMD__'
kubectl apply -f api-broken.yaml
__CMD__
capture p1-k8s-10 0 <<'__CMD__'
kubectl apply -f api.yaml -f pdb.yaml
__CMD__
capture p1-k8s-11 0 <<'__CMD__'
kubectl -n shop rollout status deployment/api --timeout=180s
__CMD__
capture p1-k8s-12 0 <<'__CMD__'
kubectl -n shop get pods -l app=api -o custom-columns=POD:.metadata.name,NODE:.spec.nodeName,READY:.status.containerStatuses[0].ready
__CMD__
capture p1-k8s-13 0 <<'__CMD__'
kubectl -n shop get pdb api
__CMD__
capture p1-k8s-14 0 <<'__CMD__'
kubectl -n shop scale deployment/postgres --replicas=0
__CMD__
capture p1-k8s-15 0 <<'__CMD__'
kubectl -n shop wait --for=condition=Ready=false pod -l app=api --timeout=90s
__CMD__
capture p1-k8s-16 0 <<'__CMD__'
kubectl -n shop get pods -l app=api
__CMD__
capture p1-k8s-17 0 <<'__CMD__'
kubectl -n shop get endpointslices -l kubernetes.io/service-name=api -o custom-columns=NAME:.metadata.name,READY:.endpoints[*].conditions.ready
__CMD__
capture p1-k8s-18 0 <<'__CMD__'
kubectl -n shop scale deployment/postgres --replicas=1 && kubectl -n shop wait --for=condition=Ready pod -l app=api --timeout=180s
__CMD__
finish
