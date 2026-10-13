// Hjemmeltekstene for avslag, stans og opphør bor her, og tiltakspenger-saksbehandling-api sender bare kodene.
// Avsnitt skilles med «\n\n» og linjer med «\n».
// Fasiten i test/fasit/hjemmeltekster.json skal endres i takt med denne fila.

#let avslagstekster(ytelse, medBarnetillegg) = (
    "DELTAR_IKKE_PÅ_ARBEIDSMARKEDSTILTAK": "du ikke deltar på arbeidsmarkedstiltak som gir rett til tiltakspenger.\n\nFor å få " + ytelse + " må du delta i arbeidsmarkedstiltak som gir rett til " + ytelse + ".\n\nDette kommer frem av arbeidsmarkedsloven § 13 og tiltakspengeforskriften " + (if medBarnetillegg { "§§ 2 og 3" } else { "§ 2" }) + ".",
    "ALDER": "du ikke har fylt 18 år. Du må ha fylt 18 år for å ha rett til å få " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 3.",
    "LIVSOPPHOLDYTELSE": "du mottar en annen pengestøtte til livsopphold. Deltakere som har rett til andre pengestøtter til livsopphold har ikke samtidig rett til å få " + ytelse + ".\n\nDette kommer frem av arbeidsmarkedsloven § 13 første ledd og tiltakspengeforskriften § 7 første ledd.",
    "KVALIFISERINGSPROGRAMMET": "du deltar på kvalifiseringsprogram. Deltakere i kvalifiseringsprogram har ikke rett til " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 7 tredje ledd.",
    "INTRODUKSJONSPROGRAMMET": "du deltar på introduksjonsprogram. Deltakere i introduksjonsprogram har ikke rett til " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 7 tredje ledd.",
    "LØNN_FRA_TILTAKSARRANGØR": "du mottar lønn fra tiltaksarrangør for tiden i arbeidsmarkedstiltaket.\n\nDeltakere som mottar lønn fra tiltaksarrangør for tid i arbeidsmarkedstiltaket har ikke rett til " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 8.",
    "LØNN_FRA_ANDRE": "du mottar lønn for arbeid som er en del av tiltaksdeltakelsen og du derfor har dekning av utgifter til livsopphold.\n\nDeltaker i arbeidsmarkedstiltak som har rett til å få dekket utgifter til livsopphold på annen måte har ikke rett til " + ytelse + ". Lønn anses som dekning av utgifter til livsopphold på annen måte, når du får lønnen for arbeid som er en del av tiltaksdeltakelsen.\n\nLønn fra arbeid utenom tiltaksdeltakelsen har ikke betydning for din rett til tiltakspenger.\n\nDette kommer frem av arbeidsmarkedsloven § 13 og tiltakspengeforskriften § 8 andre ledd.",
    "INSTITUSJONSOPPHOLD": "du oppholder deg på en institusjon med gratis opphold, mat og drikke.\n\nDeltakere som har opphold i institusjon med gratis opphold, mat og drikke under gjennomføringen av arbeidsmarkedstiltaket har ikke rett til " + ytelse + ".\n\nDet er gjort unntak for opphold i barnevernsinstitusjoner. Dette kommer frem av tiltakspengeforskriften § 9.",
    "FREMMET_FOR_SENT": "du har søkt om " + ytelse + " for sent.\n\nTiltakspenger gis for opptil tre måneder før den måneden tiltaksdeltakeren søkte om " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 11.",
)

#let avslagspunkttekster(ytelse) = (
    "DELTAR_IKKE_PÅ_ARBEIDSMARKEDSTILTAK": "Du deltar ikke på arbeidsmarkedstiltak som gir rett til tiltakspenger.\nFor å få " + ytelse + " må du delta i arbeidsmarkedstiltak som gir rett til " + ytelse + ".",
    "ALDER": "Du har ikke fylt 18 år.\nDu må ha fylt 18 år for å ha rett til å få " + ytelse + ".",
    "LIVSOPPHOLDYTELSE": "Du mottar en annen pengestøtte til livsopphold.\nDeltakere som har rett til andre pengestøtter til livsopphold har ikke samtidig rett til å få " + ytelse + ".",
    "KVALIFISERINGSPROGRAMMET": "Du deltar på kvalifiseringsprogram.\nDeltakere i kvalifiseringsprogram har ikke rett til " + ytelse + ".",
    "INTRODUKSJONSPROGRAMMET": "Du deltar på introduksjonsprogram.\nDeltakere i introduksjonsprogram har ikke rett til " + ytelse + ".",
    "LØNN_FRA_TILTAKSARRANGØR": "Du mottar lønn fra tiltaksarrangør for tiden i arbeidsmarkedstiltaket.\nDeltakere som mottar lønn fra tiltaksarrangør for tid i arbeidsmarkedstiltaket har ikke rett til " + ytelse + ".",
    "LØNN_FRA_ANDRE": "Du mottar lønn for arbeid som er en del av tiltaksdeltakelsen og du derfor har dekning av utgifter til livsopphold.\nDeltaker i arbeidsmarkedstiltak som har rett til å få dekket utgifter til livsopphold på annen måte har ikke rett til " + ytelse + ". Lønn anses som dekning av utgifter til livsopphold på annen måte, når du får lønnen for arbeid som er en del av tiltaksdeltakelsen.\nLønn fra arbeid utenom tiltaksdeltakelsen har ikke betydning for din rett til tiltakspenger.",
    "INSTITUSJONSOPPHOLD": "Du oppholder deg på en institusjon med gratis opphold, mat og drikke.\nDeltakere som har opphold i institusjon med gratis opphold, mat og drikke under gjennomføringen av arbeidsmarkedstiltaket har ikke rett til " + ytelse + ".",
    "FREMMET_FOR_SENT": "Du har søkt om " + ytelse + " for sent.\nTiltakspenger gis for opptil tre måneder før den måneden tiltaksdeltakeren søkte om " + ytelse + ".",
)

#let stanstekster(ytelse) = (
    "DELTAR_IKKE_PÅ_ARBEIDSMARKEDSTILTAK": "du ikke lenger deltar på arbeidsmarkedstiltak.\n\nDu må være deltaker i et arbeidsmarkedstiltak for å ha rett til å få " + ytelse + ".\n\nDette kommer frem av arbeidsmarkedsloven § 13 og tiltakspengeforskriften § 2.",
    "ALDER": "du ikke har fylt 18 år. Du må ha fylt 18 år for å ha rett til å få " + ytelse + ".\n\nDet kommer frem av tiltakspengeforskriften § 3.",
    "LIVSOPPHOLDYTELSE": "du mottar en annen pengestøtte til livsopphold. Deltakere som har rett til andre pengestøtter til livsopphold har ikke samtidig rett til å få " + ytelse + ".\n\nDette kommer frem av arbeidsmarkedsloven § 13 første ledd og tiltakspengeforskriften § 7 første ledd.",
    "KVALIFISERINGSPROGRAMMET": "du deltar på kvalifiseringsprogram. Deltakere i kvalifiseringsprogram har ikke rett til " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 7 tredje ledd.",
    "INTRODUKSJONSPROGRAMMET": "du deltar på introduksjonsprogram. Deltakere i introduksjonsprogram har ikke rett til " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 7 tredje ledd.",
    "LØNN_FRA_TILTAKSARRANGØR": "du mottar lønn fra tiltaksarrangør for tiden i arbeidsmarkedstiltaket.\n\nDeltakere som mottar lønn fra tiltaksarrangør for tid i arbeidsmarkedstiltaket har ikke rett til " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 8.",
    "LØNN_FRA_ANDRE": "du mottar lønn for arbeid som er en del av tiltaksdeltakelsen og du derfor har dekning av utgifter til livsopphold.\n\nDeltaker i arbeidsmarkedstiltak som har rett til å få dekket utgifter til livsopphold på annen måte har ikke rett til " + ytelse + ". Lønn anses som dekning av utgifter til livsopphold på annen måte, når du får lønnen for arbeid som er en del av tiltaksdeltakelsen.\n\nLønn fra arbeid utenom tiltaksdeltakelsen har ikke betydning for din rett til tiltakspenger.\n\nDette kommer frem av arbeidsmarkedsloven § 13 og tiltakspengeforskriften § 8 andre ledd.",
    "INSTITUSJONSOPPHOLD": "du oppholder deg på en institusjon med gratis opphold, mat og drikke.\n\nDeltakere som har opphold i institusjon med gratis opphold, mat og drikke under gjennomføringen av arbeidsmarkedstiltaket har ikke rett til " + ytelse + ".\n\nDet er gjort unntak for opphold i barnevernsinstitusjoner. Dette kommer frem av tiltakspengeforskriften § 9.",
    "IKKE_LOVLIG_OPPHOLD": "du i denne perioden ikke har lovlig opphold i Norge.\n\nDu må ha lovlig opphold i Norge, for å ha rett til " + ytelse + ".\n\nDette kommer frem av arbeidsmarkedsloven § 2.",
)

// ALDER og FREMMET_FOR_SENT har ingen standardtekst i opphør; begrunnelsen står da i tilleggsteksten.
#let opphørstekster(ytelse) = (
    "ALDER": none,
    "FREMMET_FOR_SENT": none,
    "DELTAR_IKKE_PÅ_ARBEIDSMARKEDSTILTAK": "Vilkåret om deltakelse i arbeidsmarkedstiltak er ikke oppfylt i denne perioden.\n\nDu må være deltaker i et arbeidsmarkedstiltak for å ha rett til å få " + ytelse + ".\n\nDette kommer frem av arbeidsmarkedsloven § 13, tiltakspengeforskriften § 2.",
    "LIVSOPPHOLDYTELSE": "Du har rett til annen pengestøtte til livsopphold i denne perioden.\n\nDeltakere som har rett til andre pengestøtter til livsopphold har ikke samtidig rett til å få " + ytelse + ".\n\nDette kommer frem av arbeidsmarkedsloven § 13 første ledd, forskrift om tiltakspenger § 7 første ledd.",
    "KVALIFISERINGSPROGRAMMET": "Du er deltaker i kvalifiseringsprogram i denne perioden. Deltakere i kvalifiseringsprogram har ikke rett til " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 7 tredje ledd.",
    "INTRODUKSJONSPROGRAMMET": "Du er deltaker i introduksjonsprogram i denne perioden. Deltakere i introduksjonsprogram har ikke rett til " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 7 tredje ledd.",
    "LØNN_FRA_TILTAKSARRANGØR": "Du mottar lønn fra tiltaksarrangøren for tiden i arbeidsmarkedstiltaket for denne perioden.\n\nDeltakere som mottar lønn fra tiltaksarrangør for tid i arbeidsmarkedstiltaket har ikke rett til " + ytelse + ".\n\nDette kommer frem av tiltakspengeforskriften § 8.",
    "LØNN_FRA_ANDRE": "Du mottar i denne perioden lønn for arbeid som er en del av tiltaksdeltakelsen. Du har derfor dekning av utgifter til livsopphold.\n\nDeltaker i arbeidsmarkedstiltak som har rett til å få dekket utgifter til livsopphold på annen måte har ikke rett til " + ytelse + ". Lønn anses som dekning av utgifter til livsopphold på annen måte, når du får lønnen for arbeid som er en del av tiltaksdeltakelsen.\n\nLønn fra arbeid utenom tiltaksdeltakelsen har ikke betydning for din rett til tiltakspenger.\n\nDette kommer frem av arbeidsmarkedsloven § 13, tiltakspengeforskriften § 8 andre ledd.",
    "INSTITUSJONSOPPHOLD": "Du oppholder deg på en institusjon med gratis opphold, mat og drikke i denne perioden.\n\nDeltakere som har opphold i institusjon med gratis opphold, mat og drikke under gjennomføringen av arbeidsmarkedstiltaket har ikke rett til " + ytelse + ".\n\nDet er gjort unntak for opphold i barnevernsinstitusjoner. Dette kommer frem av tiltakspengeforskriften § 9.",
    "IKKE_LOVLIG_OPPHOLD": "I denne perioden har du ikke lovlig opphold i Norge.\n\nDu må ha lovlig opphold i Norge, for å ha rett til " + ytelse + ".\n\nDette kommer frem av arbeidsmarkedsloven § 2.",
)

#let ytelsen(medBarnetillegg) = "tiltakspenger" + if medBarnetillegg { " og barnetillegg" } else { "" }

// Hele teksten for én grunn, eller none når brevtypen med vilje ikke har tekst for grunnen.
// brevtype er "avslag", "stans" eller "opphør".
// En ukjent grunn stopper rendringen, slik at en feil kode aldri gir et brev uten begrunnelse.
#let hjemmeltekst(grunn, brevtype, medBarnetillegg) = {
    let ytelse = ytelsen(medBarnetillegg)
    let tekster = if brevtype == "avslag" { avslagstekster(ytelse, medBarnetillegg) } else if brevtype == "stans" { stanstekster(ytelse) } else if brevtype == "opphør" { opphørstekster(ytelse) } else { panic("Ukjent brevtype: " + brevtype) }
    if grunn not in tekster { panic("Ukjent grunn for " + brevtype + ": " + grunn) }
    tekster.at(grunn)
}

// Leddene skrives som i createBrevForskrifter i BrevSøknadAvslagDTO.kt, med komma foran «og» ved tre eller flere ledd.
#let leddtekst(ledd) = {
    let ord = ledd.map(nummer => {
        if nummer not in (1, 2, 3) { panic("Ukjent leddnummer i hjemler") }
        ("første", "andre", "tredje").at(nummer - 1)
    })
    if ord.len() == 1 { ord.first() + " ledd" } else if ord.len() == 2 { ord.join(" og ") + " ledd" } else { ord.slice(0, -1).join(", ") + ", og " + ord.last() + " ledd" }
}

// Paragrafene i én rettskilde, sortert etter tallet de begynner med (§ 2 før § 11) og deretter som tekst.
// Paragrafer som ikke begynner med et tall, sorteres sist, som med Int.MAX_VALUE i Kotlin.
#let paragraftekst(hjemler) = {
    let ledd = (:)
    for hjemmel in hjemler {
        let liste = ledd.at(hjemmel.paragraf, default: ())
        if hjemmel.ledd != none { liste.push(hjemmel.ledd) }
        ledd.insert(hjemmel.paragraf, liste)
    }
    let paragrafer = ledd.keys().sorted(key: paragraf => {
        let tall = paragraf.match(regex("^\d+"))
        (if tall == none { 9223372036854775807 } else { int(tall.text) }, paragraf)
    })
    let deler = paragrafer.map(paragraf => {
        let liste = ledd.at(paragraf).dedup().sorted()
        if liste.len() == 0 { paragraf } else { paragraf + " " + leddtekst(liste) }
    })
    (if deler.len() == 1 { "§ " } else { "§§ " }) + deler.join(", ", last: " og ")
}

// Setningen med de samlede hjemlene under punktlisten i avslag med flere grunner.
// Gir samme tekst som createBrevForskrifter i BrevSøknadAvslagDTO.kt; fasiten er test/fasit/hjemler.json.
// hjemler er en liste med rettskilde, paragraf og ledd, med duplikater og usortert.
#let hjemmelsetning(hjemler) = {
    let rettskilder = (ARBEIDSMARKEDSLOVEN: "arbeidsmarkedsloven", TILTAKSPENGEFORSKRIFTEN: "tiltakspengeforskriften")
    for hjemmel in hjemler {
        if hjemmel.rettskilde not in rettskilder { panic("Ukjent rettskilde i hjemler: " + hjemmel.rettskilde) }
    }
    let deler = ()
    for (kode, navn) in rettskilder {
        let utvalg = hjemler.filter(hjemmel => hjemmel.rettskilde == kode)
        if utvalg.len() > 0 { deler.push(navn + " " + paragraftekst(utvalg)) }
    }
    if deler.len() == 0 { panic("Fant ingen hjemler") }
    "Dette kommer frem av " + deler.join(", og ") + "."
}

// Kortere tekst uten hjemler til punktlisten i avslag med flere grunner.
#let avslagspunkttekst(grunn, medBarnetillegg) = {
    let tekster = avslagspunkttekster(ytelsen(medBarnetillegg))
    if grunn not in tekster { panic("Ukjent avslagsgrunn: " + grunn) }
    tekster.at(grunn)
}
