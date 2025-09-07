#!/usr/bin/env bash
set -euo pipefail

# Defaults
WEB_ROOT="/var/www/webapp"       # served by nginx on :5000 (cloud-init)
EVENT_ROOT="/var/www/event"      # served by nginx on :8081 (cloud-init)
CONF_DIR="/etc/webapp"
ENV_FILE="${CONF_DIR}/mysql.env"
CONTENT_ZIP=""                   # e.g. https://github.com/Doogmann/azurevm/archive/refs/heads/main.zip
CONTENT_PATH=""                  # path inside the zip to copy from (e.g. azurevm-main/webapp-files)

MYSQL_HOST=""
MYSQL_DB="flexibleserverdb"
MYSQL_USER="mysqladmin"
MYSQL_PASS=""
MYSQL_SSL="REQUIRED"             # DISABLED|PREFERRED|REQUIRED|VERIFY_CA|VERIFY_IDENTITY

usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]
  --mysql-host FQDN              Azure MySQL Flexible Server FQDN
  --mysql-db   NAME              Database name (default: ${MYSQL_DB})
  --mysql-user USER              DB user (default: ${MYSQL_USER})
  --mysql-pass PASS              DB password
  --mysql-ssl  MODE              SSL mode (default: ${MYSQL_SSL})
  --content-zip URL              Zip URL to download (e.g. GitHub archive)
  --content-path PATH            Folder inside the zip to copy (e.g. azurevm-main/webapp-files)
USAGE
}

# --- parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mysql-host) MYSQL_HOST="$2"; shift 2;;
    --mysql-db)   MYSQL_DB="$2";   shift 2;;
    --mysql-user) MYSQL_USER="$2"; shift 2;;
    --mysql-pass) MYSQL_PASS="$2"; shift 2;;
    --mysql-ssl)  MYSQL_SSL="$2";  shift 2;;
    --content-zip)  CONTENT_ZIP="$2";  shift 2;;
    --content-path) CONTENT_PATH="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown option: $1"; usage; exit 1;;
  esac
done

sudo install -d -m 0755 "$WEB_ROOT" "$EVENT_ROOT" "$CONF_DIR"

# --- write DB env file (idempotent) ---
sudo tee "$ENV_FILE" >/dev/null <<ENV
MYSQL_HOST="${MYSQL_HOST}"
MYSQL_DB="${MYSQL_DB}"
MYSQL_USER="${MYSQL_USER}"
MYSQL_PASS="${MYSQL_PASS}"
MYSQL_SSL="${MYSQL_SSL}"
ENV
sudo chmod 600 "$ENV_FILE"

# --- if a zip is provided, try to deploy from repo ---
if [[ -n "$CONTENT_ZIP" && -n "$CONTENT_PATH" ]]; then
  echo "CSE: deploying site from zip: $CONTENT_ZIP ($CONTENT_PATH)"
  sudo apt-get update -y
  sudo apt-get install -y curl unzip rsync
  tmp="$(mktemp -d)"; pushd "$tmp" >/dev/null
  curl -fL -o repo.zip "$CONTENT_ZIP"
  unzip -q repo.zip
  if [[ -d "$CONTENT_PATH" ]]; then
    sudo rsync -a --delete "${CONTENT_PATH}/" "$WEB_ROOT/"
  else
    echo "WARN: $CONTENT_PATH not found in zip. Falling back to built-in pages."
  fi
  popd >/dev/null
fi

# --- if WEB_ROOT still empty, write built-in content ---
if [[ -z "$(ls -A "$WEB_ROOT" 2>/dev/null || true)" ]]; then
  echo "CSE: writing built-in neon landing + contact app"

  # Neon landing page (root on :5000)
  sudo tee "${WEB_ROOT}/index.html" >/dev/null <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Hectormoncler – IT-Tech</title>
<style>
:root{--neon:#00f0ff;--bg:#0a0a0a;--card:#0d1117;--text:#cbefff}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--text);font-family:system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,Helvetica,Arial,sans-serif;min-height:100vh;overflow:hidden}
header{text-align:center;padding:48px 16px 8px}
header h1{font-family:"Courier New",monospace;font-size:clamp(28px,5vw,48px);color:var(--neon);letter-spacing:2px;text-shadow:0 0 10px var(--neon)}
header p{opacity:.85;margin-top:8px}
.wrap{max-width:1100px;margin:0 auto;padding:20px}
.grid{display:grid;gap:22px;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));margin-top:22px}
.card{background:linear-gradient(180deg,rgba(0,240,255,.08),rgba(0,240,255,.02)),var(--card);border:1px solid rgba(0,240,255,.35);border-radius:14px;padding:22px;box-shadow:0 0 25px rgba(0,240,255,.15);transition:.2s}
.card:hover{transform:translateY(-4px);box-shadow:0 0 35px rgba(0,240,255,.35)}
.card h2{font-family:"Courier New",monospace;color:var(--neon);margin-bottom:10px}
.pill{display:inline-block;padding:3px 10px;border:1px solid rgba(0,240,255,.35);border-radius:999px;margin-bottom:10px;opacity:.9}
ul{margin-top:8px;line-height:1.7}
.btns{display:flex;flex-wrap:wrap;gap:12px;margin-top:14px}
.btn{display:inline-block;padding:10px 14px;border-radius:10px;font-weight:600;text-decoration:none;color:#001b20;background:var(--neon)}
.btn.ghost{background:transparent;color:var(--neon);border:1px solid rgba(0,240,255,.5)}
footer{text-align:center;margin:26px 0 40px;opacity:.75}
</style></head>
<body>
<header>
  <h1>💻 Hectormoncler – IT-Tech</h1>
  <p>LEMP on Azure • Reverse Proxy • Azure MySQL Flexible Server</p>
</header>
<div class="wrap">
  <div class="grid">
    <section class="card">
      <span class="pill">📅 Event</span>
      <h2>Event Info</h2>
      <p>Topic: <b>The Future of IT</b></p>
      <p>Date: <b>August 25, 2025</b></p>
      <p>Time: <b>15:00 CET</b></p>
      <div class="btns"><a class="btn ghost" href="/event/">Open Animated Event Page</a></div>
    </section>
    <section class="card">
      <span class="pill">📝 Contact App</span>
      <h2>Azure MySQL Contact App</h2>
      <p>Submit a message and view stored entries (MySQL via private VNet).</p>
      <div class="btns">
        <a class="btn" href="contact_form.html">Contact Form</a>
        <a class="btn ghost" href="on_get_messages.php">View Messages</a>
      </div>
      <ul>
        <li>Nginx + PHP-FPM on WebApp VM (port 5000)</li>
        <li>Proxy routes <code>/</code>→5000 and <code>/event/</code>→8081</li>
        <li>Azure MySQL Flexible Server (private access)</li>
      </ul>
    </section>
  </div>
</div>
<footer>© <script>document.write(new Date().getFullYear())</script> Hectormoncler • Azure LEMP Demo</footer>
</body></html>
HTML

  # CSS + PHP app (same as earlier)
  sudo tee "${WEB_ROOT}/style.css" >/dev/null <<'CSS'
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Arial,Helvetica,sans-serif;line-height:1.6;color:#333;background:#f4f4f4}
.container{max-width:800px;margin:0 auto;padding:20px;background:#fff;min-height:100vh;box-shadow:0 0 10px rgba(0,0,0,.1)}
header{text-align:center;margin-bottom:30px;padding-bottom:20px;border-bottom:2px solid #eee}
header h1{color:#2c3e50;margin-bottom:10px}
header p{color:#7f8c8d;font-size:1.1em}
nav{text-align:center;margin-bottom:30px}
.btn{display:inline-block;padding:10px 20px;margin:0 5px;background:#3498db;color:#fff;text-decoration:none;border-radius:5px}
.btn:hover{background:#2980b9}.btn.active{background:#2c3e50}
.btn.submit-btn{background:#27ae60;width:100%;margin-top:10px}.btn.submit-btn:hover{background:#229954}
.features{background:#ecf0f1;padding:20px;border-radius:5px;margin-top:20px}
.features ul{list-style:none}
.contact-form{background:#f8f9fa;padding:30px;border-radius:8px;border:1px solid #e9ecef}
.form-group{margin-bottom:20px}
.form-group label{display:block;margin-bottom:5px;font-weight:bold;color:#2c3e50}
.form-group input,.form-group textarea{width:100%;padding:10px;border:1px solid #ddd;border-radius:4px;font-size:16px}
.success-message,.error-message,.info-message{padding:20px;margin:20px 0;border-radius:5px;text-align:center}
.success-message{background:#d4edda;color:#155724;border:1px solid #c3e6cb}
.error-message{background:#f8d7da;color:#721c24;border:1px solid #f5c6cb}
.info-message{background:#d1ecf1;color:#0c5460;border:1px solid #bee5eb}
.messages-count{text-align:center;margin:12px 0}
.message-item{background:#f8f9fa;border:1px solid #e9ecef;border-radius:8px;padding:20px;margin-bottom:20px}
.message-header{display:flex;justify-content:space-between;gap:10px;border-bottom:1px solid #eee;padding-bottom:10px;margin-bottom:10px}
CSS

  sudo tee "${WEB_ROOT}/database_setup.php" >/dev/null <<'PHP'
<?php
$env = @parse_ini_file('/etc/webapp/mysql.env');
$host = $env['MYSQL_HOST'] ?? '';
$db   = $env['MYSQL_DB']   ?? 'flexibleserverdb';
$user = $env['MYSQL_USER'] ?? 'mysqladmin';
$pass = $env['MYSQL_PASS'] ?? '';
$ssl  = strtoupper($env['MYSQL_SSL'] ?? 'REQUIRED');
$dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
$options=[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC];
if($ssl!=='DISABLED'){ $options[PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT]=false; $options[PDO::MYSQL_ATTR_SSL_CA]='/etc/ssl/certs/ca-certificates.crt'; }
$pdo=new PDO($dsn,$user,$pass,$options);
$pdo->exec("CREATE TABLE IF NOT EXISTS contacts(id INT AUTO_INCREMENT PRIMARY KEY,name VARCHAR(255),email VARCHAR(255),message TEXT,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
?>
PHP
  sudo tee "${WEB_ROOT}/contact_form.html" >/dev/null <<'HTML'
<!DOCTYPE html><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<link rel="stylesheet" href="style.css"><div class="container"><header><h1>✉️ Contact Form</h1></header>
<nav><a class="btn" href="index.html">Home</a><a class="btn active" href="contact_form.html">Contact Form</a><a class="btn" href="on_get_messages.php">View Messages</a></nav>
<main><form action="on_post_contact.php" method="POST" class="contact-form">
<div class="form-group"><label>Name</label><input name="name" required></div>
<div class="form-group"><label>Email</label><input name="email" type="email" required></div>
<div class="form-group"><label>Message</label><textarea name="message" rows="5" required></textarea></div>
<button class="btn submit-btn" type="submit">Send Message</button></form></main></div>
HTML
  sudo tee "${WEB_ROOT}/on_post_contact.php" >/dev/null <<'PHP'
<?php require "database_setup.php";
$ok=false;$err=null;
if($_SERVER['REQUEST_METHOD']==='POST'){
  $n=trim($_POST['name']??'');$e=trim($_POST['email']??'');$m=trim($_POST['message']??'');
  if($n&&$e&&$m){ try{$pdo->prepare("INSERT INTO contacts(name,email,message) VALUES(?,?,?)")->execute([$n,$e,$m]);$ok=true;}catch(Exception $ex){$err=$ex->getMessage();}}
  else{$err="All fields are required.";}
} ?>
<!DOCTYPE html><meta charset="UTF-8"><link rel="stylesheet" href="style.css"><div class="container">
<header><h1>📨 Message Status</h1></header><nav><a class="btn" href="index.html">Home</a><a class="btn" href="contact_form.html">Contact</a><a class="btn" href="on_get_messages.php">Messages</a></nav>
<main><?php if($ok): ?><div class="success-message"><h2>✅ Saved</h2></div><?php else: ?><div class="error-message"><h2>❌ Error</h2><p><?=htmlspecialchars($err??"Unknown")?></p></div><?php endif; ?></main></div>
PHP
  sudo tee "${WEB_ROOT}/on_get_messages.php" >/dev/null <<'PHP'
<?php require "database_setup.php";
try{$rows=$pdo->query("SELECT name,email,message,created_at FROM contacts ORDER BY created_at DESC")->fetchAll();}
catch(Exception $e){$err=$e->getMessage();$rows=[];}
?>
<!DOCTYPE html><meta charset="UTF-8"><link rel="stylesheet" href="style.css"><div class="container">
<header><h1>📋 All Messages</h1></header><nav><a class="btn" href="index.html">Home</a><a class="btn" href="contact_form.html">Contact</a><a class="btn active" href="on_get_messages.php">Messages</a></nav>
<main><?php if(!empty($err)): ?><div class="error-message"><h2>❌ Error</h2><p><?=htmlspecialchars($err)?></p></div>
<?php elseif(!$rows): ?><div class="info-message"><h2>📭 No messages yet</h2></div>
<?php else: ?><div class="messages-count">Total: <b><?=count($rows)?></b></div>
<?php foreach($rows as $r): ?><div class="message-item"><div class="message-header"><h3><?=htmlspecialchars($r["name"])?></h3><span class="message-date"><?=htmlspecialchars($r["created_at"])?></span></div>
<p class="message-email">📧 <?=htmlspecialchars($r["email"])?> </p><div class="message-content"><p><?=nl2br(htmlspecialchars($r["message"]))?></p></div></div><?php endforeach; endif; ?></main></div>
PHP
fi

# Event page (always present)
sudo tee "${EVENT_ROOT}/index.html" >/dev/null <<'HTML'
<!doctype html><meta charset="utf-8"><title>Event</title><h1>Event page on :8081</h1>
HTML

# Permissions and nginx reload
sudo chown -R www-data:www-data /var/www
sudo find "$WEB_ROOT" -type d -exec chmod 755 {} \;
sudo find "$WEB_ROOT" -type f -exec chmod 644 {} \;
sudo find "$EVENT_ROOT" -type d -exec chmod 755 {} \;
sudo find "$EVENT_ROOT" -type f -exec chmod 644 {} \;
sudo systemctl reload nginx || true

echo "CSE complete. Web root: $WEB_ROOT (5000) • Event root: $EVENT_ROOT (8081) • DB env: $ENV_FILE"
