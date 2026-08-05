# AGENTS.md — tiltakspenger-pdfgenrs

Dette repoet følger monorepo-konvensjonene i [`../AGENTS.md`](../AGENTS.md).
Les den først.

Repoet inneholder kun Typst-maler (`templates/`, `lib/`), testdata (`data/`) og statiske ressurser oppå det prebygde serverimaget `ghcr.io/navikt/pdfgenrs`.
Kotlin/JVM-konvensjonene i `../AGENTS-backend.md` gjelder derfor ikke her.

Lokalt kjører tjenesten på port `8084`, både via metarepoets docker-compose og dette repoets `docker-compose.yml`/`run_development.sh`.
Port 8085 er reservert for `nais login` og skal ikke bindes her.

## Skrivestil i dokumentasjon og kommentarer

**Én setning per linje.**
README, AGENTS og kommentarer i koden skal ha linjeskift etter hvert punktum, i stedet for flere setninger pakket sammen på én lang linje.
Det gir renere diffs og gjør det enklere for mennesker å redigere.
Gjelder ikke de vendorerte filene i `lib/pensjonsbrev/`.

## Delt Typst-oppsett (lib/pensjonsbrev)

Typografi, avstander, tabeller og sideoppsett kommer fra et delt Typst-oppsett som vedlikeholdes i et annet repo (navikt/pensjonsbrev, `brevbaker/pdf-bygger/containerFiles/typst`) og er kopiert **1-1** inn i `lib/pensjonsbrev/`:

- **Rediger aldri filene i `lib/pensjonsbrev/`.**
  Bygget kjører en likhetssjekk mot oppstrøms (`.github/workflows/pensjonsbrev-sync-check.yml`) som feiler ved avvik.
  Oppdatering hentes bevisst med `./sync-pensjonsbrev.sh`.
  Egne tilpasninger legges i adapterne i `lib/` (`typography.typ`, `styles.typ`, `layout.typ`, `spraak.typ`).
- **Bruk innholdet derfra fremfor å redefinere.**
  `h1`–`h4` og `brødtekst` i `lib/typography.typ` delegerer til `mainTitle`/`title1`–`title3`/`paragraph`, dagtabellene bruker `letter-table`, og footeren kommer fra `footer.typ`.
  Vertikal avstand styres av kollisjonsmatrisen i `content/spacing.typ`.
  Elementer wrappes i `withSpacing` og slutter med `below: 0pt`, så innhold som ikke er matrix-wrappet (egne `block`/`stack`) får avstand via `set block(spacing: …)` i `apply-styles`.
  Ikke bland inn egne heading-show-regler for nivå 2–4.
- **PDF-eksporten håndhever UU-krav.**
  Overskriftsnivåer kan ikke hoppes over (h1 → h3 feiler kompileringen).
  Bruk `= tittel` kun for nivå 1; underoverskrifter skrives med `h2()`/`h3()`/`h4()`.
- Tekster de delte komponentene trenger (footer- og tabelltekster) ligger i `lib/spraak.typ` med verdier hentet fra oppstrøms `LanguageSettings.kt`.
- Gjenstående diff mot det delte oppsettet er dokumentert som TODO-er i [README.md](README.md).

## Malkonvensjoner

- **Utgående vedtaksbrev** skal ha identisk hale fra og med «Du har rett til å klage»: bruk den felles `vedtaksinfo`-komponenten i `lib/components.typ` (klagerett, innsyn, personopplysninger, veiledning, spørsmål).
  Ikke lag lokale kopier av disse tekstene i maler eller komponenter.
- **Signaturen** («Med vennlig hilsen») er også felles: bruk `signatur`-komponenten i `lib/components.typ` i alle utgående brev.
  Beslutter er nullable og vises kun når den finnes; automatisk behandlede vedtak viser «Automatisk behandlet» i stedet for signatur.
- **Innsendte dokumenter** (meldekort, søknad) er ikke brev, men en tro gjengivelse av det brukeren fylte ut — ingen signatur eller klagerett.
  De bruker samme personinfo-layout som utgående brev via `personaliaInnsendt` (mottatt-tidspunkt til høyre der utgående har utsendingsdato).

## Referanser

- **Typst-dokumentasjon:** <https://typst.app/docs/> — malspråket alt i `templates/` og `lib/` er skrevet i.
- **Serveren (upstream):** <https://github.com/navikt/pdfgenrs> — endepunkter, miljøvariabler og hvordan JSON-payload flettes inn.
  Serveren leverer kun PDF og HTML, ingen bildeutgang.
- **Standard for brev i Nav:** <https://github.com/navikt/tiltakspenger-interndokumentasjon/tree/main/brevstandard> — kravene til språk, struktur, begrunnelser, signatur og standardtekster, gjengitt ordrett fra intranettet fordi originalen ikke er tilgjengelig utenfor Nav.
  `faste-standardtekster-i-brev.md` og `krav-til-signatur-i-brev.md` der er fasit for `vedtaksinfo`- og `signatur`-komponentene i `lib/components.typ`.
  Repoet er privat og krever Nav-tilgang; ligger gjengivelsene her i stedet, er de kommet feil sted.
- **Visuelle retningslinjer for brev (Aksel):** <https://aksel.nav.no/god-praksis/artikler/visuelle-retningslinjer-for-brev> — bakgrunn for brevdesignet.
  Merk at det vendorerte oppsettet i `lib/pensjonsbrev/` inneholder nyere designvalg som ennå ikke er reflektert i artikkelen; ved konflikt er `lib/pensjonsbrev/` fasit.
- **Design tokens (Aksel):** <https://aksel.nav.no/grunnleggende/styling/design-tokens> — fargene/avstandene i `lib/` refererer Aksel-tokens (f.eks. `--a-surface-subtle`); slå opp verdier her.

## Teste brevmalene

Kjør `./run_tests.sh` etter malendringer — alt kjører i Docker og krever ingen verktøy på maskinen.
Testene rendrer alle datasett i `data/tpts/`, kanttilfellevariantene i `test/data/` og genererte avslagsvarianter (alle avslagsgrunn-grener), og asserterer HTTP 200, gyldig PDF, A4, felles hale og signatur i utgående brev (se `INNHOLDSKRAV` i `test/run-tests.py`).
De sjekker også at alle URL-er i brevtekst er klikkbare `navLenke`-lenker med `https://`-URI, og at ingen tegn rendres oppå hverandre (layoutkollisjoner).
Nye brev og nye kanttilfeller skal ha testdata: standarddatasett i `data/tpts/<mal>.json`, varianter i `test/data/<mal>--<variant>.json`.
Testdataene bruker en fast, virkelighetsnær testfamilie — ingen tulleord/tullenavn, og syntetiske identer (+40 på måned) så ingen privatpersoner kan treffes.
Kanoniske verdier: bruker Emil Aremark (fnr `25508631114`), barn Nora/Jakob/Oskar Johan Aremark, saksbehandler Ingrid Bakke, beslutter Martin Holm, saksnummer `202501011001`, tiltaksarrangør Aremark Snekkerverksted AS.
Datasettene i `data/tpts/` er også defaultene i brev-preview (både lokalt og i demoen i dev), så de skal vise et **helt, normalt brev**: ingen forhåndsvisningsvannmerke, ingen plassholdertekst og datoer som henger sammen.
Kanttilfellene — forhåndsvisning, manglende saksbehandler, automatisk behandling — hører hjemme som varianter i `test/data/`.
Tekstene i `valgtHjemmelTekst` (stans/opphør) skal speile fasit-testene i `tiltakspenger-saksbehandling-api` (`BrevRevurderingStansDTOTest`/`BrevOmgjøringOpphørDTOTest`) — endres brevtekstene der, oppdater testdataene her.
Endrer du felleskomponentene (signatur, vedtaksinfo), oppdater innholdskravene i samme endring.
Testene er deploy-gate i CI (`.github/workflows/.test.yml`).

## Verifisere brev visuelt (for agenter)

1. **Start motoren** med `./run_development.sh` eller `docker compose up -d --build` (pdfgenrs på `8084`).
   Kjør alltid med `--build` etter malendringer hvis containeren ikke volum-monterer repoet, ellers tester du en gammel mal.
2. **Render payloaden:**

   ```bash
   curl -s -X POST http://localhost:8084/api/v1/genpdf/tpts/<mal> \
     -H "Content-Type: application/json" --data @data/tpts/<mal>.json -o /tmp/<mal>.pdf
   ```

3. **Lag payload-varianter for kanttilfellene** (kopier `data/tpts/<mal>.json` og endre med python3/jq): null-felter (f.eks. `beslutterNavn`, `brevTekst`, `iverksattTidspunkt`), tomme lister, `forhandsvisning` true/false, og malspesifikke grener (korrigering, med/uten barnetillegg, …).
4. **Se på PDF-ene direkte med Read-verktøyet.**
   PDF-er rendres visuelt for agenten — les dem og vurder innhold, rekkefølge, tabellstruktur og markeringer.
   Ingen konvertering til bilder er nødvendig for hele dokumenter; `pages`-parameteren (sideutvalg) krever derimot poppler (`brew install poppler`).
   `sips`/`qlmanage` på macOS tar kun første side og er ikke egnet.
5. **Sammenlign mot en annen versjon av repoet** når en endring skal vurderes: `./run_devtools.sh` og huk av «Sammenlign versjoner» viser samme brev fra to git-refs side om side.

Merk: pdfgenrs-serveren kan kun levere **PDF og HTML** (`/api/v1/genpdf/...`, `/api/v1/genhtml/...`).
Det finnes ingen PNG/SVG-utgang for maler (`/api/v1/genpdf/image/{app}` gjør det motsatte: bilde → PDF).

For mennesker: `./run_devtools.sh` gir forhåndsvisning i nettleseren på http://localhost:8087, og demoen i dev (se README) gir det samme uten repo og Docker lokalt.
