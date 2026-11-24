// Objekter i flettedataene som kan være null, med et eksempel skjemaet fyller inn
// når feltet slås på. Uten dette blir et null-felt et tekstfelt, og det som skrives
// der sendes som streng til malen i stedet for som objekt.
//
// Eksemplene er kopier av variantene i test/data og test/run-tests.py, siden
// demo-imaget bare inneholder devtools/brev-preview og testdata/tpts.

const VALGFRIE_FELT = {
  vedtakForlengelse: {
    // BrevForlengelseDTO.kt: barn som fyller 16 år i forlengelsen.
    // Se test/data/vedtakForlengelse--*-fyller-16.json for de tre tekstvariantene.
    barnSomFyller16: { antall: 1, antallBarnIVedtaket: 2, sisteDagMedBarnetillegg: "2025-06-30" },
  },
  vedtakAvslag: {
    // BrevSøknadAvslagDTO.kt: innvilgelsen med samme periode som avslaget ved avslagsgrunnen INNVILGET_TILTAKSPENGER, med tiltakene i den perioden.
    // Eksempelet er vedtakAvslag--allerede-innvilget i hjemmeltekstvarianter() i test/run-tests.py.
    // Velg INNVILGET_TILTAKSPENGER som eneste grunn for å se brevets egen første del; ett tiltak står i setningen, flere som punktliste.
    // Null gir avslagsperioden uten tiltak og vedtaksdato; se vedtakAvslag--allerede-innvilget-uten-tidligere-innvilgelse i test/run-tests.py.
    tidligereInnvilgelse: { fraOgMed: "2025-01-01", tilOgMed: "2025-01-10", vedtaksdato: "2024-12-20", harBarnetillegg: false, tiltak: ["Arbeidstrening"] },
  },
};

function valgfrieFeltFor(datasett) {
  return VALGFRIE_FELT[datasett] ?? {};
}
