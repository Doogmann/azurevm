#!/bin/bash 
set -eu # Exit on error, treat unset variables as an error

# Create the web root even if nginx hasn’t created it yet
install -d -m 0755 /var/www/html

# Write the web page
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Hectormoncler IT-Tech</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Courier New', monospace; background: #0a0a0a; color: #00f0ff; overflow: hidden; }
    header { text-align: center; padding: 40px; font-size: 2rem; letter-spacing: 2px; text-shadow: 0 0 10px #00f0ff; }
    main { position: relative; z-index: 2; text-align: center; }
    .card { display: inline-block; background: rgba(0,0,0,0.6); padding: 20px 40px; margin: 20px; border: 1px solid #00f0ff; border-radius: 8px; box-shadow: 0 0 20px rgba(0,240,255,0.4); transition: transform .2s ease, box-shadow .2s ease; }
    .card:hover { transform: translateY(-5px); box-shadow: 0 0 30px rgba(0,240,255,0.8); }
    canvas { position: fixed; top: 0; left: 0; z-index: 0; }
  </style>
</head>
<body>
  <canvas id="bg"></canvas>
  <header>💻 Hectormoncler – IT-Tech </header>
  <main>
    <div class="card">
      <h2>📅 Event Info</h2>
      <p>Topic: The Future of IT</p>
      <p>Date: August 25, 2025</p>
      <p>Time: 15:00 CET</p>
    </div>
    <div class="card">
      <h2>📝 Register</h2>
      <form>
        <input type="text" placeholder="Your Name" required><br><br>
        <input type="email" placeholder="Your Email" required><br><br>
        <button type="submit">Join Now</button>
      </form>
    </div>
  </main>
  <script>
    const canvas = document.getElementById("bg");
    const ctx = canvas.getContext("2d");
    let w, h, nodes;
    function resize(){ w=canvas.width=window.innerWidth; h=canvas.height=window.innerHeight;
      nodes = Array.from({length:50},()=>({x:Math.random()*w,y:Math.random()*h,vx:(Math.random()-.5)*1,vy:(Math.random()-.5)*1}));
    }
    function draw(){
      ctx.clearRect(0,0,w,h); ctx.fillStyle="#00f0ff";
      nodes.forEach(n=>{ n.x+=n.vx; n.y+=n.vy; if(n.x<0||n.x>w) n.vx*=-1; if(n.y<0||n.y>h) n.vy*=-1;
        ctx.beginPath(); ctx.arc(n.x,n.y,2,0,Math.PI*2); ctx.fill();
      });
      for(let i=0;i<nodes.length;i++) for(let j=i+1;j<nodes.length;j++){
        let dx=nodes[i].x-nodes[j].x, dy=nodes[i].y-nodes[j].y, dist=Math.hypot(dx,dy);
        if(dist<120){ ctx.strokeStyle="rgba(0,240,255,"+(1-dist/120)+")"; ctx.lineWidth=1; ctx.beginPath(); ctx.moveTo(nodes[i].x,nodes[i].y); ctx.lineTo(nodes[j].x,nodes[j].y); ctx.stroke(); }
      }
      requestAnimationFrame(draw);
    }
    window.addEventListener("resize", resize); resize(); draw();
  </script>
</body>
</html>
HTML

