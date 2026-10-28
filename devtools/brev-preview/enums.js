// Feltene i flettedataene som egentlig er enum, slik at skjemaet kan vise en
// nedtrekksliste i stedet for et fritekstfelt.
//
// Listene er kopier av kilden, og kilden står i kommentaren over hver liste.
// Endres den, må listen her oppdateres for hånd. Verdiene kan ikke leses ut av
// malene i drift, siden demo-imaget bare inneholder devtools/brev-preview og
// testdata/tpts.
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

// Valget for tom verdi i nedtrekkslistene.
const INGEN = [null, "(ingen)"];

// Grunnene for avslag, stans og opphør (GrunnBrevDto.kt i tiltakspenger-saksbehandling-api).
// Etikettene er de saksbehandlerne ser i tiltakspenger-saksbehandling (AvslagsgrunnTekst).
// Hver brevtype har bare grunnene saksbehandling-api kan sende for den (tilGrunnBrevDto).
const GRUNN = {
  DELTAR_IKKE_PÅ_ARBEIDSMARKEDSTILTAK: "Deltar ikke på arbeidsmarkedstiltak",
  ALDER: "Alder",
  LIVSOPPHOLDYTELSE: "Livsoppholdytelser",
  KVALIFISERINGSPROGRAMMET: "Kvalifiseringsprogrammet",
  INTRODUKSJONSPROGRAMMET: "Introduksjonsprogrammet",
  LØNN_FRA_TILTAKSARRANGØR: "Lønn fra tiltaksarrangør",
  LØNN_FRA_ANDRE: "Lønn fra andre",
  INSTITUSJONSOPPHOLD: "Institusjonsopphold",
  IKKE_LOVLIG_OPPHOLD: "Ikke lovlig opphold",
  FREMMET_FOR_SENT: "Fremmet for sent",
  FORLENGET_VENTETID: "Forlenget ventetid",
};
const grunner = (...utenom) => Object.entries(GRUNN).filter(([kode]) => !utenom.includes(kode));
const AVSLAGSGRUNNER = grunner("IKKE_LOVLIG_OPPHOLD");
const STANSGRUNNER = grunner("FREMMET_FOR_SENT", "FORLENGET_VENTETID");
const OPPHØRSGRUNNER = grunner("FORLENGET_VENTETID");

// RettskildeBrevDto i HjemmelBrevDto.kt (tiltakspenger-saksbehandling-api).
const RETTSKILDE = [
  ["ARBEIDSMARKEDSLOVEN", "Arbeidsmarkedsloven"],
  ["FOLKETRYGDLOVEN", "Folketrygdloven"],
  ["FORELDELSESLOVEN", "Foreldelsesloven"],
  ["FORVALTNINGSLOVEN", "Forvaltningsloven"],
  ["TILTAKSPENGEFORSKRIFTEN", "Tiltakspengeforskriften"],
];

// BegrunnelsestypeDto i JournalnotatDokumentDto.kt; etikettene er overskriftene i templates/tpts/journalnotat.typ.
const BEGRUNNELSESTYPE = [
  ["VILKÅRSVURDERING", "Begrunnelse for vilkårsvurderingen"],
  ["BARNETILLEGG", "Begrunnelse for barnetillegg"],
  ["MELDEKORT", "Begrunnelse (meldekort)"],
];

// AntallDagerForMeldeperiode tillater 1–14; null betyr at antallet varierer i perioden.
// lib/innvilgelseComponents.typ skriver dagteksten bare for partall fra 2 til 10.
const ANTALL_DAGER = [
  [null, "Varierer i perioden (ingen dagtekst)"],
  ...Array.from({ length: 14 }, (_, i) => [i + 1, `${i + 1} dager per meldeperiode`]),
];

// Enum-feltene per datasett i testdata/tpts. Nøkkelen er stien inn i flettedataene,
// der «[]» står for et array-ledd.
const ENUM_FELT = {
  meldekort: { "dager[].status": MELDEKORT_STATUS_NB },
  "meldekort-korrigert": { "dager[].status": MELDEKORT_STATUS_NB },
  "meldekort-en": { "dager[].status": MELDEKORT_STATUS_EN },
  "meldekort-korrigert-en": { "dager[].status": MELDEKORT_STATUS_EN },
  vedtakAvslag: { "avslagsgrunner[]": AVSLAGSGRUNNER, "hjemler[].rettskilde": RETTSKILDE },
  stansvedtak: { "stansgrunner[]": STANSGRUNNER },
  vedtakOpphør: { "opphørsgrunner[]": OPPHØRSGRUNNER },
  vedtakInnvilgelse: { "innvilgelsesperioder.antallDagerPerMeldeperiode": ANTALL_DAGER },
  revurderingInnvilgelse: { "innvilgelsesperioder.antallDagerPerMeldeperiode": ANTALL_DAGER },
  vedtakForlengelse: { "innvilgelsesperioder.antallDagerPerMeldeperiode": ANTALL_DAGER },
  journalnotat: { "begrunnelser[].type": BEGRUNNELSESTYPE },
  meldekortvedtak: {
    "meldeperioder[].dager[].status.gjeldende": MELDEKORTVEDTAK_STATUS,
    // Forrige status finnes bare når dagen er korrigert.
    "meldeperioder[].dager[].status.forrige": [INGEN, ...MELDEKORTVEDTAK_STATUS],
  },
};

function enumFeltFor(datasett) {
  return ENUM_FELT[datasett] ?? {};
}
