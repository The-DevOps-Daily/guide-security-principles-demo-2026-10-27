#!/usr/bin/env bash
# Part 3 on Ubuntu 26.04, as the user dev
# Generated from the guide source: every command below is shown in the guide,
# and its output there comes from the captures this script writes.
set -uo pipefail
source "$(dirname "$(readlink -f "$0")")/lib.sh"
cd /home/dev/security-principles-demo/part03
capture p3-linux-01 0 <<'__CMD__'
sudo -u postgres psql -d shop -c '\dp tickets'
__CMD__
capture p3-linux-02 0 <<'__CMD__'
psql -h 127.0.0.1 -U shop_api -d shop -f api-checks.sql
__CMD__
capture p3-linux-03 0 <<'__CMD__'
sudo -u postgres psql -q -d shop < reporting.sql
__CMD__
capture p3-linux-04 0 <<'__CMD__'
sudo install -d -m 0700 /etc/shop-worker
__CMD__
capture p3-linux-05 0 <<'__CMD__'
sudo sh -c 'umask 077; openssl rand -hex 16 > /etc/shop-worker/db-password'
__CMD__
capture p3-linux-06 0 <<'__CMD__'
sudo ls -l /etc/shop-worker
__CMD__
capture p3-linux-07 1 <<'__CMD__'
sudo -u nobody cat /etc/shop-worker/db-password
__CMD__
capture p3-linux-08 0 <<'__CMD__'
sudo install -D -m 0644 worker.py /opt/shop-worker/worker.py
__CMD__
capture p3-linux-09 0 <<'__CMD__'
sudo install -m 0644 shop-worker.service.basic /etc/systemd/system/shop-worker.service && sudo systemctl daemon-reload
__CMD__
capture p3-linux-10 0 <<'__CMD__'
SYSTEMD_EMOJI=0 systemd-analyze security shop-worker.service | tail -n 1
__CMD__
capture p3-linux-11 0 <<'__CMD__'
sudo install -m 0644 shop-worker.service /etc/systemd/system/shop-worker.service && sudo systemctl daemon-reload
__CMD__
capture p3-linux-12 0 <<'__CMD__'
SYSTEMD_EMOJI=0 systemd-analyze security shop-worker.service | tail -n 1
__CMD__
capture p3-linux-13 0 <<'__CMD__'
sudo systemctl start shop-worker && sleep 2 && sudo journalctl -u shop-worker -n 1 -o cat --no-pager
__CMD__
capture p3-linux-14 0 <<'__CMD__'
python3 -m venv ~/venv-iam && ~/venv-iam/bin/pip install -q parliament==1.6.4 'setuptools<81'
__CMD__
capture p3-linux-15 1 <<'__CMD__'
~/venv-iam/bin/parliament < iam/api-policy-broad.json
__CMD__
capture p3-linux-16 0 <<'__CMD__'
~/venv-iam/bin/parliament < iam/api-policy.json && echo 'no findings'
__CMD__
finish
