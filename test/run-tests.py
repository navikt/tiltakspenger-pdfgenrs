#!/usr/bin/env python3
"""Tester alle brevmalene mot en kjørende pdfgenrs.

Kjøres i testrunner-containeren via ./run_tests.sh (se docker-compose.test.yml).
Ved feil skrives responsene til build/test/ for feilsøking.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

import pypdfium2 as pdfium

PDFGENRS_URL = os.environ.get("PDFGENRS_URL", "http://pdfgenrs:8080")
REPO = Path(os.environ.get("REPO_DIR", "/repo"))
DATA_DIR = REPO / "data" / "tpts"
TEMPLATE_DIR = REPO / "templates" / "tpts"
VARIANT_DIR = REPO / "test" / "data"
DEBUG_DIR = REPO / "build" / "test"

A4_PUNKTER = (595.3, 841.9)

# Datasett der filnavnet ikke er likt malnavnet.
# Varianter i test/data/ bruker konvensjonen <mal>--<variant>.json og trenger ikke listes her.
DATA_TIL_MAL = {
    "meldekort-korrigert": "meldekort",
    "meldekort-korrigert-en": "meldekort-en",
}

# Alle utgående vedtaksbrev skal ha den felles halen (vedtaksinfo) og den felles signaturen.
UTGÅENDE_MALER = {
    "klageAvvis",
    "klageInnstilling",
    "meldekortvedtak",
    "revurderingInnvilgelse",
    "stansvedtak",
    "utbetalingsvedtak",
    "vedtakAvslag",
    "vedtakInnvilgelse",
    "vedtakOpphør",
}
UTGÅENDE_KRAV = ["Du har rett til å klage", "Har du spørsmål?", "Med vennlig hilsen", "Nav Tiltak Oslo", "side 1 av"]

# Innholdskrav per datasett, utover standardkravene for utgående brev.
# "krever" må finnes i teksten, "forbyr" må ikke finnes.
INNHOLDSKRAV = {
    "klageAvvis": {"krever": ["Du har rett til innsyn"]},
    # klageInnstilling er et oversendelsesbrev, ikke et vedtaksbrev, og har med vilje ingen klagerett-hale.
    "klageInnstilling": {"krever": ["Har du spørsmål?", "Med vennlig hilsen", "Nav Tiltak Oslo", "Oversendelsesbrev til Nav Klageinstans", "side 1 av"]},
    "vedtakInnvilgelse": {"krever": ["Du har rett til innsyn"]},
    "meldekort": {"krever": ["Meldekort for tiltakspenger", "side 1 av"], "forbyr": ["Med vennlig hilsen"]},
    "meldekort-korrigert": {"krever": ["Meldekort for tiltakspenger"], "forbyr": ["Med vennlig hilsen"]},
    "soknad": {"forbyr": ["Med vennlig hilsen"]},
    "klageAvvis--uten-saksbehandler": {"krever": ["ingen saksbehandler tildelt"]},
    "vedtakInnvilgelse--tom-beslutter": {"forbyr": ["ingen saksbehandler tildelt"]},
    "vedtakInnvilgelse--tom-saksbehandler": {"krever": ["ingen saksbehandler tildelt"]},
    "meldekortvedtak--automatisk": {"krever": ["Automatisk behandlet"], "forbyr": ["Med vennlig hilsen", "Nav Tiltak Oslo"]},
    "utbetalingsvedtak--automatisk": {"krever": ["Automatisk behandlet"], "forbyr": ["Med vennlig hilsen", "Nav Tiltak Oslo"]},
}
# Datasett der standardkravene for utgående brev ikke gjelder: automatisk behandlede vedtak har ingen signatur, og klageInnstilling har egen kravliste.
UTEN_STANDARDKRAV = {"klageInnstilling", "meldekortvedtak--automatisk", "utbetalingsvedtak--automatisk"}


def malnavn(datanavn):
    if "--" in datanavn:
        return datanavn.split("--")[0]
    return DATA_TIL_MAL.get(datanavn, datanavn)


def vent_på_server():
    frist = time.time() + 60
    while time.time() < frist:
        try:
            urllib.request.urlopen(PDFGENRS_URL, timeout=2)
            return
        except urllib.error.HTTPError:
            return  # serveren svarte; statuskode er uinteressant
        except OSError:
            time.sleep(1)
    print(f"FEIL: pdfgenrs på {PDFGENRS_URL} svarte ikke innen fristen.")
    sys.exit(1)


def render(mal, payload):
    req = urllib.request.Request(
        f"{PDFGENRS_URL}/api/v1/genpdf/tpts/{urllib.parse.quote(mal)}",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return resp.status, resp.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()


def lagre_debug(navn, suffix, innhold):
    DEBUG_DIR.mkdir(parents=True, exist_ok=True)
    path = DEBUG_DIR / f"{navn}{suffix}"
    path.write_bytes(innhold)
    return path


def innholdskrav(navn, mal):
    regler = INNHOLDSKRAV.get(navn, {})
    krever = list(regler.get("krever", []))
    forbyr = list(regler.get("forbyr", []))
    if mal in UTGÅENDE_MALER and navn not in UTEN_STANDARDKRAV:
        krever = UTGÅENDE_KRAV + krever
    return krever, forbyr


def sjekk_pdf(navn, mal, body, feil):
    pdf = pdfium.PdfDocument(body)
    try:
        if len(pdf) == 0:
            feil.append(f"{navn}: PDF-en har ingen sider")
            return False

        tekst = ""
        for side in pdf:
            bredde, høyde = side.get_size()
            if abs(bredde - A4_PUNKTER[0]) > 1 or abs(høyde - A4_PUNKTER[1]) > 1:
                feil.append(f"{navn}: sidestørrelsen {bredde:.0f}x{høyde:.0f}pt er ikke A4")
                return False
            tekstside = side.get_textpage()
            tekst += tekstside.get_text_range()
            tekstside.close()
            side.close()

        ok = True
        krever, forbyr = innholdskrav(navn, mal)
        for streng in krever:
            if streng not in tekst:
                feil.append(f"{navn}: mangler teksten «{streng}»")
                ok = False
        for streng in forbyr:
            if streng in tekst:
                feil.append(f"{navn}: skal ikke inneholde teksten «{streng}»")
                ok = False
        return ok
    finally:
        pdf.close()


def test_datasett(datafil, feil):
    navn = datafil.stem
    mal = malnavn(navn)
    if not (TEMPLATE_DIR / f"{mal}.typ").is_file():
        feil.append(f"{navn}: fant ingen mal '{mal}.typ' (sjekk DATA_TIL_MAL i run-tests.py)")
        return

    payload = datafil.read_bytes()
    json.loads(payload)  # valider testdataene før de sendes

    status, body = render(mal, payload)
    if status != 200:
        sti = lagre_debug(navn, ".feil.txt", body)
        feil.append(f"{navn}: HTTP {status} fra malen '{mal}' (respons i {sti})")
        return
    if not body.startswith(b"%PDF-"):
        sti = lagre_debug(navn, ".feil.bin", body)
        feil.append(f"{navn}: responsen er ikke en PDF (respons i {sti})")
        return

    if not sjekk_pdf(navn, mal, body, feil):
        lagre_debug(navn, ".feil.pdf", body)
        return

    print(f"OK   {navn} -> {mal} ({len(body)} bytes)")


def main():
    vent_på_server()

    datafiler = sorted(DATA_DIR.glob("*.json")) + sorted(VARIANT_DIR.glob("*.json"))
    if not datafiler:
        print("FEIL: fant ingen testdata.")
        sys.exit(1)

    feil = []
    for datafil in datafiler:
        test_datasett(datafil, feil)

    print(f"\n{len(datafiler) - len(feil)}/{len(datafiler)} datasett ok")
    if feil:
        for f in feil:
            print(f"FEIL {f}")
        sys.exit(1)


if __name__ == "__main__":
    main()
