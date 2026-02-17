#!/bin/bash
# Lead Distribution Engine — Tek tıkla başlat
cd "$(dirname "$0")"

echo "========================================"
echo "  Lead Distribution Engine Başlatılıyor"
echo "========================================"

# Önceki işlemleri temizle
pkill -f "python3 server.py" 2>/dev/null
pkill -f "cloudflared" 2>/dev/null
sleep 1

# 1. Python sunucuyu başlat
echo "[1/2] Sunucu başlatılıyor (port 8080)..."
python3 server.py &
SERVER_PID=$!
sleep 1

# 2. Cloudflare tunnel başlat
echo "[2/2] Cloudflare tunnel başlatılıyor..."
cloudflared tunnel --url http://localhost:8080 --no-autoupdate > /tmp/cloudflared.log 2>&1 &
TUNNEL_PID=$!

# URL'in oluşmasını bekle
echo "Tunnel URL bekleniyor..."
for i in {1..15}; do
    URL=$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' /tmp/cloudflared.log 2>/dev/null | head -1)
    if [ -n "$URL" ]; then
        break
    fi
    sleep 1
done

echo ""
echo "========================================"
echo "  HAZIR!"
echo "========================================"
echo ""
echo "  Tunnel URL: $URL"
echo ""
echo "  Bu URL'i Bitrix24 uygulama ayarlarına yapıştır:"
echo "  Bitrix24 → Developer resources → Uygulamam → URL alanı"
echo ""
echo "  Durdurmak için: Ctrl+C"
echo "========================================"

# URL'i panoya kopyala (macOS)
echo -n "$URL/index.html" | pbcopy
echo "  (URL panoya kopyalandı — Cmd+V ile yapıştır)"
echo ""

# Ctrl+C ile temiz kapanış
trap "echo ''; echo 'Kapatılıyor...'; kill $SERVER_PID $TUNNEL_PID 2>/dev/null; exit 0" INT
wait
