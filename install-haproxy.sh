#!/bin/bash

# ========================================
# 🛡️ NAMYSTORE HAProxy One Click Installer
# ========================================

set -e

echo "[1/6] 🔥 Menghapus service konflik (nginx & xray)..."
systemctl stop nginx xray || true
systemctl disable nginx xray || true
kill $(lsof -t -i:80) 2>/dev/null || true

echo "[2/6] 📦 Memasang HAProxy..."
apt update -y
apt install -y haproxy

echo "[3/6] 📁 Menyalin konfigurasi HAProxy..."
cat >/etc/haproxy/haproxy.cfg <<'EOF'
#CONFIGURASI NAMYSTORETUNNEL LOADBALANCER [ namydevx.my.id ]
global
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 1d
    tune.h2.initial-window-size 2147483647
    tune.ssl.default-dh-param 2048
    pidfile /run/haproxy.pid
    chroot /var/lib/haproxy
    user haproxy
    group haproxy
    daemon
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
    ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11
    ca-base /etc/ssl/certs
    crt-base /etc/ssl/private

defaults
    log global
    mode tcp
    option dontlognull
    timeout connect 200ms
    timeout client  300s
    timeout server  300s

frontend multiport
    mode tcp
    bind-process 1 2
    bind *:222-1000 tfo
    tcp-request inspect-delay 500ms
    tcp-request content accept if HTTP
    tcp-request content accept if { req.ssl_hello_type 1 }
    use_backend recir_http if HTTP
    default_backend recir_https

frontend multiports
    mode tcp
    bind abns@haproxy-http accept-proxy tfo
    default_backend recir_https_www

frontend ssl
    mode tcp
    bind-process 1
    bind *:80 tfo
    bind *:55 tfo
    bind *:8080 tfo
    bind *:8880 tfo
    bind *:2095 tfo
    bind *:2082 tfo
    bind *:2086 tfo
    bind abns@haproxy-https accept-proxy ssl crt /etc/haproxy/hap.pem alpn h2,http/1.1 tfo
    tcp-request inspect-delay 500ms
    tcp-request content capture req.ssl_sni len 100
    tcp-request content accept if { req.ssl_hello_type 1 }
    acl chk-02_up hdr(Connection) -i upgrade
    acl chk-02_ws hdr(Upgrade) -i websocket
    acl this_payload payload(0,7) -m bin 5353482d322e30
    acl up-to ssl_fc_alpn -i h2
    use_backend GRUP_NAMYSTORE if up-to
    use_backend NAMYSTORE if chk-02_up chk-02_ws
    use_backend NAMYSTORE if { path_reg -i ^\/(.*) }
    use_backend BOT_NAMYSTORE if this_payload
    default_backend CHANNEL_NAMYSTORE

backend recir_https_www
    mode tcp
    server misssv-bau 127.0.0.1:2223 check

backend NAMYSTORE
    mode http
    server hencet-bau 127.0.0.1:1010 send-proxy check

backend GRUP_NAMYSTORE
    mode tcp
    server hencet-baus 127.0.0.1:1013 send-proxy check

backend CHANNEL_NAMYSTORE
    mode tcp
    balance roundrobin
    server nonok-bau 127.0.0.1:1194 check
    server memek-bau 127.0.0.1:1012 send-proxy check

backend BOT_NAMYSTORE
    mode tcp
    server misv-bau 127.0.0.1:2222 check

backend recir_http
    mode tcp
    server loopback-for-http abns@haproxy-http send-proxy-v2 check

backend recir_https
    mode tcp
    server loopback-for-https abns@haproxy-https send-proxy-v2 check
EOF

echo "[4/6] 🔎 Mengecek konfigurasi HAProxy..."
haproxy -c -f /etc/haproxy/haproxy.cfg

echo "[5/6] 🚀 Mengaktifkan dan memulai HAProxy..."
systemctl enable haproxy
systemctl restart haproxy

echo "[6/6] ✅ HAProxy berhasil dijalankan!"
systemctl status haproxy --no-pager
