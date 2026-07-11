"""Versjonssammenligning: pdfgenrs mot pdfgenrs på en vilkårlig git-ref.

Siden pdfgenrs bare er upstream-imaget med templates/fonts/data/resources/lib
montert som volumer, trenger vi ikke bygge noe for å vise en annen versjon:
hver ref får et git-worktree under ~/.cache og en egen container på en ledig
port. Containere og worktrees ryddes når serve.py avsluttes.
"""
import atexit
import os
import re
import shutil
import socket
import subprocess
import threading
import time

from common import REPO_ROOT, is_alive

WORKTREES_DIR = os.path.expanduser("~/.cache/tiltakspenger-pdfgenrs-devtools/worktrees")
# Containerne legges på et fast, dokumentert portspenn så de ikke går i beina på
# andre tjenester: 8091 er wiremock i metarepoets compose, og 8090 lar vi stå som margin.
CONTAINER_PORTS = range(8092, 8100)
ref_instances = {}  # commit-sha -> {"url", "container", "worktree"}
ref_lock = threading.Lock()


class RefError(Exception):
    """Brukerfeil (ukjent ref, docker nede o.l.) - svarer 400 med meldingen."""


def run_git(*args):
    return subprocess.run(["git", "-C", REPO_ROOT, *args], capture_output=True, text=True)


def list_refs():
    """Grener og siste commits, til forslagslisten i ref-feltene."""
    refs = run_git("for-each-ref", "--format=%(refname:short)", "refs/heads/", "refs/remotes/origin/")
    branches = [b for b in refs.stdout.splitlines() if b and b != "origin"]  # "origin" = origin/HEAD
    commits = []
    for line in run_git("log", "-n", "20", "--format=%h%x09%s").stdout.splitlines():
        sha, _, subject = line.partition("\t")
        commits.append({"sha": sha, "subject": subject})
    head = run_git("symbolic-ref", "--short", "refs/remotes/origin/HEAD").stdout.strip()
    default = head.removeprefix("origin/") if head else "main"
    return {"default": default, "branches": branches, "commits": commits}


def prepare_ref(ref):
    """Sørger for at en pdfgenrs kjører for ref-en; returnerer commit-sha-en.

    Ref-en resolves på nytt hver gang, så en gren som har fått nye commits
    får automatisk en fersk instans ved neste generering.
    """
    ref = ref.strip()
    if not ref or ref.startswith("-"):
        raise RefError(f"Ugyldig ref: {ref!r}")
    resolved = run_git("rev-parse", "--verify", "--quiet", ref + "^{commit}")
    if resolved.returncode != 0:
        raise RefError(f"Ukjent git-ref: {ref}")
    sha = resolved.stdout.strip()
    with ref_lock:
        instance = ref_instances.get(sha)
        if instance and is_alive(instance["url"]):
            return sha
        if instance:  # containeren er borte (stoppet/fjernet manuelt) - lag på nytt
            _remove_instance(sha)
        ref_instances[sha] = _start_instance(sha, ref)
    return sha


def instance_url(sha):
    instance = ref_instances.get(sha)
    return instance["url"] if instance else None


def worktree_url():
    """En pdfgenrs som garantert serverer arbeidskatalogen (dette repoet, volum-montert).

    Brukes når containeren på PDFGEN_URL viser seg å ikke montere repoet
    (typisk metarepoets compose, som baker malene inn i imaget ved build).
    """
    global _worktree_instance
    with ref_lock:
        if _worktree_instance and is_alive(_worktree_instance["url"]):
            return _worktree_instance["url"]
        _worktree_instance = _run_container("pdfgenrs-devtools-arbeidskatalog", REPO_ROOT, _image_for(None), "arbeidskatalogen")
        return _worktree_instance["url"]


_worktree_instance = None


def _image_for(sha):
    """Imaget fra ref-ens Dockerfile (None = arbeidskatalogens)."""
    dockerfile = run_git("show", f"{sha}:Dockerfile").stdout if sha else ""
    if not dockerfile:
        with open(os.path.join(REPO_ROOT, "Dockerfile")) as f:
            dockerfile = f.read()
    image_match = re.search(r"^FROM\s+(\S+)", dockerfile, re.M)
    if image_match is None:
        raise RefError("Fant ingen FROM i Dockerfile")
    return image_match.group(1)


def _free_port():
    for port in CONTAINER_PORTS:
        with socket.socket() as s:
            try:
                s.bind(("127.0.0.1", port))
            except OSError:
                continue
            return port
    raise RefError(
        f"Ingen ledige porter i {CONTAINER_PORTS.start}-{CONTAINER_PORTS.stop - 1} - "
        "fjern noen med: docker rm -f $(docker ps -q --filter name=pdfgenrs-devtools)"
    )


def _run_container(container, src_dir, image, label):
    subprocess.run(["docker", "rm", "-f", container], capture_output=True)  # frigjør navn og port fra forrige økt
    port = _free_port()
    volumes = []
    for d in ("templates", "fonts", "data", "resources", "lib"):
        path = os.path.join(src_dir, d)
        if os.path.isdir(path):
            volumes += ["-v", f"{path}:/app/{d}"]
    print(f"pdfgenrs @ {label}: starter {image} som '{container}' på http://localhost:{port} (fjernes ved avslutning)")
    instance = {"url": f"http://localhost:{port}", "container": container}
    run = subprocess.run(
        ["docker", "run", "-d", "--rm", "--platform", "linux/amd64", "--name", container,
         "--label", "devtools.opphav=tiltakspenger-pdfgenrs/run_devtools.sh",
         "--label", f"devtools.viser={label}",
         "--label", f"devtools.kilde={src_dir}",
         "-p", f"127.0.0.1:{port}:8080", "-e", "DEV_MODE=true", *volumes, image],
        capture_output=True, text=True,
    )
    if run.returncode != 0:
        _remove_instance_files(instance)
        raise RefError(f"docker run feilet: {run.stderr.strip()}")
    for _ in range(60):
        if is_alive(instance["url"]):
            return instance
        time.sleep(1)
    _remove_instance_files(instance)
    raise RefError(f"pdfgenrs @ {label} svarte ikke innen 60s")


def _start_instance(sha, ref):
    short = sha[:12]
    worktree = os.path.join(WORKTREES_DIR, short)
    # Rydd rester fra en tidligere økt som ikke fikk avsluttet ordentlig
    run_git("worktree", "remove", "--force", worktree)
    shutil.rmtree(worktree, ignore_errors=True)
    run_git("worktree", "prune")
    os.makedirs(WORKTREES_DIR, exist_ok=True)
    added = run_git("worktree", "add", "--detach", worktree, sha)
    if added.returncode != 0:
        raise RefError(f"git worktree add feilet: {added.stderr.strip()}")
    try:
        instance = _run_container(f"pdfgenrs-devtools-{short}", worktree, _image_for(sha), f"{ref} ({short})")
    except RefError:
        _remove_instance_files({"container": f"pdfgenrs-devtools-{short}", "worktree": worktree})
        raise
    instance["worktree"] = worktree
    return instance


def _remove_instance_files(instance):
    subprocess.run(["docker", "rm", "-f", instance["container"]], capture_output=True)
    if "worktree" in instance:
        run_git("worktree", "remove", "--force", instance["worktree"])
        shutil.rmtree(instance["worktree"], ignore_errors=True)
        run_git("worktree", "prune")


def _remove_instance(sha):
    _remove_instance_files(ref_instances.pop(sha))


@atexit.register
def _cleanup():
    for sha in list(ref_instances):
        _remove_instance(sha)
    if _worktree_instance:
        _remove_instance_files(_worktree_instance)
