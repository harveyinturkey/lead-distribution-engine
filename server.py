#!/usr/bin/env python3
"""Bitrix24 uyumlu lokal sunucu — GET ve POST destekler."""
import http.server
import os

os.chdir(os.path.dirname(os.path.abspath(__file__)))

class B24Handler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        # Bitrix24 iframe'i POST ile açar, GET gibi davran
        self.do_GET()

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

print("Sunucu başlatıldı: http://localhost:8080")
print("Ctrl+C ile durdurun")
http.server.HTTPServer(('', 8080), B24Handler).serve_forever()
