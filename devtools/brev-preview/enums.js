// Feltene i flettedataene som egentlig er enum, slik at skjemaet kan vise en
// nedtrekksliste i stedet for et fritekstfelt.
//
// Listene er kopier av kilden, og kilden står i kommentaren over hver liste.
// Endres den, må listen her oppdateres — samme håndarbeid som AVSLAGSGRUNNER i
// test/run-tests.py. Verdiene kan ikke leses ut av malene i drift, siden
// demo-imaget bare inneholder devtools/brev-preview og testdata/tpts.
//
// Et alternativ er enten "VERDI" (verdien vises som den er) eller
// ["VERDI", "Etikett"]. Etiketten er kun en hjelp i skjemaet; det er verdien
// som sendes til pdfgenrs.

// lib/meldekortComponents.typ (meldekortLabelsNo), med samme verdier som
// enum-klassen MeldekortDagStatus i tiltakspenger-meldekort-api.
const MELDEKORT_STATUS_NB = [
  ["DELTATT_UTEN_LØNN_I_TILTAKET", "Har deltatt"],
  ["DELTATT_MED_LØNN_I_TILTAKET", "Mottok lønn"],
  ["FRAVÆR_SYK", "Syk"],
  ["FRAVÆR_SYKT_BARN", "Sykt barn eller syk barnepasser"],
  ["FRAVÆR_STERKE_VELFERDSGRUNNER_ELLER_JOBBINTERVJU", "Sterke velferdsgrunner eller jobbintervju"],
  ["FRAVÆR_GODKJENT_AV_NAV", "Fravær godkjent av Nav"],
  ["FRAVÆR_ANNET", "Annet fravær"],
  ["IKKE_TILTAKSDAG", "Ikke tiltaksdag"],
  ["IKKE_RETT_TIL_TILTAKSPENGER", "Ikke rett til tiltakspenger"],
  ["IKKE_BESVART", "Ikke besvart"],
];

// lib/meldekortComponents.typ (meldekortLabelsEn) — samme verdier, engelske etiketter.
const MELDEKORT_STATUS_EN = [
  ["DELTATT_UTEN_LØNN_I_TILTAKET", "Participated"],
  ["DELTATT_MED_LØNN_I_TILTAKET", "Received pay"],
  ["FRAVÆR_SYK", "Sick"],
  ["FRAVÆR_SYKT_BARN", "Sick child or sick child carer"],
  ["FRAVÆR_STERKE_VELFERDSGRUNNER_ELLER_JOBBINTERVJU", "Strong welfare reasons or job interview"],
  ["FRAVÆR_GODKJENT_AV_NAV", "Absence approved by Nav"],
  ["FRAVÆR_ANNET", "Other absence"],
  ["IKKE_TILTAKSDAG", "No employment scheme activity"],
  ["IKKE_RETT_TIL_TILTAKSPENGER", "Not entitled"],
  ["IKKE_BESVART", "No report"],
];

// lib/avslagComponents.typ — én gren per grunn. Samme liste som AVSLAGSGRUNNER i
// test/run-tests.py, med Avslagsgrunnlag i tiltakspenger-saksbehandling-api som kilde.
const AVSLAGSGRUNN = [
  ["DELTAR_IKKE_PÅ_ARBEIDSMARKEDSTILTAK", "Deltar ikke på arbeidsmarkedstiltak"],
  ["ALDER", "Har ikke fylt 18 år"],
  ["LIVSOPPHOLDYTELSE", "Annen pengestøtte til livsopphold"],
  ["KVALIFISERINGSPROGRAMMET", "Deltar på kvalifiseringsprogram"],
  ["INTRODUKSJONSPROGRAMMET", "Deltar på introduksjonsprogram"],
  ["LØNN_FRA_TILTAKSARRANGØR", "Lønn fra tiltaksarrangør"],
  ["LØNN_FRA_ANDRE", "Lønn for arbeid i tiltaksdeltakelsen"],
  ["INSTITUSJONSOPPHOLD", "Institusjonsopphold"],
  ["FREMMET_FOR_SENT", "Søkt for sent"],
];

// toStatus() i BrevMeldekortvedtakDTO.kt (tiltakspenger-saksbehandling-api).
// Statusen kommer ferdig oversatt i flettedataene, så verdien er også etiketten.
// lib/meldekortvedtakComponents.typ forgrener på «Ikke besvart» og «Ikke tiltaksdag».
const MELDEKORTVEDTAK_STATUS = [
  "Deltatt",
  "Deltatt med lønn",
  "Syk",
  "Sykt barn eller syk barnepasser",
  "Sterke velferdsgrunner eller jobbintervju",
  "Fravær godkjent av Nav",
  "Annet fravær",
  "Ikke tiltaksdag",
  "Ikke rett til tiltakspenger",
  "Ikke besvart",
];

// Felt som kan stå tomme.
const INGEN = [null, "(ingen)"];

// Enum-feltene per datasett i testdata/tpts. Nøkkelen er stien inn i flettedataene,
// der «[]» står for et array-ledd.
const ENUM_FELT = {
  meldekort: { "dager[].status": MELDEKORT_STATUS_NB },
  "meldekort-korrigert": { "dager[].status": MELDEKORT_STATUS_NB },
  "meldekort-en": { "dager[].status": MELDEKORT_STATUS_EN },
  "meldekort-korrigert-en": { "dager[].status": MELDEKORT_STATUS_EN },
  vedtakAvslag: { "avslagsgrunner[]": AVSLAGSGRUNN },
  meldekortvedtak: {
    "meldeperioder[].dager[].status.gjeldende": MELDEKORTVEDTAK_STATUS,
    // Forrige status finnes bare når dagen er korrigert.
    "meldeperioder[].dager[].status.forrige": [INGEN, ...MELDEKORTVEDTAK_STATUS],
  },
};

function enumFeltFor(datasett) {
  return ENUM_FELT[datasett] ?? {};
}
