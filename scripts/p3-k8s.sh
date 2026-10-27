#!/usr/bin/env bash
# Part 3 on the kind cluster
# Generated from the guide source: every command below is shown in the guide,
# and its output there comes from the captures this script writes.
set -uo pipefail
source "$(dirname "$(readlink -f "$0")")/lib.sh"
capture p3-k8s-01 0 <<'__CMD__'
cd ~/security-principles-demo/part03
__CMD__
capture p3-k8s-02 0 <<'__CMD__'
kubectl apply -f rbac-deployer.yaml
__CMD__
capture p3-k8s-03 0 <<'__CMD__'
kubectl auth can-i --list -n shop --as=system:serviceaccount:shop:deployer
__CMD__
capture p3-k8s-04 1 <<'__CMD__'
kubectl auth can-i get secrets -n shop --as=system:serviceaccount:shop:deployer
__CMD__
capture p3-k8s-05 1 <<'__CMD__'
kubectl get secret postgres -n shop --as=system:serviceaccount:shop:deployer
__CMD__
capture p3-k8s-06 0 <<'__CMD__'
kubectl -n shop patch deployment worker --as=system:serviceaccount:shop:deployer --type=json -p '[{"op":"add","path":"/spec/template/spec/containers/0/env/-","value":{"name":"STOLEN","valueFrom":{"secretKeyRef":{"name":"postgres","key":"password"}}}}]'
__CMD__
capture p3-k8s-07 0 <<'__CMD__'
kubectl -n shop rollout status deployment/worker --timeout=120s >/dev/null && kubectl -n shop exec deploy/worker -- printenv STOLEN
__CMD__
capture p3-k8s-08 0 <<'__CMD__'
kubectl -n shop rollout undo deployment/worker && kubectl -n shop rollout status deployment/worker --timeout=120s
__CMD__
capture p3-k8s-09 0 <<'__CMD__'
kubectl -n shop get secret postgres -o jsonpath='{.data.password}' | base64 -d; echo
__CMD__
capture p3-k8s-10 0 <<'__CMD__'
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.roleRef.name == "cluster-admin") | .metadata.name + ": " + ([.subjects[]? | .kind + "/" + .name] | join(", "))'
__CMD__
capture p3-k8s-11 0 <<'__CMD__'
kubectl label --dry-run=server --overwrite namespace shop pod-security.kubernetes.io/enforce=restricted
__CMD__
capture p3-k8s-12 0 <<'__CMD__'
kubectl label --overwrite namespace shop pod-security.kubernetes.io/enforce=restricted pod-security.kubernetes.io/warn=restricted
__CMD__
capture p3-k8s-13 1 <<'__CMD__'
kubectl -n shop run debug --image=postgres:18.6-alpine3.24@sha256:10a5c69a83035ab5239f5620d708520e8b28f5aa1f2b20143e6024532edadfb5 -- sleep 3600
__CMD__
capture p3-k8s-14 1 <<'__CMD__'
kubectl -n shop exec deploy/api -- ls /var/run/secrets/kubernetes.io/serviceaccount
__CMD__
finish
