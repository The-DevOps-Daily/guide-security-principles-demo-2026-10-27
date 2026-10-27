#!/usr/bin/env bash
# Part 2 on Ubuntu 26.04, as the user dev
# Generated from the guide source: every command below is shown in the guide,
# and its output there comes from the captures this script writes.
set -uo pipefail
source "$(dirname "$(readlink -f "$0")")/lib.sh"
cd /home/dev/security-principles-demo/part02
capture p2-linux-01 0 <<'__CMD__'
grep -n '^Include' /etc/ssh/sshd_config
__CMD__
capture p2-linux-02 0 <<'__CMD__'
ls /etc/ssh/sshd_config.d/
__CMD__
capture p2-linux-03 0 <<'__CMD__'
sudo grep -i -E '^(passwordauthentication|clientaliveinterval)' -r /etc/ssh/sshd_config.d/
__CMD__
capture p2-linux-04 0 <<'__CMD__'
sudo sshd -T | grep -E '^(passwordauthentication|permitrootlogin|kbdinteractiveauthentication|maxauthtries|persourcepenalties|clientaliveinterval|channeltimeout|x11forwarding|allowtcpforwarding) '
__CMD__
capture p2-linux-05 0 <<'__CMD__'
sudo groupadd --system ssh-users && sudo usermod -aG ssh-users dev
__CMD__
capture p2-linux-06 0 <<'__CMD__'
sudo install -m 0644 10-hardening.conf /etc/ssh/sshd_config.d/
__CMD__
capture p2-linux-07 0 <<'__CMD__'
sudo sshd -t && echo 'config OK'
__CMD__
capture p2-linux-08 0 <<'__CMD__'
sudo sshd -T | grep -E '^(passwordauthentication|permitrootlogin|kbdinteractiveauthentication|maxauthtries|persourcepenalties|clientaliveinterval|channeltimeout|unusedconnectiontimeout|x11forwarding|allowtcpforwarding|allowgroups) '
__CMD__
capture p2-linux-09 0 <<'__CMD__'
sudo apt-get install -y -qq aide >/dev/null && sudo install -m 0600 aide-shop.conf /etc/aide-shop.conf
__CMD__
capture p2-linux-10 0 <<'__CMD__'
sudo mkdir -p /etc/shop /var/lib/aide-shop && echo 'log_level=info' | sudo tee /etc/shop/app.conf >/dev/null
__CMD__
capture p2-linux-11 0 <<'__CMD__'
sudo aide --config /etc/aide-shop.conf --init >/dev/null && sudo mv /var/lib/aide-shop/aide.db.new /var/lib/aide-shop/aide.db
__CMD__
capture p2-linux-12 0 <<'__CMD__'
sudo aide --config /etc/aide-shop.conf --check
__CMD__
capture p2-linux-13 0 <<'__CMD__'
echo 'debug_token=letmein' | sudo tee -a /etc/shop/app.conf >/dev/null && sudo chmod 0666 /etc/shop/app.conf
__CMD__
capture p2-linux-14 4 <<'__CMD__'
sudo aide --config /etc/aide-shop.conf --check
__CMD__
capture p2-linux-15 0 <<'__CMD__'
sudo apt-get install -y -qq postgresql python3-psycopg >/dev/null && sudo systemctl enable --now postgresql
__CMD__
capture p2-linux-16 0 <<'__CMD__'
sudo -u postgres psql -q -v ON_ERROR_STOP=1 < setup.sql
__CMD__
capture p2-linux-17 0 <<'__CMD__'
echo '127.0.0.1:5432:shop:shop_api:lab-only-change-me' > ~/.pgpass && chmod 600 ~/.pgpass
__CMD__
capture p2-linux-18 0 <<'__CMD__'
python3 orders.py unsafe 'ana@example.com'
__CMD__
capture p2-linux-19 0 <<'__CMD__'
python3 orders.py unsafe "x' OR '1'='1"
__CMD__
capture p2-linux-20 0 <<'__CMD__'
python3 orders.py safe "x' OR '1'='1"
__CMD__
capture p2-linux-21 0 <<'__CMD__'
python3 orders.py unsafe "x'; DROP TABLE orders; --"
__CMD__
capture p2-linux-22 0 <<'__CMD__'
cp ../part01/server.py shop-api/
__CMD__
capture p2-linux-23 0 <<'__CMD__'
docker build -q -t shop-api:1.4.0 shop-api >/dev/null && docker run --rm shop-api:1.4.0 id
__CMD__
capture p2-linux-24 0 <<'__CMD__'
docker run -d --name api --read-only --tmpfs /tmp --cap-drop ALL --security-opt no-new-privileges=true -p 127.0.0.1:8080:8080 shop-api:1.4.0
__CMD__
capture p2-linux-25 0 <<'__CMD__'
sleep 2; curl -s http://127.0.0.1:8080/orders
__CMD__
capture p2-linux-26 1 <<'__CMD__'
docker exec api sh -c 'echo "import os" > /app/backdoor.py'
__CMD__
capture p2-linux-27 0 <<'__CMD__'
docker exec api grep -E '^(CapEff|NoNewPrivs)' /proc/1/status
__CMD__
capture p2-linux-28 0 <<'__CMD__'
docker rm -f api
__CMD__
finish
