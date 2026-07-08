# tiltakspenger-pdfgen
Generering av PDF for tiltakspenger sine applikasjoner.

## Starte tiltakspenger-pdfgen lokalt
* Du kan starte pdfgen lokalt ved å kjøre `./run_development.sh` 

* Man kan også kjøre docker-compose:
```docker compose up -d --build```

    Flagget `-d` brukes for at ikke terminalen skal låses til docker.
Flagget `--build` brukes for å bygge imaget på nytt som vil si at applikasjonen som kjøres opp er lik koden du har lokalt.

* Pdfgen er også en del av scriptet `up.sh` som ligger i metarepo og starter opp ved kjøring av det.


## Utviklerverktøy: forhåndsvise brev i nettleseren
Kjør `./run_devtools.sh` og åpne http://localhost:8087. Der kan du velge brev, justere
flettedataene i et skjema (eller som rå JSON) og se PDF-en oppdatere seg fortløpende.
Starter også pdfgenrs selv om den ikke allerede kjører.

Se [devtools/brev-preview/README.md](devtools/brev-preview/README.md) for detaljer.


## Gjøre kall mot tiltakspenger-pdfgen lokalt
PDFene kan testes lokalt på `http://localhost:8085/api/v1/genpdf/<application>/<template>`, f.eks.
http://localhost:8085/api/v1/genpdf/tpts/vedtakInnvilgelse

Templatene vil bruke flettedata fra json-fil med samme navn som template i `data/tpts`


## Gjøre kall mot tiltakspenger-pdfgen lokalt (alternativ 2) 
1. Start opp postman/insomnia/bruno eller et annet program som kan gjøre rest-kall

2. Sett opp en `POST` mot endepunktet du vil ha brev fra f.eks: `http://localhost:8085/api/v1/genpdf/tpts/vedtakInnvilgelse`
3. Sett BODY til å være Json
f.eks:
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

4. Når du har gjort kall må du sette responsen til å tolkes som .PDF eller laste ned responsen som en .PDF-fil


## Styling av brev
Vi følger de visuelle retningslinjene til Aksel, som finnes her: https://aksel.nav.no/god-praksis/artikler/visuelle-retningslinjer-for-brev

## Extra
- docs og tutorial for typst
  - https://typst.app/docs
  - https://typst.app/docs/tutorial/
- Intellij har dårlig out-of-the-box IDE støtte, du kan last ned plugin "Kvasir" gratis - https://plugins.jetbrains.com/plugin/25061-kvasir. Denne gir deg syntax highlighting, live preview og linting for typst i IntelliJ.
  - known issues:
    - Dersom prosjektet åpnes i intellij fra meta-repoet, vil Kvasir klage på file-path til data/resources/styles, etc. og preview still stoppe å fungere. Dette kan løses ved å åpne prosjektet direkte i intellij, og ikke via meta-repoet.
    - Feilmeldinger fra Kvasir kan i tider være litt kryptiske. Feilen vil vises i f.eks templaten din, mens selve feilen ligger i stylingen. 
    - Ikke alle feil vises heller. Du kan teste om du har kompileringsfeil hvis previewet ikke opppdaterer når du legger inn tekst og saver.
- Ulik pdfgen, (og tidligere pdfgenrs versjoner), så må `/templates` kun inneholde de ulike templatesene våre. Partials (components), og andre hjelpe-templates/styles etc, ligger i `/lib`