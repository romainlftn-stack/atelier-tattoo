#!/bin/bash
# Lance l'Atelier Tattoo 3D sur un petit serveur local.
# Indispensable : ouvert en double-cliquant index.html (file://), le navigateur
# interdit de lire anatomie.bin et l'atelier retombe sur des modèles de secours.
cd "$(dirname "$0")" || exit 1

PORT=8770
while lsof -i :$PORT >/dev/null 2>&1; do PORT=$((PORT+1)); done

# Serveur sans cache : sinon le navigateur ressert une ancienne version de
# index.html et les modifications semblent ne pas avoir été prises en compte.
python3 - "$PORT" <<'PY' >/dev/null 2>&1 &
import sys, http.server, socketserver
class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()
    def guess_type(self, path):
        t = super().guess_type(path)
        return 'text/html; charset=utf-8' if t == 'text/html' else t
    def log_message(self, *a): pass
socketserver.TCPServer.allow_reuse_address = True
socketserver.TCPServer(('127.0.0.1', int(sys.argv[1])), H).serve_forever()
PY
SRV=$!
trap 'kill $SRV 2>/dev/null' EXIT INT TERM

sleep 1
open "http://127.0.0.1:$PORT/index.html"

echo ""
echo "  ┌──────────────────────────────────────────────┐"
echo "  │   ATELIER TATTOO 3D                          │"
echo "  │   http://127.0.0.1:$PORT/index.html            "
echo "  └──────────────────────────────────────────────┘"
echo ""
echo "  Ouvrez TOUJOURS l'atelier par ce lanceur."
echo "  Un double-clic sur index.html affiche des modèles de secours."
echo ""
echo "  Laissez cette fenêtre ouverte pendant l'utilisation."
echo "  Fermez-la (ou Ctrl+C) pour arrêter le serveur."
echo ""
wait $SRV
