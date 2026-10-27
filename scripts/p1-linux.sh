#!/usr/bin/env bash
# Part 1 on Ubuntu 26.04, as the user dev
# Generated from the guide source: every command below is shown in the guide,
# and its output there comes from the captures this script writes.
set -uo pipefail
source "$(dirname "$(readlink -f "$0")")/lib.sh"
cd /home/dev
capture p1-linux-01 0 <<'__CMD__'
nc -lk 127.0.0.1 8099 >/dev/null & listener=$!
__CMD__
capture p1-linux-02 0 <<'__CMD__'
export PAYMENT_API_KEY='pay_live_Hq8Zt3Lw9Xr2Vb6Nc1Kd'
__CMD__
capture p1-linux-03 0 <<'__CMD__'
curl -s -m 5 -H "Authorization: Bearer $PAYMENT_API_KEY" http://127.0.0.1:8099/charges &
__CMD__
capture p1-linux-04 0 <<'__CMD__'
sleep 1; sudo -u nobody ps -o user=,args= -C curl
__CMD__
capture p1-linux-05 1 <<'__CMD__'
sudo -u nobody cat /proc/$!/environ
__CMD__
capture p1-linux-06 28 <<'__CMD__'
wait $!
__CMD__
capture p1-linux-07 0 <<'__CMD__'
curl -s -m 5 -H @- http://127.0.0.1:8099/charges <<<"Authorization: Bearer $PAYMENT_API_KEY" &
__CMD__
capture p1-linux-08 0 <<'__CMD__'
sleep 1; sudo -u nobody ps -o user=,args= -C curl
__CMD__
capture p1-linux-09 0 <<'__CMD__'
wait $!; kill $listener
__CMD__
capture p1-linux-10 0 <<'__CMD__'
git config --global user.name 'Dev' && git config --global user.email dev@example.com && git config --global init.defaultBranch main
__CMD__
capture p1-linux-11 0 <<'__CMD__'
git init -q ~/shop-config && cd ~/shop-config
__CMD__
capture p1-linux-12 0 <<'__CMD__'
printf 'PAYMENT_API_KEY=%s\n' "$PAYMENT_API_KEY" > .env && git add .env && git commit -q -m 'Add local settings'
__CMD__
capture p1-linux-13 0 <<'__CMD__'
git rm -q .env && git commit -q -m 'Remove secrets'
__CMD__
capture p1-linux-14 0 <<'__CMD__'
git log --oneline --stat
__CMD__
capture p1-linux-15 0 <<'__CMD__'
git show HEAD~1:.env
__CMD__
capture p1-linux-16 1 <<'__CMD__'
gitleaks git --no-banner --redact -v .
__CMD__
capture p1-linux-17 0 <<'__CMD__'
mkdir -p ~/release && cd ~/release
__CMD__
capture p1-linux-18 0 <<'__CMD__'
printf 'print("ticket shop api 1.4.0")\n' > app.py && tar -czf shop-api-1.4.0.tar.gz app.py
__CMD__
capture p1-linux-19 0 <<'__CMD__'
sha256sum shop-api-1.4.0.tar.gz | tee SHA256SUMS
__CMD__
capture p1-linux-20 0 <<'__CMD__'
sha256sum -c SHA256SUMS
__CMD__
capture p1-linux-21 0 <<'__CMD__'
printf 'x' >> shop-api-1.4.0.tar.gz
__CMD__
capture p1-linux-22 1 <<'__CMD__'
sha256sum -c SHA256SUMS
__CMD__
capture p1-linux-23 0 <<'__CMD__'
cd ~/shop-config && git -c user.name='Release Bot' -c user.email=release-bot@example.com commit -q --allow-empty -m 'Bump payment SDK'
__CMD__
capture p1-linux-24 0 <<'__CMD__'
git log --format='%h %an <%ae> signature:%G? %s'
__CMD__
capture p1-linux-25 0 <<'__CMD__'
sudo cp ~/security-principles-demo/part01/shop-ratelimit.conf /etc/nginx/conf.d/ && sudo nginx -t
__CMD__
capture p1-linux-26 0 <<'__CMD__'
sudo systemctl restart nginx
__CMD__
capture p1-linux-27 0 <<'__CMD__'
for i in $(seq 1 8); do curl -s -o /dev/null -w '%{http_code} ' -X POST http://127.0.0.1:8081/login; done; echo
__CMD__
finish
