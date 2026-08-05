# brev-preview

Utviklerverktøy for å forhåndsvise brevene i nettleseren: velg brev, juster flettedataene i et skjema (eller som rå JSON), og se PDF-en oppdatere seg fortløpende mens du redigerer.

## Kjøre

Fra repo-rota:

```bash
./run_devtools.sh
```

Åpne deretter http://localhost:8087.

Scriptet trenger bare Python 3 (kun stdlib, ingen avhengigheter).
Det finner en kjørende pdfgenrs på port 8084, og starter den selv med `docker compose up -d --build` om den ikke svarer.

Om containeren på 8084 ikke volum-monterer dette repoet (typisk metarepoets compose, som baker malene inn i imaget ved build og dermed viser en gammel versjon), oppdages det ved oppstart og devtoolsen starter i stedet en egen container for arbeidskatalogen.

## Dele en lenke til et bestemt brev

«Kopier lenke» i headeren gir en URL som åpner samme brev med samme innhold hos den som får den.
Adressefeltet holdes i takt med det du ser, så lenken kan også bare kopieres derfra.

Alt ligger i fragmentet (`#brev=…&data=…`), som aldri sendes til serveren — flettedataene inneholder syntetiske fødselsnumre og har ingenting i en accesslogg å gjøre.
Har du ikke endret noe, bærer lenken bare brevnavnet (`#brev=vedtakAvslag`) og viser datasettet fra `data/tpts`.
Har du endret noe, pakkes hele payloaden med, gzippet og base64url-kodet.
Lenken er altså selvbærende, ikke en diff mot `data/tpts`: en gammel lenke viser det samme brevet selv om testdatasettet endres senere.

Målt på datasettene i repoet blir lenkene 600–1200 tegn, og `utbetalingsvedtak` er den lengste med 1537.
Det er godt innenfor det Slack og e-post takler.

Er lenken avkortet på veien, sier siden fra og viser datasettet i stedet for å stå igjen tom — brevvalget i lenken beholdes.
Lenken virker likt lokalt og i demoen i dev; bare vertsnavnet skiller.

## Nedtrekkslister for felt som er enum

Felt som egentlig er enum vises som nedtrekksliste i skjemaet, med en lesbar etikett i listen og selve verdien som tittel på feltet.
De står i [`enums.js`](enums.js), med sti inn i flettedataene per datasett i `data/tpts`:

| Datasett                | Felt                                    | Kilde                                                     |
|-------------------------|-----------------------------------------|-----------------------------------------------------------|
| `meldekort*`            | `dager[].status`                        | `meldekortLabelsNo`/`-En` i `lib/meldekortComponents.typ`  |
| `vedtakAvslag`          | `avslagsgrunner[]`                      | grenene i `lib/avslagComponents.typ`                       |
| `meldekortvedtak`       | `…dager[].status.forrige`/`.gjeldende`  | `toStatus()` i `BrevMeldekortvedtakDTO.kt`                 |
| `utbetalingsvedtak`     | `saksbehandler.type`/`beslutter.type`   | `templates/tpts/utbetalingsvedtak.typ`                     |

Listene er kopier av kilden, på samme måte som `AVSLAGSGRUNNER` i `test/run-tests.py` — verdiene kan ikke leses ut av malene i drift, siden demo-imaget bare inneholder `devtools/brev-preview` og `data/tpts`.
Endres kilden, må listen oppdateres.
En verdi som ikke står i listen (typisk skrevet inn i JSON-modus) blir stående, merket «ukjent verdi».

Resten av feltene er fritekst, tall eller checkbox som før.
Statusene i `utbetalingsvedtak` har et eget sett ord som ingen kilde i flåten lenger produserer (malen er avløst av `meldekortvedtak`), og er derfor ikke satt opp som enum.

## Felt som regnes ut fra andre felt

Noen felt i flettedataene er ikke noe saksbehandler fyller ut — backend regner dem ut fra andre felt i samme payload.
De er skrivebeskyttet i skjemaet (stiplet ramme) og oppdateres med det samme grunnlaget endres, så forhåndsvisningen ikke kan komme i utakt med seg selv.
Reglene står i [`avledet.js`](avledet.js):

| Datasett          | Felt                              | Regel                                                             |
|-------------------|-----------------------------------|-------------------------------------------------------------------|
| `vedtakAvslag`    | `avslagsgrunnerSize`              | antall `avslagsgrunner` (`BrevSøknadAvslagDTO.kt`)                 |
| `meldekortvedtak` | `meldeperioder[].harBarnetillegg` | en dag har barnetillegg > 0 (`BrevMeldekortvedtakDTO.kt`)          |

Bare felt der backend-regelen kan gjentas nøyaktig fra det payloaden inneholder står her.
Beløpsfeltene i `meldekortvedtak` ser avledede ut, men er det ikke: `meldeperioder[].beløp` summerer dagene i *beregningen*, mens `dager` i payloaden kommer fra sammenligningen, og `totaltBelop` hentes fra behandlingen.
Å summere dagene i skjemaet ville vært en gjetning, ikke samme regel som backend.

Regelen gjelder bare skjemaet — JSON-modus er rå, og der kan du sette hva du vil.

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

## Demo i dev

Samme side kjører som egen nais-app i dev, slik at brevene kan vises og redigeres uten repo og Docker lokalt: <https://tiltakspenger-pdfgenrs-demo.intern.dev.nav.no>.
Se [«Demo i dev»](../../README.md#demo-i-dev) i repoets README for oppsett og deploy.

Versjonssammenligningen er av der, siden den trenger `docker` og `git` i containeren.
Siden oppdager det selv: `compare.js` skjuler hele funksjonen når `/api/refs` ikke svarer, og `serve.py` registrerer ikke de rutene når `NAIS_APP_NAME` er satt.

## Miljøvariabler

| Variabel        | Default                 | Beskrivelse                   |
|-----------------|-------------------------|-------------------------------|
| `DEVTOOLS_PORT` | `8087`                  | Port for devtools-siden       |
| `PDFGEN_URL`    | `http://localhost:8084` | Adresse til pdfgenrs-serveren |

## Hvordan det henger sammen

Backend (kun Python-stdlib):

- `serve.py` server statiske filer fra repo-rota (siden trenger `data/tpts/*.json` som utgangspunkt for skjemaet) og proxyer `POST /api/genpdf/...` videre til pdfgenrs sin `/api/v1/genpdf/...`.
  Proxyen trengs fordi pdfgenrs ikke sender CORS-headere, så siden kan ikke kalle serveren direkte fra en annen origin.
- `versions.py` eier versjonssammenligningen: `GET /api/refs` (forslagsliste), `POST /api/ref/prepare` (worktree + container for en ref) og oppryddingen ved avslutning.
- `common.py` er det lille som deles: repo-rota og liveness-sjekken.

Frontend (ren HTML/JS/CSS uten avhengigheter):

- `app.js` er kjernen: flettedata-state, mal-valg og hovedpanelet. Ekstra paneler kobler seg på via `window.brevPreview` (`onGenerate`-hooken får mal + flettedata ved hver generering).
- `form.js` genererer skjemaet rekursivt fra JSON-strukturen: boolske felt blir checkboxer, tall og tekst blir inputs, enum-felt blir nedtrekkslister, og arrays får «Legg til»/«Fjern»-knapper.
  Objekter og lister er sammenleggbare, og lister med mer enn tre ledd starter sammenlagt med første tekstverdi som overskrift — ellers drukner de lange brevene i dager og perioder.
- `enums.js` er listen over felt som er enum, med sti inn i flettedataene per datasett (se over).
- `avledet.js` er reglene for felt som regnes ut fra andre felt, med samme stisyntaks.
- `lenke.js` pakker brev og flettedata inn i og ut av fragmentet i URL-en (se over).
- `panel.js` er gjenbrukbar lasting av PDF inn i en iframe (objectURL-opprydding, utdaterte svar ignoreres) — brukes av begge panelene.
- `compare.js` er versjonssammenligningen (ref-feltene og høyrepanelet).

Brevlisten kommer fra filnavnene i `data/tpts/` — nye brev dukker opp automatisk.
