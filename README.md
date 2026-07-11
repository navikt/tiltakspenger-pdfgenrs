# tiltakspenger-pdfgenrs

Generering av PDF for tiltakspenger sine applikasjoner.

## Starte tiltakspenger-pdfgenrs lokalt

* Du kan starte pdfgenrs lokalt ved å kjøre `./run_development.sh`
* Man kan også kjøre docker-compose:

```docker compose up -d --build```

Flagget `-d` brukes for at ikke terminalen skal låses til docker.
Flagget `--build` brukes for å bygge imaget på nytt, som vil si at applikasjonen som kjøres opp er lik koden du har lokalt.

* Pdfgenrs er også en del av scriptet `up.sh` som ligger i metarepo og starter opp ved kjøring av det.

## Teste brevmalene

Kjør `./run_tests.sh`.
Alt kjører i Docker (en pdfgenrs-container og en testrunner-container), så det trengs ingen verktøy på maskinen utover Docker.
Testene rendrer alle datasettene i `data/tpts/`, kanttilfellevariantene i `test/data/` og genererte avslagsvarianter (hver avslagsgrunn alene med/uten barnetillegg + alle i punktliste, se `AVSLAGSGRUNNER` i `test/run-tests.py`), og sjekker at:

* alle maler kompilerer og svarer 200 med en gyldig PDF
* alle sider er A4 og dokumentet har minst én side
* utgående vedtaksbrev inneholder den felles halen og signaturen (fasit-tekster som «Du har rett til å klage» og «Nav Tiltak Oslo»)
* varianter oppfører seg riktig (placeholder ved manglende saksbehandler, ingen signatur ved automatisk behandling, osv.)
* alle URL-er i brevteksten er klikkbare lenker (`navLenke`) med gyldig `https://`-URI i PDF-annotasjonen
* ingen tegn rendres oppå hverandre (fanger layoutkollisjoner, f.eks. dato plassert over annen tekst)

Innholdskravene ligger i [test/run-tests.py](test/run-tests.py).
Varianter i `test/data/` følger navnekonvensjonen `<mal>--<variant>.json` og rendres mot malen før `--`.
Ved feil legges responsene i `build/test/` for feilsøking.
Testene kjøres også i CI (`.github/workflows/.test.yml`) og stopper deploy hvis de feiler.

## Utviklerverktøy: forhåndsvise brev i nettleseren

Kjør `./run_devtools.sh` og åpne http://localhost:8087.
Der kan du velge brev, justere flettedataene i et skjema (eller som rå JSON) og se PDF-en oppdatere seg fortløpende.
Starter også pdfgenrs selv om den ikke allerede kjører.

Se [devtools/brev-preview/README.md](devtools/brev-preview/README.md) for detaljer.

## Gjøre kall mot tiltakspenger-pdfgenrs lokalt

PDFene kan testes lokalt på `http://localhost:8084/api/v1/genpdf/<application>/<template>`, f.eks. http://localhost:8084/api/v1/genpdf/tpts/vedtakInnvilgelse.
Templatene vil bruke flettedata fra json-fil med samme navn som template i `data/tpts`.

## Gjøre kall mot tiltakspenger-pdfgenrs lokalt (alternativ 2)

1. Start opp postman/insomnia/bruno eller et annet program som kan gjøre rest-kall.
2. Sett opp en `POST` mot endepunktet du vil ha brev fra, f.eks. `http://localhost:8084/api/v1/genpdf/tpts/vedtakInnvilgelse`.
3. Sett BODY til å være Json, f.eks.:

```
{
  "personalia": {
    "ident": "50485211165",
    "fornavn": "Ola",
    "etternavn": "Nordmann"
  },
  "saksnummer": "202501301001",
  "saksbehandlerNavn": "Saksbehandler Navn",
  "beslutterNavn": "Saksbehandler Navn",
  "kontor": "Nav Tiltak Oslo",
  "harBarnetillegg": true,
  "satser": [
    {
      "år": 2024,
      "ordinær": 285,
      "barnetillegg": 53
    },
    {
      "år": 2025,
      "ordinær": 298,
      "barnetillegg": 55
    }
  ],
  "tilleggstekst": "Dette er en vurdering",
  "forhandsvisning": true,
  "datoForUtsending": "31. januar 2025",
    "innvilgelsesperioder": {
    "antallDagerTekst": "fem dager",
    "perioder": [
      {
        "fraOgMed": "1. november 2024",
        "tilOgMed": "28. februar 2025"
      }
    ]
  },
  "barnetillegg": [
    {
      "antallBarnTekst": "ett",
      "periode": {
        "fraOgMed": "1. november 2024",
        "tilOgMed": "28. februar 2025"
      }
    }
  ]
}
```

4. Når du har gjort kall må du sette responsen til å tolkes som .PDF eller laste ned responsen som en .PDF-fil.

## Styling av brev

Typografi, avstander, tabeller og sideoppsett kommer fra et delt Typst-oppsett som vedlikeholdes i [navikt/pensjonsbrev](https://github.com/navikt/pensjonsbrev) (`brevbaker/pdf-bygger/containerFiles/typst`) og er kopiert 1-1 inn i [`lib/pensjonsbrev/`](lib/pensjonsbrev/):

- **Filene i `lib/pensjonsbrev/` skal aldri endres lokalt.**
  Endringer gjøres oppstrøms og hentes inn med `./sync-pensjonsbrev.sh`.
  Egne tilpasninger legges i adaptere i `lib/` (se `typography.typ`, `styles.typ`, `layout.typ`).
- Bygget kjører en likhetssjekk mot oppstrøms ([`.github/workflows/pensjonsbrev-sync-check.yml`](.github/workflows/pensjonsbrev-sync-check.yml)), som også kjøres ukentlig for å fange opp oppstrøms endringer.
  Ved avvik: kjør `./sync-pensjonsbrev.sh` og verifiser brevene på nytt.
- Oppsettet bygger videre på Aksels visuelle retningslinjer for brev (https://aksel.nav.no/god-praksis/artikler/visuelle-retningslinjer-for-brev), men inneholder nyere designvalg som ennå ikke er reflektert der.
- Se også som sier mye om innhold og språk: https://navno.sharepoint.com/sites/fag-og-ytelser-Standarder-i-ytelsesforvaltningen/SitePages/Standard-for-brev-i-NAV.aspx

### TODO: gjenstående diff mot det delte oppsettet

Målet er å gjenbruke mest mulig og ha minst mulig eget.
Punktene under er funksjonelle endringer som må avklares med fagsiden, UX og juristene før de tas:

- [ ] **Felles personinfo-blokk (`casedetails`)**: krever at payloadene fra appene får feltene den forventer (navn, dokumentdato m.m. — meldekortvedtak mangler i dag begge).
      DTO-endringer i backendene, deretter kan `personalia`-adapterne fjernes.
- [ ] **Signatur/avslutning (`closing.typ`)**: bytte vår `signatur`-komponent til den delte avslutningen (annen struktur og tekst, og uten våre røde placeholder-markeringer).
- [ ] **Lister**: bruke `bulletlist`/`numberedlist` fra det delte oppsettet i malene i stedet for rå `list()`, slik at listeavstand følger kollisjonsmatrisen.
- [ ] **Logo**: bytte `resources/img.png` til den vendorerte `lib/pensjonsbrev/NAV_logo.svg`.
- [ ] **Forhåndsvisningsmarkering**: den røde «Forhåndsvisning»-headeren er vår egen — oppstrøms forhåndsviser i nettleseren og har ingen tilsvarende i PDF.
      Harmoniser hvis det delte oppsettet får støtte for merking.
- [ ] **`template()`**: når punktene over er løst kan malene trolig bruke det delte side- og førstesideoppsettet direkte i stedet for adapterne i `lib/`.

## Extra

- docs og tutorial for typst
  - https://typst.app/docs
  - https://typst.app/docs/tutorial/
- Intellij har dårlig out-of-the-box IDE-støtte, du kan laste ned plugin "Kvasir" gratis - https://plugins.jetbrains.com/plugin/25061-kvasir.
  Denne gir deg syntax highlighting, live preview og linting for typst i IntelliJ.
  - known issues:
    - Dersom prosjektet åpnes i intellij fra meta-repoet, vil Kvasir klage på file-path til data/resources/styles, etc. og preview slutte å fungere.
      Dette kan løses ved å åpne prosjektet direkte i intellij, og ikke via meta-repoet.
    - Feilmeldinger fra Kvasir kan i tider være litt kryptiske.
      Feilen vil vises i f.eks. templaten din, mens selve feilen ligger i stylingen.
    - Ikke alle feil vises heller.
      Du kan teste om du har kompileringsfeil hvis previewet ikke oppdaterer når du legger inn tekst og saver.
- Ulik pdfgen, (og tidligere pdfgenrs-versjoner), så må `/templates` kun inneholde de ulike templatesene våre.
  Partials (components), og andre hjelpe-templates/styles etc., ligger i `/lib`.
