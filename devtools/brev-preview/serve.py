#!/usr/bin/env python3
"""Utviklerverktøy for tiltakspenger-pdfgenrs.

Serverer devtools/brev-preview-siden og proxyer PDF-generering til pdfgenrs-serveren
(som verken sender CORS-headere eller kan serve statiske filer selv).
Versjonssammenligning (pdfgenrs mot pdfgenrs på en annen git-ref) ligger i versions.py.
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
import signal
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

import versions
from common import REPO_ROOT, is_alive

PORT = int(os.environ.get("DEVTOOLS_PORT", "8087"))
PDFGEN_CANDIDATES = (
    [os.environ["PDFGEN_URL"]]
    if os.environ.get("PDFGEN_URL")
    else [
        "http://localhost:8084",  # både metarepoets og dette repoets docker-compose.yml
    ]
)

pdfgen_url = None


def find_pdfgen():
    global pdfgen_url
    if pdfgen_url is None:
        pdfgen_url = next((url for url in PDFGEN_CANDIDATES if is_alive(url)), None)
    return pdfgen_url


def serves_working_tree(url):
    """Sjekker at containeren bak url-en faktisk volum-monterer dette repoet.

    Metarepoets compose kjører pdfgenrs på samme port, men UTEN volumer - da er
    malene bakt inn i imaget ved build, og forhåndsvisningen ville stille vist
    en gammel versjon i stedet for arbeidskatalogen.
    Returnerer None når det ikke lar seg avgjøre (ikke en lokal container e.l.).
    """
    port = urllib.parse.urlparse(url).port
    ps = subprocess.run(
        ["docker", "ps", "--filter", f"publish={port}", "--format", "{{.Names}}"],
        capture_output=True, text=True,
    )
    names = ps.stdout.split()
    if ps.returncode != 0 or not names:
        return None
    mounts = subprocess.run(
        ["docker", "inspect", names[0], "--format", "{{range .Mounts}}{{.Source}}\n{{end}}"],
        capture_output=True, text=True,
    )
    if mounts.returncode != 0:
        return None
    return any(line.startswith(REPO_ROOT) for line in mounts.stdout.splitlines())


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
        elif self.path == "/api/refs":
            self._respond(200, "application/json", json.dumps(versions.list_refs()).encode())
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
        ref_proxy = re.fullmatch(r"/api/ref/([0-9a-f]{40})(/genpdf/.*)", self.path)
        if self.path.startswith("/api/legacy/genpdf/"):  # LEGACY PDFGEN: slett denne if-blokken
            self._proxy_genpdf(find_legacy(), self.path[len("/api/legacy"):], "gammel pdfgen")
        elif self.path.startswith("/api/genpdf/"):
            self._proxy_genpdf(find_pdfgen(), self.path[len("/api"):], "pdfgenrs")
        elif self.path == "/api/ref/prepare":
            body = self.rfile.read(int(self.headers.get("Content-Length", 0)))
            try:
                sha = versions.prepare_ref(json.loads(body)["ref"])
                self._respond(200, "application/json", json.dumps({"sha": sha}).encode())
            except versions.RefError as e:
                self._respond(400, "text/plain; charset=utf-8", str(e).encode())
        elif ref_proxy:
            sha, genpdf_path = ref_proxy.groups()
            target = versions.instance_url(sha)
            if target is None:
                self._respond(502, "text/plain; charset=utf-8", "Ukjent versjons-instans - last siden på nytt.".encode())
            else:
                self._proxy_genpdf(target, genpdf_path, f"pdfgenrs @ {sha[:12]}")
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
    # sys.exit -> atexit -> versions.py rydder containere/worktrees, også ved `kill`
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    global pdfgen_url
    if find_pdfgen() is None:
        start_pdfgen()
    # Ikke stol blindt på containeren vi fant: uten repo-volumer (metarepoets
    # compose) viser den en innbakt gammel versjon, ikke arbeidskatalogen.
    # PDFGEN_URL satt eksplisitt betyr at brukeren vet hva de gjør.
    if pdfgen_url and not os.environ.get("PDFGEN_URL") and serves_working_tree(pdfgen_url) is False:
        print(f"ADVARSEL: containeren på {pdfgen_url} monterer ikke dette repoet")
        print("(sannsynligvis metarepoets compose, som baker malene inn i imaget ved build).")
        try:
            pdfgen_url = versions.worktree_url()
            print("Starter derfor en egen pdfgenrs for arbeidskatalogen.")
        except versions.RefError as e:
            print(f"Klarte ikke å starte egen pdfgenrs for arbeidskatalogen ({e}) - "
                  f"forhåndsvisningen kan vise en utdatert versjon!")
    if pdfgen_url:
        print(f"pdfgenrs: {pdfgen_url}")
    else:
        print("pdfgenrs kjører fortsatt ikke - PDF-generering vil feile til den er oppe.")
    # LEGACY PDFGEN: slett disse tre linjene når pdfgen fjernes
    if legacy_templates() and find_legacy() is None:
        start_legacy()
    print(f"pdfgen (gammel): {legacy_url or 'kjører ikke'}")
    print(f"Devtools:  http://localhost:{PORT}")
    print("Containere devtoolsen starter heter pdfgenrs-devtools-* (porter "
          f"{versions.CONTAINER_PORTS.start}-{versions.CONTAINER_PORTS.stop - 1}) og fjernes ved avslutning.")
    try:
        ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
    except KeyboardInterrupt:
        sys.exit(0)


if __name__ == "__main__":
    main()
