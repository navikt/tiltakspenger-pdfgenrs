# brev-preview

Utviklerverktøy for å forhåndsvise brevene i nettleseren: velg brev, juster flettedataene i et skjema (eller som rå JSON), og se PDF-en oppdatere seg fortløpende mens du redigerer.

## Kjøre

Fra repo-rota:

```
./run_devtools.sh
```

Åpne deretter http://localhost:8087.

Scriptet trenger bare Python 3 (kun stdlib, ingen avhengigheter).
Det finner en kjørende pdfgenrs på port 8084, og starter den selv med `docker compose up -d --build` om den ikke svarer.

Om containeren på 8084 ikke volum-monterer dette repoet (typisk metarepoets compose, som baker malene inn i imaget ved build og dermed viser en gammel versjon), oppdages det ved oppstart og devtoolsen starter i stedet en egen container for arbeidskatalogen.

## Sammenlikne versjoner (pdfgenrs mot pdfgenrs)

Huk av «Sammenlign versjoner» i headeren for å se det samme brevet, med de samme flettedataene, fra to versjoner av repoet side om side:

- Venstre panel er default **arbeidskatalogen** — det du har utsjekket akkurat nå, inkludert uncommittede endringer.
- Høyre panel er default **main**. Nedtrekkslistene viser arbeidskatalogen, grenene og de siste commitene; velg «Egen ref …» for å skrive inn hva som helst `git rev-parse` forstår (tøm feltet for å komme tilbake til listen).

Begge feltene kan settes fritt, så det går også an å sammenlikne to commits med hverandre.

Bak kulissene lager `versions.py` et git-worktree per ref under `~/.cache/tiltakspenger-pdfgenrs-devtools/` og starter en egen pdfgenrs-container per ref — pdfgenrs er bare upstream-imaget med maler/fonter montert som volumer, så ingenting må bygges. Refs resolves på nytt ved hver generering, så committer du til grenen du sammenlikner mot, plukkes den nye commiten opp automatisk. Containere og worktrees ryddes når devtoolsen avsluttes.

Containerne er lette å kjenne igjen i `docker ps`:

- De heter `pdfgenrs-devtools-<sha>` (eller `pdfgenrs-devtools-arbeidskatalog`).
- De holder seg på portene **8092–8099** (8091 er wiremock i metarepoet), kun på 127.0.0.1.
- De har labels som viser opphavet: `devtools.opphav`, `devtools.viser` (ref-en) og `devtools.kilde` (katalogen som er montert). Se dem med `docker inspect`, eller list alle med `docker ps --filter name=pdfgenrs-devtools`.

Skulle en økt ha krasjet uten opprydding, er det trygt å fjerne alt med `docker rm -f $(docker ps -aq --filter name=pdfgenrs-devtools)` — de gjenskapes ved behov.

## Overgangsfase: gammel pdfgen side om side

Så lenge `../tiltakspenger-pdfgen` finnes (utsjekket meta-repo), vises PDF-en fra gammel pdfgen ved siden av den nye, generert fra de samme flettedataene, slik at det er lett å sammenlikne brevene.
Scriptet finner en kjørende pdfgen på port 8081, og prøver å starte den med `docker compose up -d --build` i pdfgen-repoet om den ikke svarer (tilsvarer `../tiltakspenger-pdfgen/run_development.sh`, bare detached).
(Panelet viker når «Sammenlign versjoner» er på.)

Brev som ikke finnes i gammel pdfgen merkes med «finnes ikke i pdfgen».
Brev som ennå ikke er migrert til pdfgenrs vises i mallisten som «(kun i pdfgen)» — flettedataene hentes da fra pdfgen-repoet og kun det gamle panelet rendres.

### Slette legacy-støtten når pdfgen fjernes

Alt er merket med `LEGACY PDFGEN`:

```
grep -rn "LEGACY PDFGEN" devtools/brev-preview
```

1. Slett `legacy.js`
2. Fjern de merkede blokkene i `serve.py`, `index.html`, `app.js` og `compare.js`
3. Fjern denne seksjonen fra denne README-en

## Miljøvariabler

| Variabel            | Default                 | Beskrivelse                                        |
|---------------------|-------------------------|----------------------------------------------------|
| `DEVTOOLS_PORT`     | `8087`                  | Port for devtools-siden                            |
| `PDFGEN_URL`        | `http://localhost:8084` | Adresse til pdfgenrs-serveren                      |
| `LEGACY_PDFGEN_URL` | `http://localhost:8081` | Adresse til gammel pdfgen (LEGACY PDFGEN, se over) |

## Hvordan det henger sammen

Backend (kun Python-stdlib):

- `serve.py` server statiske filer fra repo-rota (siden trenger `data/tpts/*.json` som utgangspunkt for skjemaet) og proxyer `POST /api/genpdf/...` videre til pdfgenrs sin `/api/v1/genpdf/...`.
  Proxyen trengs fordi pdfgenrs ikke sender CORS-headere, så siden kan ikke kalle serveren direkte fra en annen origin.
- `versions.py` eier versjonssammenligningen: `GET /api/refs` (forslagsliste), `POST /api/ref/prepare` (worktree + container for en ref) og oppryddingen ved avslutning.
- `common.py` er det lille som deles: repo-rota og liveness-sjekken.

Frontend (ren HTML/JS/CSS uten avhengigheter):

- `app.js` er kjernen: flettedata-state, mal-valg og hovedpanelet. Ekstra paneler kobler seg på via `window.brevPreview` (`onGenerate`-hooken får mal + flettedata ved hver generering).
- `form.js` genererer skjemaet rekursivt fra JSON-strukturen: boolske felt blir checkboxer, tall og tekst blir inputs, og arrays får «Legg til»/«Fjern»-knapper.
- `panel.js` er gjenbrukbar lasting av PDF inn i en iframe (objectURL-opprydding, utdaterte svar ignoreres) — brukes av alle tre panelene.
- `compare.js` er versjonssammenligningen (ref-feltene og høyrepanelet).
- `legacy.js` er panelet for gammel pdfgen (LEGACY PDFGEN, se over).

Brevlisten kommer fra filnavnene i `data/tpts/` — nye brev dukker opp automatisk.
