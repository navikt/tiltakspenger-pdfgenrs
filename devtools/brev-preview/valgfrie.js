// Objekter i flettedataene som kan være null, med et eksempel skjemaet fyller inn
// når feltet slås på. Uten dette blir et null-felt et tekstfelt, og det som skrives
// der sendes som streng til malen i stedet for som objekt.
//
// Eksemplene er kopier av variantene i test/data, siden demo-imaget bare
// inneholder devtools/brev-preview og testdata/tpts.

const VALGFRIE_FELT = {
  vedtakForlengelse: {
    // BrevForlengelseDTO.kt: barn som fyller 16 år i forlengelsen.
    // Se test/data/vedtakForlengelse--*-fyller-16.json for de tre tekstvariantene.
    barnSomFyller16: { antall: 1, antallBarnIVedtaket: 2, sisteDagMedBarnetillegg: "2025-06-30" },
  },
  vedtakAvslag: {
    // BrevSøknadAvslagDTO.kt: innvilgelsen med samme periode som avslaget ved avslagsgrunnen INNVILGET_TILTAKSPENGER.
    // Null gir reserveteksten uten datoer; se test/data/vedtakAvslag--innvilget-tiltakspenger-uten-tidligere-innvilgelse.json.
    tidligereInnvilgelse: { fraOgMed: "2025-01-01", tilOgMed: "2025-01-10", vedtaksdato: "2024-12-20", harBarnetillegg: false },
  },
};

function valgfrieFeltFor(datasett) {
  return VALGFRIE_FELT[datasett] ?? {};
}
