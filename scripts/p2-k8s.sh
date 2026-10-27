#!/usr/bin/env bash
# Part 2 on the kind cluster from Part 1
# Generated from the guide source: every command below is shown in the guide,
# and its output there comes from the captures this script writes.
set -uo pipefail
source "$(dirname "$(readlink -f "$0")")/lib.sh"
capture p2-k8s-01 0 <<'__CMD__'
cd ~/security-principles-demo/part02
__CMD__
capture p2-k8s-02 0 <<'__CMD__'
kubectl apply -f netpol.yaml
__CMD__
capture p2-k8s-03 0 <<'__CMD__'
kubectl -n shop exec deploy/worker -- pg_isready -h postgres
__CMD__
capture p2-k8s-04 2 <<'__CMD__'
kubectl -n shop run intruder --image=postgres:18.6-alpine3.24@sha256:10a5c69a83035ab5239f5620d708520e8b28f5aa1f2b20143e6024532edadfb5 --restart=Never --rm -i --quiet -- pg_isready -h postgres -t 3
__CMD__
capture p2-k8s-05 0 <<'__CMD__'
kubectl -n shop get pods -l app=api
__CMD__
capture p2-k8s-06 0 <<'__CMD__'
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.3/standard-install.yaml >/dev/null
__CMD__
capture p2-k8s-07 0 <<'__CMD__'
kubectl apply --dry-run=server -f gateway.yaml
__CMD__
finish
