#!/usr/bin/env bash
# Part 4 on the kind cluster
# Generated from the guide source: every command below is shown in the guide,
# and its output there comes from the captures this script writes.
set -uo pipefail
source "$(dirname "$(readlink -f "$0")")/lib.sh"
capture p4-k8s-01 0 <<'__CMD__'
cd ~/security-principles-demo/part04
__CMD__
capture p4-k8s-02 0 <<'__CMD__'
kubectl apply -f impostor.yaml && kubectl -n shop wait --for=condition=Ready pod/impostor --timeout=120s
__CMD__
capture p4-k8s-03 0 <<'__CMD__'
kubectl -n shop exec impostor -- pg_isready -h postgres
__CMD__
capture p4-k8s-04 0 <<'__CMD__'
cd ~ && curl -sL https://istio.io/downloadIstio | ISTIO_VERSION=1.31.3 sh - >/dev/null
__CMD__
capture p4-k8s-05 0 <<'__CMD__'
export PATH="$HOME/istio-1.31.3/bin:$PATH" && cd ~/security-principles-demo/part04
__CMD__
capture p4-k8s-06 0 <<'__CMD__'
istioctl install --set profile=ambient --skip-confirmation >/dev/null
__CMD__
capture p4-k8s-07 0 <<'__CMD__'
kubectl -n istio-system get pods
__CMD__
capture p4-k8s-08 0 <<'__CMD__'
kubectl apply -f netpol-hbone.yaml
__CMD__
capture p4-k8s-09 0 <<'__CMD__'
kubectl label namespace shop istio.io/dataplane-mode=ambient
__CMD__
capture p4-k8s-10 0 <<'__CMD__'
sleep 10; istioctl ztunnel-config workloads --workload-namespace shop
__CMD__
capture p4-k8s-11 0 <<'__CMD__'
kubectl -n shop exec deploy/worker -- pg_isready -h postgres
__CMD__
capture p4-k8s-12 0 <<'__CMD__'
kubectl apply -f mesh-policy.yaml
__CMD__
capture p4-k8s-13 0 <<'__CMD__'
sleep 5; kubectl -n shop exec deploy/worker -- pg_isready -h postgres
__CMD__
capture p4-k8s-14 2 <<'__CMD__'
kubectl -n shop exec impostor -- pg_isready -h postgres
__CMD__
capture p4-k8s-15 0 <<'__CMD__'
kubectl -n istio-system logs ds/ztunnel --since=2m | grep -m 1 'policy rejection'
__CMD__
capture p4-k8s-16 0 <<'__CMD__'
kubectl apply -f edge.yaml -f edge-jwt.yaml >/dev/null && kubectl -n edge wait --for=condition=Programmed gateway/edge --timeout=180s && kubectl -n edge wait --for=condition=Ready pod/client --timeout=120s
__CMD__
capture p4-k8s-17 0 <<'__CMD__'
samples=https://raw.githubusercontent.com/istio/istio/release-1.31/security/tools/jwt/samples
__CMD__
capture p4-k8s-18 0 <<'__CMD__'
user_token=$(curl -s $samples/demo.jwt) && admin_token=$(curl -s $samples/groups-scope.jwt)
__CMD__
capture p4-k8s-19 0 <<'__CMD__'
sleep 5; kubectl -n edge exec client -- curl -s -w ' (%{http_code})\n' http://edge-istio/events
__CMD__
capture p4-k8s-20 0 <<'__CMD__'
kubectl -n edge exec client -- curl -s -w ' (%{http_code})\n' http://edge-istio/admin/refunds
__CMD__
capture p4-k8s-21 0 <<'__CMD__'
kubectl -n edge exec -i client -- curl -s -w ' (%{http_code})\n' -H @- http://edge-istio/admin/refunds <<<"Authorization: Bearer $user_token"
__CMD__
capture p4-k8s-22 0 <<'__CMD__'
kubectl -n edge exec -i client -- curl -s -w ' (%{http_code})\n' -H @- http://edge-istio/admin/refunds <<<"Authorization: Bearer $admin_token"
__CMD__
capture p4-k8s-23 0 <<'__CMD__'
kubectl -n edge exec -i client -- curl -s -w ' (%{http_code})\n' -H @- http://edge-istio/admin/refunds <<<"Authorization: Bearer ${admin_token%.*}.${user_token##*.}"
__CMD__
finish
