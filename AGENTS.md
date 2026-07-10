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
- **Visuelle retningslinjer for brev (Aksel):** <https://aksel.nav.no/god-praksis/artikler/visuelle-retningslinjer-for-brev> — bakgrunn for brevdesignet.
  Merk at det vendorerte oppsettet i `lib/pensjonsbrev/` inneholder nyere designvalg som ennå ikke er reflektert i artikkelen; ved konflikt er `lib/pensjonsbrev/` fasit.
- **Design tokens (Aksel):** <https://aksel.nav.no/grunnleggende/styling/design-tokens> — fargene/avstandene i `lib/` refererer Aksel-tokens (f.eks. `--a-surface-subtle`); slå opp verdier her.
- **Migreringsissue:** <https://github.com/navikt/tiltakspenger-pdfgenrs/issues/8> — status, sjekkliste og fremgangsmåte for 1-til-1-migreringen fra gammel pdfgen.
- **Gammel pdfgen (fasit under migreringen):** [`../tiltakspenger-pdfgen`](../tiltakspenger-pdfgen) — `.hbs`-malene der er fasit for innhold og struktur til de er verifisert og repoet slettes.

## Teste brevmalene

Kjør `./run_tests.sh` etter malendringer — alt kjører i Docker og krever ingen verktøy på maskinen.
Testene rendrer alle datasett i `data/tpts/` og kanttilfellevariantene i `test/data/`, og asserterer HTTP 200, gyldig PDF, A4, felles hale og signatur i utgående brev (se `INNHOLDSKRAV` i `test/run-tests.py`).
Nye brev og nye kanttilfeller skal ha testdata: standarddatasett i `data/tpts/<mal>.json`, varianter i `test/data/<mal>--<variant>.json`.
Testdataene bruker en fast, virkelighetsnær testfamilie — ingen tulleord/tullenavn, og syntetiske identer (+40 på måned) så ingen privatpersoner kan treffes.
Kanoniske verdier (gjelder også `tiltakspenger-pdfgen/data/tpts/`): bruker Emil Aremark (fnr `25508631114`), barn Nora/Jakob/Oskar Johan Aremark, saksbehandler Ingrid Bakke, beslutter Martin Holm, saksnummer `202501011001`, tiltaksarrangør Aremark Snekkerverksted AS.
Tekstene i `valgtHjemmelTekst` (stans/opphør) skal speile fasit-testene i `tiltakspenger-saksbehandling-api` (`BrevRevurderingStansDTOTest`/`BrevOmgjøringOpphørDTOTest`) — endres brevtekstene der, oppdater testdataene her.
Endrer du felleskomponentene (signatur, vedtaksinfo), oppdater innholdskravene i samme endring.
Testene er deploy-gate i CI (`.github/workflows/.test.yml`).

## Verifisere brev visuelt mot gammel pdfgen (for agenter)

Slik sammenlignes en mal 1-til-1 mot gammel pdfgen (brukt ved migreringsverifisering av `meldekortvedtak`):

1. **Start begge motorene** fra metarepoet: `docker compose up -d --build pdfgen-service pdfgenrs-service` (pdfgen på `8081`, pdfgenrs på `8084`).
   Imagene bygges fra lokal kildekode — kjør alltid med `--build` etter malendringer, ellers tester du en gammel mal.
2. **Render samme payload mot begge motorene** (endepunktene er like, kun porten skiller):

   ```bash
   curl -s -X POST http://localhost:8081/api/v1/genpdf/tpts/<mal> \
     -H "Content-Type: application/json" --data @data/tpts/<mal>.json -o /tmp/<mal>-pdfgen.pdf
   curl -s -X POST http://localhost:8084/api/v1/genpdf/tpts/<mal> \
     -H "Content-Type: application/json" --data @data/tpts/<mal>.json -o /tmp/<mal>-pdfgenrs.pdf
   ```

3. **Lag payload-varianter for kanttilfellene** (kopier `data/tpts/<mal>.json` og endre med python3/jq): null-felter (f.eks. `beslutterNavn`, `brevTekst`, `iverksattTidspunkt`), tomme lister, `forhandsvisning` true/false, og malspesifikke grener (korrigering, med/uten barnetillegg, …).
   Render hver variant mot begge motorene.
4. **Se på PDF-ene direkte med Read-verktøyet.**
   PDF-er rendres visuelt for agenten — les pdfgen- og pdfgenrs-varianten etter hverandre og sammenlign innhold, rekkefølge, tabellstruktur og markeringer.
   Ingen konvertering til bilder er nødvendig for hele dokumenter; `pages`-parameteren (sideutvalg) krever derimot poppler (`brew install poppler`).
   `sips`/`qlmanage` på macOS tar kun første side og er ikke egnet.
5. **Kjente aksepterte avvik** (repo-brede konvensjoner, ikke feil): typografisk minus (−338 vs -338), bunntekst med saksnummer + «side X av Y» (gammel pdfgen mangler denne på enkelte maler), samt at typografi, avstander, tabeller (sebrastriper, «Tabellen fortsetter på neste side») og faste elementer følger det delte oppsettet i `lib/pensjonsbrev/` mens gammel pdfgen har sine egne størrelser og stiler.
   I dagtabellene markeres endrede dager med blyantikon og fet korrigert verdi — ikke med egen bakgrunnsfarge som i gammel pdfgen (kolliderer med sebrastripene).
   Sammenlign altså **innhold og struktur** mot gammel pdfgen, ikke fontstørrelser, farger og sideskift.

Merk: pdfgenrs-serveren kan kun levere **PDF og HTML** (`/api/v1/genpdf/...`, `/api/v1/genhtml/...`).
Det finnes ingen PNG/SVG-utgang for maler (`/api/v1/genpdf/image/{app}` gjør det motsatte: bilde → PDF).

For mennesker: `./run_devtools.sh` gir side-om-side-forhåndsvisning i nettleseren på http://localhost:8087.
