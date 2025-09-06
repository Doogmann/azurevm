#!/usr/bin/env bash
set -euo pipefail

WEB_ROOT="/var/www/webapp"    # PHP contact app (served on 5000)
EVENT_ROOT="/var/www/event"   # Neon landing (served on 8081)
CONF_DIR="/etc/webapp"
ENV_FILE="${CONF_DIR}/mysql.env"

sudo install -d -m 0755 "$WEB_ROOT" "$EVENT_ROOT" "$CONF_DIR"

# -------------------------------------------------------------------
# Optional: create a default MySQL env file if one is not present.
# You can override these by pre-creating /etc/webapp/mysql.env
# from your provisioner (recommended).
# -------------------------------------------------------------------
if [[ ! -f "$ENV_FILE" ]]; then
  sudo tee "$ENV_FILE" >/dev/null <<'ENV'
# MySQL connection for Azure Flexible Server
# Override these via your provisioner for production.
MYSQL_HOST="CHANGE-ME.mysql.database.azure.com"
MYSQL_DB="flexibleserverdb"
MYSQL_USER="mysqladmin"
MYSQL_PASS="SecurePassword123!"
# For Azure MySQL, SSL is typically required:
MYSQL_SSL="REQUIRED"   # one of: DISABLED | PREFERRED | REQUIRED | VERIFY_CA | VERIFY_IDENTITY
ENV
  sudo chmod 600 "$ENV_FILE"
fi

# -------------------------------------------------------------------
# EVENT landing (8081)
# -------------------------------------------------------------------
sudo tee "${EVENT_ROOT}/index.html" >/dev/null <<'HTML'
<!doctype html><meta charset="utf-8"><title>Neon site</title>
<h1 style="font-family:Georgia,serif">Neon site is up on 8081</h1>
HTML

# -------------------------------------------------------------------
# WEBAPP main landing (5000) — neon + links to PHP app pages
# -------------------------------------------------------------------
sudo tee "${WEB_ROOT}/index.html" >/dev/null <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Hectormoncler – IT-Tech</title>
  <style>
    :root{--neon:#00f0ff;--bg:#0a0a0a;--card:#0d1117;--text:#cbefff}
    *{box-sizing:border-box;margin:0;padding:0}
    body{background:var(--bg);color:var(--text);font-family:system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,Helvetica,Arial,sans-serif;min-height:100vh;overflow:hidden}
    header{position:relative;z-index:2;text-align:center;padding:48px 16px 8px}
    header h1{font-family:"Courier New",monospace;font-size:clamp(28px,5vw,48px);color:var(--neon);letter-spacing:2px;text-shadow:0 0 10px var(--neon)}
    header p{opacity:.85;margin-top:8px}
    .wrap{position:relative;z-index:2;max-width:1100px;margin:0 auto;padding:20px}
    .grid{display:grid;gap:22px;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));margin-top:22px}
    .card{background:linear-gradient(180deg,rgba(0,240,255,.08),rgba(0,240,255,.02)),var(--card);
          border:1px solid rgba(0,240,255,.35);border-radius:14px;padding:22px;
          box-shadow:0 0 25px rgba(0,240,255,.15);transition:transform .2s,box-shadow .2s}
    .card:hover{transform:translateY(-4px);box-shadow:0 0 35px rgba(0,240,255,.35)}
    .card h2{font-family:"Courier New",monospace;color:var(--neon);margin-bottom:10px}
    .pill{display:inline-block;padding:3px 10px;border:1px solid rgba(0,240,255,.35);border-radius:999px;margin-bottom:10px;opacity:.9}
    ul{margin-top:8px;line-height:1.7}
    .btns{display:flex;flex-wrap:wrap;gap:12px;margin-top:14px}
    .btn{display:inline-block;padding:10px 14px;border-radius:10px;font-weight:600;text-decoration:none;color:#001b20;background:var(--neon)}
    .btn.ghost{background:transparent;color:var(--neon);border:1px solid rgba(0,240,255,.5)}
    footer{position:relative;z-index:2;text-align:center;margin:26px 0 40px;opacity:.75}
    canvas#bg{position:fixed;inset:0;z-index:1}
    /* little form look */
    .form input{width:100%;margin:.35rem 0;padding:.55rem;border-radius:8px;border:1px solid rgba(0,240,255,.25);background:#0b141a;color:var(--text)}
    .form button{margin-top:.4rem}
  </style>
</head>
<body>
  <canvas id="bg"></canvas>

  <header>
    <h1>💻 Hectormoncler – IT-Tech</h1>
    <p>LEMP on Azure • Reverse Proxy • Azure Database for MySQL</p>
  </header>

  <div class="wrap">
    <div class="grid">

      <section class="card">
        <span class="pill">📅 Event</span>
        <h2>Event Info</h2>
        <p>Topic: <b>The Future of IT</b></p>
        <p>Date: <b>August 25, 2025</b></p>
        <p>Time: <b>15:00 CET</b></p>
        <div class="btns">
          <a class="btn ghost" href="/event/">Open Animated Event Page</a>
        </div>
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
          <li>Reverse Proxy: <code>/</code> → 5000, <code>/event/</code> → 8081</li>
          <li>Azure MySQL Flexible Server (private access)</li>
        </ul>
      </section>

      <section class="card">
        <span class="pill">🧪 Status</span>
        <h2>Health Check</h2>
        <ul>
          <li><a class="btn ghost" href="/health">Web health</a></li>
          <li><a class="btn ghost" href="/event/">Event page</a></li>
        </ul>
        <div class="form" style="margin-top:10px">
          <input placeholder="Your Name" />
          <input placeholder="Your Email" type="email" />
          <button class="btn">Join Now</button>
        </div>
      </section>

    </div>
  </div>

  <footer>© <script>document.write(new Date().getFullYear())</script> Hectormoncler • Azure LEMP Demo</footer>

  <script>
  // lightweight moving dots + lines background
  const c=document.getElementById('bg'),x=c.getContext('2d');let w,h,nodes=[];
  function R(){w=c.width=innerWidth;h=c.height=innerHeight;
    nodes=Array.from({length:60},()=>({x:Math.random()*w,y:Math.random()*h,vx:(Math.random()-.5),vy:(Math.random()-.5)}));
  }
  function D(){x.clearRect(0,0,w,h);x.fillStyle='#00f0ff';
    nodes.forEach(p=>{p.x+=p.vx;p.y+=p.vy;if(p.x<0||p.x>w)p.vx*=-1;if(p.y<0||p.y>h)p.vy*=-1;x.beginPath();x.arc(p.x,p.y,1.8,0,6.28);x.fill();});
    for(let i=0;i<nodes.length;i++)for(let j=i+1;j<nodes.length;j++){
      let a=nodes[i],b=nodes[j],dx=a.x-b.x,dy=a.y-b.y,d=Math.hypot(dx,dy); if(d<120){
        x.strokeStyle=`rgba(0,240,255,${1-d/120})`; x.lineWidth=1; x.beginPath(); x.moveTo(a.x,a.y); x.lineTo(b.x,b.y); x.stroke();
      }
    }
    requestAnimationFrame(D);
  }
  addEventListener('resize',R); R(); D();
  </script>
</body>
</html>
HTML

# -------------------------------------------------------------------
# Contact app: style.css
# -------------------------------------------------------------------
sudo tee "${WEB_ROOT}/style.css" >/dev/null <<'CSS'
/* Simple and clean styling for the contact app */
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Arial,Helvetica,sans-serif;line-height:1.6;color:#333;background:#f4f4f4}
.container{max-width:800px;margin:0 auto;padding:20px;background:#fff;min-height:100vh;box-shadow:0 0 10px rgba(0,0,0,.1)}
header{text-align:center;margin-bottom:30px;padding-bottom:20px;border-bottom:2px solid #eee}
header h1{color:#2c3e50;margin-bottom:10px}
header p{color:#7f8c8d;font-size:1.1em}
nav{text-align:center;margin-bottom:30px}
.btn{display:inline-block;padding:10px 20px;margin:0 5px;background:#3498db;color:#fff;text-decoration:none;border-radius:5px;border:none;cursor:pointer;font-size:16px;transition:background .3s}
.btn:hover{background:#2980b9}.btn.active{background:#2c3e50}
.btn.submit-btn{background:#27ae60;width:100%;margin-top:10px}.btn.submit-btn:hover{background:#229954}
main{margin-bottom:30px}
.features{background:#ecf0f1;padding:20px;border-radius:5px;margin-top:20px}
.features h3{color:#2c3e50;margin-bottom:10px}
.features ul{list-style:none;padding-left:0}
.features li{padding:5px 0;padding-left:20px;position:relative}
.features li:before{content:"✓";position:absolute;left:0;color:#27ae60;font-weight:bold}
.contact-form{background:#f8f9fa;padding:30px;border-radius:8px;border:1px solid #e9ecef}
.form-group{margin-bottom:20px}
.form-group label{display:block;margin-bottom:5px;font-weight:bold;color:#2c3e50}
.form-group input,.form-group textarea{width:100%;padding:10px;border:1px solid #ddd;border-radius:4px;font-size:16px}
.form-group input:focus,.form-group textarea:focus{outline:none;border-color:#3498db;box-shadow:0 0 5px rgba(52,152,219,.3)}
.success-message,.error-message,.info-message{padding:20px;margin:20px 0;border-radius:5px;text-align:center}
.success-message{background:#d4edda;color:#155724;border:1px solid #c3e6cb}
.error-message{background:#f8d7da;color:#721c24;border:1px solid #f5c6cb}
.info-message{background:#d1ecf1;color:#0c5460;border:1px solid #bee5eb}
.actions{text-align:center;margin-top:20px}
.messages-count{background:#e8f4fd;padding:10px;border-radius:5px;margin-bottom:20px;text-align:center}
.message-item{background:#f8f9fa;border:1px solid #e9ecef;border-radius:8px;padding:20px;margin-bottom:20px}
.message-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;border-bottom:1px solid #eee;padding-bottom:10px}
.message-header h3{color:#2c3e50;margin:0}.message-date{color:#7f8c8d;font-size:.9em}
.message-email{color:#3498db;margin-bottom:10px}.message-content{color:#555}
@media(max-width:600px){.container{padding:10px}.message-header{flex-direction:column;align-items:flex-start}.message-date{margin-top:5px}.btn{padding:8px 15px;font-size:14px;margin:2px}}
CSS

# -------------------------------------------------------------------
# Contact app: index.html
# -------------------------------------------------------------------
sudo tee "${WEB_ROOT}/index-app.html" >/dev/null <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Level 2.3: Azure MySQL Contact App</title>
  <link rel="stylesheet" href="style.css" />
</head>
<body>
  <div class="container">
    <header>
      <h1>📝 Azure MySQL Contact App</h1>
      <p>Level 2.3: LEMP Stack with Azure MySQL Flexible Server</p>
    </header>
    <nav>
      <a href="index.html" class="btn">Home</a>
      <a href="contact_form.html" class="btn">Contact Form</a>
      <a href="on_get_messages.php" class="btn">View Messages</a>
    </nav>
    <main>
      <h2>Welcome!</h2>
      <p>This is a PHP contact form application running on Azure with secure database connectivity.</p>
      <div class="features">
        <h3>Architecture Features:</h3>
        <ul>
          <li>Contact form with Azure MySQL database storage</li>
          <li>Secure private network connectivity</li>
          <li>Azure Database for MySQL Flexible Server</li>
          <li>SSL/TLS encrypted database connections</li>
          <li>Network Security Group protection</li>
          <li>Nginx web server with PHP-FPM</li>
        </ul>
      </div>
    </main>
  </div>
</body>
</html>
HTML

# -------------------------------------------------------------------
# Contact app: contact_form.html
# -------------------------------------------------------------------
sudo tee "${WEB_ROOT}/contact_form.html" >/dev/null <<'HTML'
<!DOCTYPE html>
<html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Contact Form - Azure MySQL Contact App</title>
<link rel="stylesheet" href="style.css">
</head><body>
<div class="container">
  <header><h1>✉️ Contact Form</h1></header>
  <nav>
    <a href="index.html" class="btn">Home</a>
    <a href="contact_form.html" class="btn active">Contact Form</a>
    <a href="on_get_messages.php" class="btn">View Messages</a>
  </nav>
  <main>
    <form action="on_post_contact.php" method="POST" class="contact-form">
      <div class="form-group"><label for="name">Name:</label><input type="text" id="name" name="name" required></div>
      <div class="form-group"><label for="email">Email:</label><input type="email" id="email" name="email" required></div>
      <div class="form-group"><label for="message">Message:</label><textarea id="message" name="message" rows="5" required></textarea></div>
      <button type="submit" class="btn submit-btn">Send Message</button>
    </form>
  </main>
</div>
</body></html>
HTML

# -------------------------------------------------------------------
# Contact app: database_setup.php  (reads /etc/webapp/mysql.env)
# Auto-creates 'contacts' table on first include.
# -------------------------------------------------------------------
sudo tee "${WEB_ROOT}/database_setup.php" >/dev/null <<'PHP'
<?php
// Load env file (created by CSE or provisioner)
$env = parse_ini_file('/etc/webapp/mysql.env', false, INI_SCANNER_TYPED);

$host = $env['MYSQL_HOST'] ?? '127.0.0.1';
$db   = $env['MYSQL_DB']   ?? 'flexibleserverdb';
$user = $env['MYSQL_USER'] ?? 'mysqladmin';
$pass = $env['MYSQL_PASS'] ?? '';
$ssl  = strtoupper($env['MYSQL_SSL'] ?? 'REQUIRED'); // DISABLED|PREFERRED|REQUIRED|VERIFY_CA|VERIFY_IDENTITY

$charset = 'utf8mb4';
$dsn = "mysql:host={$host};dbname={$db};charset={$charset}";
$options = [
  PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
  PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
  PDO::ATTR_EMULATE_PREPARES   => false,
];

// SSL mode handling for Azure MySQL
switch ($ssl) {
  case 'DISABLED':
    break;
  case 'PREFERRED':
  case 'REQUIRED':
  default:
    $options[PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT] = false;
    $options[PDO::MYSQL_ATTR_SSL_CA] = '/etc/ssl/certs/ca-certificates.crt';
    break;
}

try {
  $pdo = new PDO($dsn, $user, $pass, $options);
  // Ensure table exists (idempotent)
  $pdo->exec("
    CREATE TABLE IF NOT EXISTS contacts (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) NOT NULL,
      message TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ");
} catch (PDOException $e) {
  http_response_code(500);
  echo 'Database connection failed: ' . htmlspecialchars($e->getMessage());
  exit;
}
PHP

# -------------------------------------------------------------------
# Contact app: on_post_contact.php
# -------------------------------------------------------------------
sudo tee "${WEB_ROOT}/on_post_contact.php" >/dev/null <<'PHP'
<?php
require_once 'database_setup.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $name = trim($_POST['name'] ?? '');
  $email = trim($_POST['email'] ?? '');
  $message = trim($_POST['message'] ?? '');
  if ($name && $email && $message) {
    try {
      $stmt = $pdo->prepare("INSERT INTO contacts (name, email, message) VALUES (?, ?, ?)");
      $stmt->execute([$name, $email, $message]);
      $success = true;
    } catch (PDOException $e) {
      $error = "Error saving message: " . $e->getMessage();
    }
  } else {
    $error = "All fields are required.";
  }
}
?>
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Message Sent - Azure MySQL Contact App</title>
<link rel="stylesheet" href="style.css">
</head><body>
<div class="container">
  <header><h1>📨 Message Status</h1></header>
  <nav>
    <a href="index.html" class="btn">Home</a>
    <a href="contact_form.html" class="btn">Contact Form</a>
    <a href="on_get_messages.php" class="btn">View Messages</a>
  </nav>
  <main>
    <?php if (!empty($success)): ?>
      <div class="success-message"><h2>✅ Message Sent Successfully!</h2>
      <p>Thank you for your message. It has been saved to the Azure MySQL database.</p></div>
    <?php else: ?>
      <div class="error-message"><h2>❌ Error</h2>
      <p><?php echo htmlspecialchars($error ?? 'Unknown error'); ?></p></div>
    <?php endif; ?>
    <div class="actions">
      <a href="contact_form.html" class="btn">Send Another Message</a>
      <a href="on_get_messages.php" class="btn">View All Messages</a>
    </div>
  </main>
</div>
</body></html>
PHP

# -------------------------------------------------------------------
# Contact app: on_get_messages.php
# -------------------------------------------------------------------
sudo tee "${WEB_ROOT}/on_get_messages.php" >/dev/null <<'PHP'
<?php
require_once 'database_setup.php';

try {
  $stmt = $pdo->query("SELECT id, name, email, message, created_at FROM contacts ORDER BY created_at DESC");
  $messages = $stmt->fetchAll();
} catch (PDOException $e) {
  $error = "Error retrieving messages: " . $e->getMessage();
  $messages = [];
}
?>
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>All Messages - Azure MySQL Contact App</title>
<link rel="stylesheet" href="style.css">
</head><body>
<div class="container">
  <header><h1>📋 All Messages</h1></header>
  <nav>
    <a href="index.html" class="btn">Home</a>
    <a href="contact_form.html" class="btn">Contact Form</a>
    <a href="on_get_messages.php" class="btn active">View Messages</a>
  </nav>
  <main>
    <?php if (!empty($error)): ?>
      <div class="error-message"><h2>❌ Error</h2><p><?php echo htmlspecialchars($error); ?></p></div>
    <?php elseif (empty($messages)): ?>
      <div class="info-message"><h2>📭 No Messages Yet</h2>
      <p>No messages have been submitted yet.</p>
      <a href="contact_form.html" class="btn">Send First Message</a></div>
    <?php else: ?>
      <div class="messages-count"><p>Total messages: <strong><?php echo count($messages); ?></strong></p></div>
      <div class="messages-list">
        <?php foreach ($messages as $m): ?>
          <div class="message-item">
            <div class="message-header">
              <h3><?php echo htmlspecialchars($m['name']); ?></h3>
              <span class="message-date"><?php echo htmlspecialchars($m['created_at']); ?></span>
            </div>
            <p class="message-email">📧 <?php echo htmlspecialchars($m['email']); ?></p>
            <div class="message-content">
              <p><?php echo nl2br(htmlspecialchars($m['message'])); ?></p>
            </div>
          </div>
        <?php endforeach; ?>
      </div>
    <?php endif; ?>
  </main>
</div>
</body></html>
PHP

# -------------------------------------------------------------------
# Permissions
# -------------------------------------------------------------------
sudo chown -R www-data:www-data /var/www
sudo find "$WEB_ROOT"   -type d -exec chmod 755 {} \;
sudo find "$WEB_ROOT"   -type f -exec chmod 644 {} \;
sudo find "$EVENT_ROOT" -type d -exec chmod 755 {} \;
sudo find "$EVENT_ROOT" -type f -exec chmod 644 {} \;

echo "CSE: web content deployed to:
  - ${WEB_ROOT}   (served on :5000)
  - ${EVENT_ROOT} (served on :8081)
Config file for DB: ${ENV_FILE}
Remember to set MYSQL_HOST to your Flexible Server FQDN."
