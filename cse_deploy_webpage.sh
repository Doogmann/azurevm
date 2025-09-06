#!/usr/bin/env bash
set -euo pipefail

# --- paths ---
WEB_ROOT="/var/www/html"
EVENT_ROOT="/var/www/event"
EVENT_SITE="/etc/nginx/sites-available/event-8081.conf"
EVENT_SITE_LINK="/etc/nginx/sites-enabled/event-8081.conf"

sudo install -d -m 0755 "$WEB_ROOT" "$EVENT_ROOT"

# --- merged landing page (root on port 80) ---
sudo tee "${WEB_ROOT}/index.html" >/dev/null <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Hectormoncler • Azure MySQL Contact App</title>
  <style>
    :root{--neon:#00f0ff;--bg:#0a0a0a;--text:#e5faff;--card:#0d1117;--accent:#1976d2}
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,Helvetica,Arial,sans-serif;background:var(--bg);color:var(--text);min-height:100vh;overflow-x:hidden}
    header{text-align:center;padding:48px 16px 24px}
    header h1{font-family:'Courier New',monospace;font-weight:700;letter-spacing:2px;font-size:clamp(28px,4.5vw,48px);color:var(--neon);text-shadow:0 0 10px var(--neon)}
    header p{opacity:.9;margin-top:8px}
    canvas#bg{position:fixed;inset:0;z-index:-1}
    .wrap{max-width:1100px;margin:0 auto;padding:16px}
    .grid{display:grid;gap:20px;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));margin-top:20px}
    .card{background:linear-gradient(180deg,rgba(0,240,255,.08),rgba(0,240,255,.02)),var(--card);border:1px solid rgba(0,240,255,.35);border-radius:14px;padding:22px;box-shadow:0 0 25px rgba(0,240,255,.15);transition:transform .2s,box-shadow .2s}
    .card:hover{transform:translateY(-4px);box-shadow:0 0 35px rgba(0,240,255,.35)}
    .card h2{font-family:'Courier New',monospace;color:var(--neon);margin-bottom:10px}
    .muted{opacity:.8}
    .btns{display:flex;flex-wrap:wrap;gap:12px;margin-top:14px}
    .btn{appearance:none;border:0;cursor:pointer;text-decoration:none;color:#fff;background:var(--accent);padding:10px 14px;border-radius:10px;font-weight:600}
    .btn.secondary{background:#0ea5e9}
    .btn.ghost{background:transparent;color:var(--neon);border:1px solid rgba(0,240,255,.5)}
    .btn:hover{filter:brightness(.95)}
    ul.list{margin-top:10px;line-height:1.75}
    footer{opacity:.7;text-align:center;margin:26px 0 40px}
    code{background:#0b1220;padding:2px 6px;border-radius:6px}
  </style>
</head>
<body>
  <canvas id="bg"></canvas>
  <header>
    <h1>💻 Hectormoncler – IT-Tech</h1>
    <p class="muted">LEMP on Azure • Reverse Proxy • Azure Database for MySQL Flexible Server</p>
  </header>
  <div class="wrap">
    <div class="grid">
      <section class="card">
        <h2>📅 Event Info</h2>
        <p>Topic: <b>The Future of IT</b></p>
        <p>Date: <b>August 25, 2025</b></p>
        <p>Time: <b>15:00 CET</b></p>
        <div class="btns"><a class="btn ghost" href="/event/">Open Animated Event Page</a></div>
      </section>
      <section class="card">
        <h2>📝 Azure MySQL Contact App</h2>
        <p class="muted">Submit a message and view stored entries (MySQL over private VNet).</p>
        <div class="btns">
          <a class="btn" href="contact_form.html">Contact Form</a>
          <a class="btn secondary" href="on_get_messages.php">View Messages</a>
        </div>
        <ul class="list">
          <li>Nginx + PHP-FPM on WebApp VM</li>
          <li>Reverse Proxy routes <code>/</code> → WebApp:80 and <code>/event/</code> → WebApp:8081</li>
          <li>Private Azure MySQL Flexible Server</li>
        </ul>
      </section>
      <section class="card">
        <h2>🧭 Architecture</h2>
        <ul class="list">
          <li>ReverseProxy (public) → WebApp (private)</li>
          <li>NSGs with ASGs; Proxy → WebApp (80, 8081)</li>
          <li>MySQL Flexible Server (private access, SSL enforced)</li>
        </ul>
        <div class="btns"><a class="btn ghost" href="/">Home</a><a class="btn ghost" href="/event/">Event</a></div>
      </section>
    </div>
  </div>
  <footer>© <span id="yr"></span> Hectormoncler • Azure LEMP Demo</footer>
  <script>
    document.getElementById('yr').textContent=new Date().getFullYear();
    const c=document.getElementById("bg"),x=c.getContext("2d");let W,H,N,pts;
    function size(){W=c.width=innerWidth;H=c.height=innerHeight;N=Math.max(40,Math.min(90,Math.floor(W/30)));
      pts=[...Array(N)].map(()=>({x:Math.random()*W,y:Math.random()*H,vx:(Math.random()-.5)*.9,vy:(Math.random()-.5)*.9}));
    }
    function tick(){x.clearRect(0,0,W,H);x.fillStyle="#00f0ff";x.strokeStyle="rgba(0,240,255,.5)";x.lineWidth=1;
      pts.forEach(p=>{p.x+=p.vx;p.y+=p.vy;if(p.x<0||p.x>W)p.vx*=-1;if(p.y<0||p.y>H)p.vy*=-1;x.beginPath();x.arc(p.x,p.y,1.8,0,Math.PI*2);x.fill();});
      for(let i=0;i<pts.length;i++)for(let j=i+1;j<pts.length;j++){const a=pts[i],b=pts[j],dx=a.x-b.x,dy=a.y-b.y,d=Math.hypot(dx,dy);
        if(d<120){x.globalAlpha=1-d/120;x.beginPath();x.moveTo(a.x,a.y);x.lineTo(b.x,b.y);x.stroke();x.globalAlpha=1;}}
      requestAnimationFrame(tick);
    }
    addEventListener('resize',size); size(); tick();
  </script>
</body>
</html>
HTML

# --- simple event page (served on 8081) ---
sudo tee "${EVENT_ROOT}/index.html" >/dev/null <<'HTML'
<!doctype html><meta charset="utf-8"><title>Neon site</title>
<h1 style="font-family:Georgia,serif">Neon site is up on 8081</h1>
HTML

# --- nginx server on 8081 for /event backend ---
sudo tee "$EVENT_SITE" >/dev/null <<'NGINX'
server {
  listen 8081;
  server_name _;
  root /var/www/event;
  index index.html;
  location / { try_files $uri $uri/ =404; }
}
NGINX

sudo ln -sf "$EVENT_SITE" "$EVENT_SITE_LINK"
sudo nginx -t
sudo systemctl reload nginx || sudo systemctl restart nginx

echo "CSE: landing page + /event site deployed."
