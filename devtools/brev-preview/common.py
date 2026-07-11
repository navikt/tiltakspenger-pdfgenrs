"""Delt mellom serve.py og versions.py: repo-rota og liveness-sjekk."""
import os
import urllib.error
import urllib.request

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def is_alive(base_url):
    try:
        urllib.request.urlopen(base_url, timeout=1)
        return True
    except urllib.error.HTTPError:
        return True  # serveren svarte; statuskode er uinteressant
    except OSError:
        return False
