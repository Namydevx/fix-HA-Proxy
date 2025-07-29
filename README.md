# ⚡ Fix HAProxy by NamyDevx

Script satu klik untuk menginstal dan mengkonfigurasi HAProxy secara otomatis di VPS Debian/Ubuntu.  
Termasuk penghapusan konflik port (seperti nginx/xray di port 80), validasi konfigurasi, dan aktivasi HAProxy.

---

## 📦 Fitur

- ✅ Auto install HAProxy
- 🔁 Disable service yang konflik di port 80 (seperti nginx dan xray)
- 🔒 Gunakan konfigurasi HAProxy yang sudah disiapkan untuk TCP SSL/TLS Load Balancer
- 🔄 Auto restart & enable HAProxy agar berjalan setiap reboot
- 📊 Konfigurasi mendukung proxy: Vmess, Vless, WebSocket, TLS/non-TLS

---

## 🚀 Cara Install

Jalankan perintah ini di terminal VPS Anda:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Namydevx/fix-HA-Proxy/main/install-haproxy.sh)
