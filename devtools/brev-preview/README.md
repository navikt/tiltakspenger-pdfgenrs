# brev-preview

Utviklerverktøy for å forhåndsvise brevene i nettleseren: velg brev, juster
flettedataene i et skjema (eller som rå JSON), og se PDF-en oppdatere seg
fortløpende mens du redigerer.

## Kjøre

Fra repo-rota:

```
./run_devtools.sh
```

Åpne deretter http://localhost:8087.

Scriptet trenger bare Python 3 (kun stdlib, ingen avhengigheter).
Det finner en kjørende pdfgenrs på port 8084, og starter den selv med `docker compose up -d --build` om den ikke svarer.

## Overgangsfase: gammel pdfgen side om side

Så lenge `../tiltakspenger-pdfgen` finnes (utsjekket meta-repo), vises PDF-en fra
gammel pdfgen ved siden av den nye, generert fra de samme flettedataene, slik at
det er lett å sammenlikne brevene. Scriptet finner en kjørende pdfgen på port 8081, og prøver å starte den med `docker compose up -d --build` i pdfgen-repoet om den ikke svarer (tilsvarer `../tiltakspenger-pdfgen/run_development.sh`, bare detached).

Brev som ikke finnes i gammel pdfgen merkes med «finnes ikke i pdfgen».
Brev som ennå ikke er migrert til pdfgenrs vises i mallisten som «(kun i pdfgen)» — flettedataene hentes da fra pdfgen-repoet og kun det gamle panelet rendres.

### Slette legacy-støtten når pdfgen fjernes

Alt er merket med `LEGACY PDFGEN`:

```
grep -rn "LEGACY PDFGEN" devtools/brev-preview
```

1. Slett `legacy.js`
2. Fjern de merkede blokkene i `serve.py`, `index.html`, `app.js` og `style.css`
3. Fjern denne seksjonen fra denne README-en

## Miljøvariabler

| Variabel            | Default                 | Beskrivelse                                        |
|---------------------|-------------------------|----------------------------------------------------|
| `DEVTOOLS_PORT`     | `8087`                  | Port for devtools-siden                            |
| `PDFGEN_URL`        | `http://localhost:8084` | Adresse til pdfgenrs-serveren                      |
| `LEGACY_PDFGEN_URL` | `http://localhost:8081` | Adresse til gammel pdfgen (LEGACY PDFGEN, se over) |

## Hvordan det henger sammen

- `serve.py` server statiske filer fra repo-rota (siden trenger `data/tpts/*.json`
  som utgangspunkt for skjemaet) og proxyer `POST /api/genpdf/...` videre til
  pdfgenrs sin `/api/v1/genpdf/...`. Proxyen trengs fordi pdfgenrs ikke sender
  CORS-headere, så siden kan ikke kalle serveren direkte fra en annen origin.
- `index.html`/`app.js`/`style.css` er ren HTML/JS/CSS uten avhengigheter.
  Skjemaet genereres rekursivt fra JSON-strukturen: boolske felt blir checkboxer,
  tall og tekst blir inputs, og arrays får «Legg til»/«Fjern»-knapper.
- Brevlisten kommer fra filnavnene i `data/tpts/` — nye brev dukker opp automatisk.
