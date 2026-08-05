// Felt som backend regner ut fra andre felt i samme payload. De er skrivebeskyttet
// i skjemaet og regnes ut på nytt når grunnlaget endres, så forhåndsvisningen ikke
// kan komme i utakt med seg selv — legger du til en avslagsgrunn, følger tellingen med.
//
// Regelen får objektet feltet står i som første argument og hele payloaden som andre.
// Kilden står over hver regel; endres den, må regelen her følge etter.
// Rekkefølgen betyr noe: et felt som bygger på et annet avledet felt må stå etter det.

const AVLEDEDE_FELT = {
  vedtakAvslag: {
    // BrevSøknadAvslagDTO.kt: avslagsgrunnerSize = avslagsgrunner.size
    avslagsgrunnerSize: (data) => data.avslagsgrunner.length,
  },
  meldekortvedtak: {
    // BrevMeldekortvedtakDTO.kt: harBarnetillegg = dager.any { barnetillegg.gjeldende > 0 || (forrige ?: 0) > 0 },
    // regnet ut fra nettopp den daglisten som havner i payloaden.
    "meldeperioder[].harBarnetillegg": (meldeperiode) =>
      meldeperiode.dager.some((dag) => (dag.barnetillegg?.gjeldende ?? 0) > 0 || (dag.barnetillegg?.forrige ?? 0) > 0),
  },
};

// Beløpsfeltene i meldekortvedtak ser avledede ut, men er det ikke herfra:
// `meldeperioder[].beløp` summerer dagene i *beregningen* (`meldeperiodeberegning.dager`),
// mens `dager` i payloaden kommer fra sammenligningen — to lister som DTO-en ikke
// binder sammen. `totaltBelop` kommer tilsvarende fra `Meldekortbehandling.beløpTotal`.
// Å summere dagene i skjemaet ville derfor vært en gjetning, ikke samme regel som backend.
//
// `totalDifferanse = meldeperioder.sumOf { it.beløpDiff }` er derimot entydig i koden,
// men data/tpts/meldekortvedtak.json har -338 der summen er 1352 (1690 + -338).
// Regelen er utelatt til det er avklart hvilken av de to som er feil — ellers ville
// demoen stille vist andre tall enn testdatasettet.

function avledetFeltFor(datasett) {
  return AVLEDEDE_FELT[datasett] ?? {};
}

// Objektene et felt står i. «[]» i stien er et array-ledd, så «meldeperioder[].beløp»
// treffer ett felt per meldeperiode.
function eiereAv(data, sti) {
  const ledd = sti.split(".");
  const navn = ledd.pop();
  let noder = [data];
  for (const nivå of ledd) {
    const nøkkel = nivå.replace("[]", "");
    noder = noder.flatMap((node) => {
      const verdi = node?.[nøkkel];
      if (nivå.endsWith("[]")) return Array.isArray(verdi) ? verdi : [];
      return verdi !== null && typeof verdi === "object" ? [verdi] : [];
    });
  }
  return noder.filter((node) => navn in node).map((eier) => ({ eier, navn }));
}

function beregnAvledede(data, felt) {
  for (const [sti, regel] of Object.entries(felt)) {
    for (const { eier, navn } of eiereAv(data, sti)) eier[navn] = regel(eier, data);
  }
}
