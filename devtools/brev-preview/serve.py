#!/usr/bin/env python3
"""Utviklerverktøy for tiltakspenger-pdfgenrs.

Serverer devtools/brev-preview-siden og proxyer PDF-generering til pdfgenrs-serveren
(som verken sender CORS-headere eller kan serve statiske filer selv).
Kun Python-stdlib, ingen avhengigheter.

Bruk:
    ./run_devtools.sh               ->  http://localhost:8087

Miljøvariabler:
    DEVTOOLS_PORT       port for denne serveren (default 8087)
    PDFGEN_URL          overstyr pdfgenrs-adressen (default: 8084)
    LEGACY_PDFGEN_URL   overstyr gammel pdfgen-adresse (default: 8081)
"""
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PORT = int(os.environ.get("DEVTOOLS_PORT", "8087"))
PDFGEN_CANDIDATES = (
    [os.environ["PDFGEN_URL"]]
    if os.environ.get("PDFGEN_URL")
    else [
        "http://localhost:8084",  # både metarepoets og dette repoets docker-compose.yml
    ]
)

pdfgen_url = None


def is_alive(base_url):
    try:
        urllib.request.urlopen(base_url, timeout=1)
        return True
    except urllib.error.HTTPError:
        return True  # serveren svarte; statuskode er uinteressant
    except OSError:
        return False


def find_pdfgen():
    global pdfgen_url
    if pdfgen_url is None:
        pdfgen_url = next((url for url in PDFGEN_CANDIDATES if is_alive(url)), None)
    return pdfgen_url


# --- LEGACY PDFGEN (overgangsfase) -----------------------------------------
# Viser gammel pdfgen side om side med pdfgenrs. Slett alt som er merket
# "LEGACY PDFGEN" (grep etter det) når tiltakspenger-pdfgen fjernes.
LEGACY_REPO = os.path.join(os.path.dirname(REPO_ROOT), "tiltakspenger-pdfgen")
LEGACY_CANDIDATES = (
    [os.environ["LEGACY_PDFGEN_URL"]]
    if os.environ.get("LEGACY_PDFGEN_URL")
    else [
        "http://localhost:8081",  # både metarepoets og pdfgen-repoets docker-compose.yml
    ]
)
legacy_url = None


def find_legacy():
    global legacy_url
    if legacy_url is None:
        legacy_url = next((url for url in LEGACY_CANDIDATES if is_alive(url)), None)
    return legacy_url


def start_legacy():
    if not os.path.isdir(LEGACY_REPO):
        print(f"Fant ikke {LEGACY_REPO} - hopper over gammel pdfgen.")
        return
    print("Fant ingen kjørende pdfgen (gammel) - prøver å starte med docker compose ...")
    try:
        subprocess.run(["docker", "compose", "up", "-d", "--build"], cwd=LEGACY_REPO, check=True)
    except (OSError, subprocess.CalledProcessError) as e:
        print(f"Klarte ikke å starte gammel pdfgen ({e}).")
        print("Start den selv, f.eks. ../tiltakspenger-pdfgen/run_development.sh")
        return
    for _ in range(30):
        if find_legacy():
            return
        time.sleep(1)


def legacy_templates():
    template_dir = os.path.join(LEGACY_REPO, "templates", "tpts")
    if not os.path.isdir(template_dir):
        return []
    return sorted(f[:-4] for f in os.listdir(template_dir) if f.endswith(".hbs"))
# --- LEGACY PDFGEN slutt ----------------------------------------------------


def start_pdfgen():
    print("Fant ingen kjørende pdfgenrs - prøver å starte med docker compose ...")
    try:
        subprocess.run(["docker", "compose", "up", "-d", "--build"], cwd=REPO_ROOT, check=True)
    except (OSError, subprocess.CalledProcessError) as e:
        print(f"Klarte ikke å starte pdfgenrs ({e}).")
        print("Start den selv med `docker compose up -d --build` eller ./run_development.sh")
        return
    for _ in range(30):
        if find_pdfgen():
            return
        time.sleep(1)


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=REPO_ROOT, **kwargs)

    def do_GET(self):
        if self.path in ("/", "/index.html"):
            self.send_response(302)
            self.send_header("Location", "/devtools/brev-preview/index.html")
            self.end_headers()
        elif self.path == "/api/templates":
            data_dir = os.path.join(REPO_ROOT, "data", "tpts")
            names = sorted(f[:-5] for f in os.listdir(data_dir) if f.endswith(".json"))
            self._respond(200, "application/json", json.dumps(names).encode())
        elif self.path == "/api/legacy/templates":  # LEGACY PDFGEN: slett denne elif-blokken
            self._respond(200, "application/json", json.dumps(legacy_templates()).encode())
        elif self.path.startswith("/api/legacy/data/"):  # LEGACY PDFGEN: slett denne elif-blokken
            # Malnavnet kommer fra URL-en; valider mot tegn-allowlist og sjekk at stien blir værende i datamappen.
            name = os.path.basename(urllib.parse.unquote(self.path[len("/api/legacy/data/"):]))
            data_dir = os.path.realpath(os.path.join(LEGACY_REPO, "data", "tpts"))
            data_file = os.path.realpath(os.path.join(data_dir, name + ".json"))
            if re.fullmatch(r"[\w-]+", name) and data_file.startswith(data_dir + os.sep) and os.path.isfile(data_file):
                with open(data_file, "rb") as f:
                    self._respond(200, "application/json", f.read())
            else:
                self.send_error(404)
        else:
            super().do_GET()

    def do_POST(self):
        if self.path.startswith("/api/legacy/genpdf/"):  # LEGACY PDFGEN: slett denne if-blokken
            self._proxy_genpdf(find_legacy(), self.path[len("/api/legacy"):], "gammel pdfgen")
        elif self.path.startswith("/api/genpdf/"):
            self._proxy_genpdf(find_pdfgen(), self.path[len("/api"):], "pdfgenrs")
        else:
            self.send_error(404)

    def _proxy_genpdf(self, target, genpdf_path, name):
        if target is None:
            self._respond(502, "text/plain; charset=utf-8", f"{name} kjører ikke.".encode())
            return
        # Stien kommer fra URL-en; slipp kun gjennom /genpdf/<app>/<mal> så requesten ikke kan styres andre steder.
        genpdf_path = urllib.parse.unquote(genpdf_path)
        if not re.fullmatch(r"/genpdf/[\w-]+/[\w-]+", genpdf_path):
            self.send_error(404)
            return
        body = self.rfile.read(int(self.headers.get("Content-Length", 0)))
        req = urllib.request.Request(
            target + "/api/v1" + urllib.parse.quote(genpdf_path),
            data=body,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                self._respond(resp.status, resp.headers.get("Content-Type", "application/pdf"), resp.read())
        except urllib.error.HTTPError as e:
            self._respond(e.code, e.headers.get("Content-Type", "text/plain"), e.read())
        except OSError as e:
            self._respond(502, "text/plain; charset=utf-8", f"Får ikke kontakt med {name} på {target}: {e}".encode())

    def _respond(self, status, content_type, body):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass  # ikke spam terminalen for hver request


def main():
    if find_pdfgen() is None:
        start_pdfgen()
    if pdfgen_url:
        print(f"pdfgenrs: {pdfgen_url}")
    else:
        print("pdfgenrs kjører fortsatt ikke - PDF-generering vil feile til den er oppe.")
    # LEGACY PDFGEN: slett disse tre linjene når pdfgen fjernes
    if legacy_templates() and find_legacy() is None:
        start_legacy()
    print(f"pdfgen (gammel): {legacy_url or 'kjører ikke'}")
    print(f"Devtools:  http://localhost:{PORT}")
    try:
        ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
    except KeyboardInterrupt:
        sys.exit(0)


if __name__ == "__main__":
    main()
