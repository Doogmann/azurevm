#!/usr/bin/env bash
set -euo pipefail

WEB_ROOT="/var/www/webapp"   # main app (served on 5000 by cloud-init)
EVENT_ROOT="/var/www/event"  # static (served on 8081 by cloud-init)

sudo install -d -m 0755 "$WEB_ROOT" "$EVENT_ROOT"

# Landing page (root on 5000)
sudo tee "${WEB_ROOT}/index.html" >/dev/null <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Hectormoncler • Azure MySQL Contact App</title>
<style>
:root{--neon:#00f0ff;--bg:#0a0a0a;--text:#e5faff;--card:#0d1117;--accent:#1976d2}
*{box-sizing:border-box;margin:0;padding:0}body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,Helvetica,Arial,sans-serif;background:var(--bg);color:var(--text);min-height:100vh;overflow-x:hidden}
header{text-align:center;padding:48px 16px 24px}
header h1{font-family:'Courier New',monospace;font-weight:700;letter-spacing:2px;font-size:clamp(28px,4.5vw,48px);color:var(--neon);text-shadow:0 0 10px var(--neon)}
header p{opacity:.9;margin-top:8px}.wrap{max-width:1100px;margin:0 auto;padding:16px}
.grid{display:grid;gap:20px;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));margin-top:20px}
.card{background:linear-gradient(180deg,rgba(0,240,255,.08),rgba(0,240,255,.02)),var(--card);border:1px solid rgba(0,240,255,.35);border-radius:14px;padding:22px;box-shadow:0 0 25px rgba(0,240,255,.15);transition:transform .2s,box-shadow .2s}
.card:hover{transform:translateY(-4px);box-shadow:0 0 35px rgba(0,240,255,.35)}.card h2{font-family:'Courier New',monospace;color:var(--neon);margin-bottom:10px}
.btns{display:flex;flex-wrap:wrap;gap:12px;margin-top:14px}.btn{border:0;text-decoration:none;color:#fff;background:var(--accent);padding:10px 14px;border-radius:10px;font-weight:600}
.btn.secondary{background:#0ea5e9}.btn.ghost{background:transparent;color:var(--neon);border:1px solid rgba(0,240,255,.5)}.btn:hover{filter:brightness(.95)}
ul{margin-top:10px;line-height:1.75}footer{opacity:.7;text-align:center;margin:26px 0 40px}
</style></head>
<body>
<header>
  <h1>💻 Hectormoncler – IT-Tech</h1>
  <p>LEMP on Azure • Reverse Proxy • Azure Database for MySQL Flexible Server</p>
</header>
<div class="wrap">
  <div class="grid">
    <section class="card">
      <h2>📅 Event</h2>
      <p>Topic: <b>The Future of IT</b> • Date: <b>Aug 25, 2025</b> • Time: <b>15:00 CET</b></p>
      <div class="btns"><a class="btn ghost" href="/event/">Open Animated Event Page</a></div>
    </section>
    <section class="card">
      <h2>📝 Azure MySQL Contact App</h2>
      <p>Submit a message and view stored entries (MySQL via private VNet).</p>
      <div class="btns">
        <a class="btn" href="contact_form.html">Contact Form</a>
        <a class="btn secondary" href="on_get_messages.php">View Messages</a>
      </div>
      <ul>
        <li>Nginx + PHP-FPM on WebApp VM (port 5000)</li>
        <li>Reverse Proxy routes <code>/</code>→5000 and <code>/event/</code>→8081</li>
        <li>Azure MySQL Flexible Server (private access)</li>
      </ul>
    </section>
  </div>
</div>
<footer>© <script>document.write(new Date().getFullYear())</script> Hectormoncler • Azure LEMP Demo</footer>
</body></html>
HTML

# Simple /event page (already served by nginx on 8081 per cloud-init)
sudo tee "${EVENT_ROOT}/index.html" >/dev/null <<'HTML'
<!doctype html><meta charset="utf-8"><title>Neon site</title>
<h1 style="font-family:Georgia,serif">Neon site is up on 8081</h1>
HTML

echo "CSE: content deployed."

