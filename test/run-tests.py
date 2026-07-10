#!/usr/bin/env python3
"""Tester alle brevmalene mot en kjørende pdfgenrs.

Kjøres i testrunner-containeren via ./run_tests.sh (se docker-compose.test.yml).
Ved feil skrives responsene til build/test/ for feilsøking.
"""
import ctypes
import json
import os
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

import pypdfium2 as pdfium
import pypdfium2.raw as pdfium_c

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

# Avslagsgrunnene fra saksbehandling-api (Avslagsgrunnlag). Brukes til å generere
# datasett som dekker alle grener i lib/avslagComponents.typ — både enkeltgrunn
# (med hjemler, med/uten barnetillegg) og punktlisten med alle grunnene samlet.
AVSLAGSGRUNNER = [
    "DELTAR_IKKE_PÅ_ARBEIDSMARKEDSTILTAK",
    "ALDER",
    "LIVSOPPHOLDYTELSE",
    "KVALIFISERINGSPROGRAMMET",
    "INTRODUKSJONSPROGRAMMET",
    "LØNN_FRA_TILTAKSARRANGØR",
    "LØNN_FRA_ANDRE",
    "INSTITUSJONSOPPHOLD",
    "FREMMET_FOR_SENT",
]

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


# URL-aktig tekst i brevene (nav.no/klage, skatteetaten.no/…, osv.).
# Avsluttende tegnsetting fanges bevisst ikke opp av mønsteret.
URL_MØNSTER = re.compile(r"(?:[a-zA-Z0-9-]+\.)+(?:no|com|net|org)(?:/[A-Za-z0-9#/._~-]*[A-Za-z0-9#_~-])?")


def normaliser_url(url):
    return url.removeprefix("https://").removeprefix("http://").removeprefix("www.").rstrip("/")


def lenkeannotasjoner(pdf, side):
    """Returnerer URI-ene til alle lenkeannotasjoner på siden."""
    urier = []
    for i in range(pdfium_c.FPDFPage_GetAnnotCount(side.raw)):
        annot = pdfium_c.FPDFPage_GetAnnot(side.raw, i)
        if not annot:
            continue
        try:
            if pdfium_c.FPDFAnnot_GetSubtype(annot) != pdfium_c.FPDF_ANNOT_LINK:
                continue
            lenke = pdfium_c.FPDFAnnot_GetLink(annot)
            if not lenke:
                continue
            action = pdfium_c.FPDFLink_GetAction(lenke)
            if not action or pdfium_c.FPDFAction_GetType(action) != pdfium_c.PDFACTION_URI:
                continue
            lengde = pdfium_c.FPDFAction_GetURIPath(pdf.raw, action, None, 0)
            buffer = ctypes.create_string_buffer(lengde)
            pdfium_c.FPDFAction_GetURIPath(pdf.raw, action, buffer, lengde)
            urier.append(buffer.raw.rstrip(b"\x00").decode("utf-8", "replace"))
        finally:
            pdfium_c.FPDFPage_CloseAnnot(annot)
    return urier


def sjekk_lenker(navn, sidenr, sidetekst, urier, feil):
    """Alle URL-er i brevteksten skal være klikkbare lenker med gyldig https-URI.

    Generalisert fra to konkrete feil: lenker som ikke var wrappet i navLenke,
    og navLenke uten scheme (URI-annotasjonen «nav.no» åpner ingenting i PDF-visere).
    """
    ok = True
    for uri in urier:
        if not uri.startswith(("https://", "http://")):
            feil.append(f"{navn}: side {sidenr}: lenke-URI «{uri}» mangler https:// og åpner ikke i PDF-visere")
            ok = False
    normaliserte = {normaliser_url(uri) for uri in urier}
    for url in URL_MØNSTER.findall(sidetekst):
        if normaliser_url(url) not in normaliserte:
            feil.append(f"{navn}: side {sidenr}: «{url}» står i teksten uten å være en klikkbar lenke (bruk navLenke)")
            ok = False
    return ok


def sjekk_tekstkollisjoner(navn, sidenr, tekstside, feil, terskel=0.7, maks_rapportert=3):
    """Ingen synlige tegn skal ligge oppå hverandre (f.eks. dato rendret over annen tekst).

    Sammenligner tegnenes bounding-bokser; par som overlapper mer enn `terskel`
    av det minste tegnets areal regnes som kollisjon. Naboglyfer med kerning
    overlapper langt mindre enn dette, og nabotegn hoppes over fordi ligaturer
    (ff, ft, fi, …) rapporteres av pdfium som flere tegn med samme boks.
    """
    tp = tekstside.raw
    tegn = []
    for i in range(pdfium_c.FPDFText_CountChars(tp)):
        c = chr(pdfium_c.FPDFText_GetUnicode(tp, i))
        if c.isspace() or unicodedata.combining(c):
            continue
        v, h, b, t = (ctypes.c_double() for _ in range(4))
        pdfium_c.FPDFText_GetCharBox(tp, i, ctypes.byref(v), ctypes.byref(h), ctypes.byref(b), ctypes.byref(t))
        if h.value - v.value <= 0 or t.value - b.value <= 0:
            continue
        tegn.append((i, c, v.value, b.value, h.value, t.value))

    rutenett = {}
    kollisjoner = []
    for indeks, (i, c, v, b, h, t) in enumerate(tegn):
        celle = (int((v + h) / 2 // 8), int((b + t) / 2 // 8))
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                for j in rutenett.get((celle[0] + dx, celle[1] + dy), ()):
                    i2, c2, v2, b2, h2, t2 = tegn[j]
                    if abs(i - i2) <= 2:
                        continue  # ligatur eller kerning mellom nabotegn
                    overlapp_x = min(h, h2) - max(v, v2)
                    overlapp_y = min(t, t2) - max(b, b2)
                    if overlapp_x <= 0 or overlapp_y <= 0:
                        continue
                    minste_areal = min((h - v) * (t - b), (h2 - v2) * (t2 - b2))
                    if overlapp_x * overlapp_y > terskel * minste_areal:
                        kollisjoner.append((c2, c, (v + h) / 2, (b + t) / 2))
        rutenett.setdefault(celle, []).append(indeks)

    for c2, c, x, y in kollisjoner[:maks_rapportert]:
        feil.append(f"{navn}: side {sidenr}: tegnene «{c2}» og «{c}» overlapper ved ({x:.0f}, {y:.0f}) — tekst rendres oppå annen tekst")
    if len(kollisjoner) > maks_rapportert:
        feil.append(f"{navn}: side {sidenr}: … og {len(kollisjoner) - maks_rapportert} kollisjoner til")
    return not kollisjoner


def sjekk_pdf(navn, mal, body, feil):
    pdf = pdfium.PdfDocument(body)
    try:
        if len(pdf) == 0:
            feil.append(f"{navn}: PDF-en har ingen sider")
            return False

        ok = True
        tekst = ""
        for sidenr, side in enumerate(pdf, start=1):
            bredde, høyde = side.get_size()
            if abs(bredde - A4_PUNKTER[0]) > 1 or abs(høyde - A4_PUNKTER[1]) > 1:
                feil.append(f"{navn}: sidestørrelsen {bredde:.0f}x{høyde:.0f}pt er ikke A4")
                return False
            tekstside = side.get_textpage()
            sidetekst = tekstside.get_text_range()
            tekst += sidetekst
            ok &= sjekk_lenker(navn, sidenr, sidetekst, lenkeannotasjoner(pdf, side), feil)
            ok &= sjekk_tekstkollisjoner(navn, sidenr, tekstside, feil)
            tekstside.close()
            side.close()
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


def avslagsvarianter():
    """Genererer (navn, payload) som til sammen rendrer alle avslagsgrunn-grenene."""
    basis = json.loads((DATA_DIR / "vedtakAvslag.json").read_text())
    for grunn in AVSLAGSGRUNNER:
        for medBarn in (True, False):
            payload = dict(basis, avslagsgrunner=[grunn], avslagsgrunnerSize=1, harSøktMedBarn=medBarn, hjemlerTekst=None)
            yield f"vedtakAvslag--{grunn.lower()}{'' if medBarn else '-uten-barn'}", payload
    payload = dict(basis, avslagsgrunner=AVSLAGSGRUNNER, avslagsgrunnerSize=len(AVSLAGSGRUNNER))
    yield "vedtakAvslag--alle-grunner", payload


def test_datasett(datafil, feil):
    navn = datafil.stem
    payload = datafil.read_bytes()
    json.loads(payload)  # valider testdataene før de sendes
    test_payload(navn, payload, feil)


def test_payload(navn, payload, feil):
    mal = malnavn(navn)
    if not (TEMPLATE_DIR / f"{mal}.typ").is_file():
        feil.append(f"{navn}: fant ingen mal '{mal}.typ' (sjekk DATA_TIL_MAL i run-tests.py)")
        return

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

    antall = len(datafiler)
    for navn, payload in avslagsvarianter():
        antall += 1
        test_payload(navn, json.dumps(payload, ensure_ascii=False).encode("utf-8"), feil)

    print(f"\n{antall - len(feil)}/{antall} datasett ok")
    if feil:
        for f in feil:
            print(f"FEIL {f}")
        sys.exit(1)


if __name__ == "__main__":
    main()
