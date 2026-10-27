#!/usr/bin/env python3
import os
import sys
import glob
import time
import queue
import subprocess
import threading
from pathlib import Path
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler

RESUME_DIR = Path(__file__).resolve().parent
PREVIEW_DIR = Path("/tmp/resume_preview")
INPUT_FILE = RESUME_DIR / "template" / "template.typ"
PDF_FILE = RESUME_DIR / "Abdullah_Al_Khalid_CV.pdf"

PREVIEW_DIR.mkdir(parents=True, exist_ok=True)

clients = set()
clients_lock = threading.Lock()
state = {
    "version": 0,
    "last_build": "Never",
    "pages": [],
    "error": None
}

def compile_resume():
    t0 = time.time()
    try:
        for f in PREVIEW_DIR.glob("page-*.svg"):
            try:
                f.unlink()
            except OSError:
                pass

        pdf_res = subprocess.run(
            ["typst", "compile", "--root", str(RESUME_DIR), str(INPUT_FILE), str(PDF_FILE)],
            cwd=str(RESUME_DIR),
            capture_output=True,
            text=True
        )
        if pdf_res.returncode != 0:
            state["error"] = pdf_res.stderr
            return False

        svg_target = str(PREVIEW_DIR / "page-{p}.svg")
        svg_res = subprocess.run(
            ["typst", "compile", "--root", str(RESUME_DIR), str(INPUT_FILE), svg_target],
            cwd=str(RESUME_DIR),
            capture_output=True,
            text=True
        )
        if svg_res.returncode != 0:
            state["error"] = svg_res.stderr
            return False

        svg_files = sorted(list(PREVIEW_DIR.glob("page-*.svg")), key=lambda p: int(p.stem.split("-")[1]))
        state["pages"] = [f.name for f in svg_files]
        state["version"] += 1
        state["error"] = None
        duration = round((time.time() - t0) * 1000)
        state["last_build"] = f"{time.strftime('%H:%M:%S')} ({duration}ms)"
        return True
    except Exception as e:
        state["error"] = str(e)
        return False

def broadcast_update():
    with clients_lock:
        dead = set()
        for q in clients:
            try:
                q.put_nowait(state["version"])
            except Exception:
                dead.add(q)
        clients.difference_update(dead)

def watch_loop():
    last_mtimes = {}
    compile_resume()
    broadcast_update()

    def get_watch_files():
        files = []
        for ext in ("*.typ", "*.yml", "*.yaml", "*.json", "*.toml"):
            files.extend(RESUME_DIR.rglob(ext))
        return [f for f in files if "/." not in str(f) and not str(f).startswith(str(PREVIEW_DIR))]

    while True:
        time.sleep(0.4)
        files = get_watch_files()
        changed = False
        current_mtimes = {}
        for f in files:
            try:
                mtime = f.stat().st_mtime
                current_mtimes[f] = mtime
                if f not in last_mtimes or last_mtimes[f] != mtime:
                    changed = True
            except OSError:
                pass

        if len(files) != len(last_mtimes):
            changed = True

        if changed:
            last_mtimes = current_mtimes
            if compile_resume():
                broadcast_update()

HTML_PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Resume Preview (Local Only)</title>
  <style>
    :root {
      --bg: #18181b;
      --header-bg: rgba(24, 24, 27, 0.9);
      --accent: #10b981;
      --text: #f4f4f5;
      --muted: #a1a1aa;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: var(--bg);
      color: var(--text);
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }
    header {
      position: sticky;
      top: 0;
      z-index: 50;
      background: var(--header-bg);
      backdrop-filter: blur(12px);
      border-bottom: 1px solid rgba(255,255,255,0.08);
      padding: 0.75rem 1.5rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .brand {
      display: flex;
      align-items: center;
      gap: 0.75rem;
    }
    .badge {
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      font-size: 0.75rem;
      padding: 0.2rem 0.6rem;
      border-radius: 9999px;
      background: rgba(16, 185, 129, 0.15);
      color: var(--accent);
      font-weight: 600;
    }
    .badge .dot {
      width: 6px;
      height: 6px;
      background: var(--accent);
      border-radius: 50%;
      animation: pulse 2s infinite;
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.4; transform: scale(0.85); }
    }
    .actions {
      display: flex;
      align-items: center;
      gap: 1rem;
    }
    .status-text {
      font-size: 0.8rem;
      color: var(--muted);
    }
    .btn {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      padding: 0.45rem 0.95rem;
      border-radius: 6px;
      background: #2563eb;
      color: white;
      text-decoration: none;
      font-size: 0.85rem;
      font-weight: 500;
    }
    .btn:hover { background: #1d4ed8; }
    main {
      flex: 1;
      padding: 2rem 1rem 4rem;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 2rem;
    }
    .page-container {
      width: 100%;
      max-width: 820px;
      background: white;
      border-radius: 2px;
      box-shadow: 0 12px 35px rgba(0,0,0,0.55);
      overflow: hidden;
      line-height: 0;
    }
    .page-container img {
      width: 100%;
      height: auto;
      display: block;
    }
    .error-banner {
      display: none;
      max-width: 820px;
      width: 100%;
      background: #7f1d1d;
      color: #fecaca;
      padding: 1rem;
      border-radius: 6px;
      font-family: monospace;
      font-size: 0.85rem;
      white-space: pre-wrap;
    }
  </style>
</head>
<body>
  <header>
    <div class="brand">
      <h1 style="font-size: 1rem; font-weight: 600;">Abdullah Al Khalid — Resume</h1>
      <span class="badge"><span class="dot"></span> Local Only</span>
    </div>
    <div class="actions">
      <span class="status-text" id="status">Syncing...</span>
      <a href="/Abdullah_Al_Khalid_CV.pdf" download class="btn">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        Download PDF
      </a>
    </div>
  </header>

  <main id="main">
    <div id="error" class="error-banner"></div>
    <div id="pages-wrapper" style="width: 100%; display: flex; flex-direction: column; align-items: center; gap: 2rem;"></div>
  </main>

  <script>
    let currentVersion = -1;
    const pagesWrapper = document.getElementById('pages-wrapper');
    const statusEl = document.getElementById('status');
    const errorEl = document.getElementById('error');

    async function refreshContent() {
      try {
        const res = await fetch('/api/status');
        const data = await res.json();
        
        statusEl.innerText = "Updated " + data.last_build;
        if (data.error) {
          errorEl.style.display = 'block';
          errorEl.innerText = data.error;
        } else {
          errorEl.style.display = 'none';
        }

        if (data.version !== currentVersion) {
          currentVersion = data.version;
          pagesWrapper.innerHTML = '';
          data.pages.forEach((pageName, idx) => {
            const container = document.createElement('div');
            container.className = 'page-container';
            const img = document.createElement('img');
            img.src = '/pages/' + pageName + '?v=' + data.version;
            img.alt = 'Resume Page ' + (idx + 1);
            container.appendChild(img);
            pagesWrapper.appendChild(container);
          });
        }
      } catch (err) {
        statusEl.innerText = "Reconnecting...";
      }
    }

    refreshContent();

    const evtSource = new EventSource('/events');
    evtSource.onmessage = function() {
      refreshContent();
    };
    evtSource.onerror = function() {
      setTimeout(refreshContent, 1500);
    };
  </script>
</body>
</html>
"""

class ResumeHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        if self.path == "/" or self.path == "/index.html":
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Cache-Control", "no-cache")
            self.end_headers()
            self.wfile.write(HTML_PAGE.encode("utf-8"))
            return

        if self.path == "/events":
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Connection", "keep-alive")
            self.end_headers()

            q = queue.Queue()
            with clients_lock:
                clients.add(q)

            try:
                self.wfile.write(b"data: init\n\n")
                self.wfile.flush()
                while True:
                    try:
                        ver = q.get(timeout=20)
                        self.wfile.write(f"data: {ver}\n\n".encode("utf-8"))
                        self.wfile.flush()
                    except queue.Empty:
                        self.wfile.write(b": keepalive\n\n")
                        self.wfile.flush()
            except (BrokenPipeError, ConnectionResetError):
                pass
            finally:
                with clients_lock:
                    clients.discard(q)
            return

        if self.path == "/api/status":
            import json
            payload = json.dumps(state).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Cache-Control", "no-cache")
            self.end_headers()
            self.wfile.write(payload)
            return

        if self.path.startswith("/Abdullah_Al_Khalid_CV.pdf"):
            if PDF_FILE.exists():
                data = PDF_FILE.read_bytes()
                self.send_response(200)
                self.send_header("Content-Type", "application/pdf")
                self.send_header("Content-Disposition", "inline; filename=Abdullah_Al_Khalid_CV.pdf")
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)
            else:
                self.send_error(404, "PDF not generated yet")
            return

        if self.path.startswith("/pages/"):
            filename = self.path.split("/pages/")[1].split("?")[0]
            page_path = PREVIEW_DIR / filename
            if page_path.exists() and page_path.suffix == ".svg":
                data = page_path.read_bytes()
                self.send_response(200)
                self.send_header("Content-Type", "image/svg+xml")
                self.send_header("Cache-Control", "public, max-age=60")
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)
            else:
                self.send_error(404, "Page not found")
            return

        self.send_error(404, "Not Found")

def run():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    watcher = threading.Thread(target=watch_loop, daemon=True)
    watcher.start()

    # Bind strictly to 127.0.0.1 (Localhost only, inaccessible to the outside or LAN)
    server = ThreadingHTTPServer(("127.0.0.1", port), ResumeHandler)
    print(f"Resume preview running locally only: http://127.0.0.1:{port}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass

if __name__ == "__main__":
    run()
