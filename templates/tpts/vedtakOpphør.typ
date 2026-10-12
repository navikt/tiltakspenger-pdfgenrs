#import "/lib/mod.typ": *

#let data = json("/data/tpts/vedtakOpphør.json")
// Finnes feltet valgtHjemmelTekst, brukes det; en tom liste eller null betyr at ingen av de valgte grunnene har tekst, og at begrunnelsen står i tilleggsteksten.
// Mangler feltet, lages teksten fra opphørsgrunner; som før vises bare den første.
// Grunner uten tekst (ALDER, FREMMET_FOR_SENT) faller bort, slik at begrunnelsen da står i tilleggsteksten.
#let hjemmeltekster = if "valgtHjemmelTekst" in data {
    if data.valgtHjemmelTekst == none { () } else { data.valgtHjemmelTekst }
} else {
    assert("opphørsgrunner" in data, message: "Opphørsbrevet mangler både valgtHjemmelTekst og opphørsgrunner")
    data.opphørsgrunner.map(grunn => hjemmeltekst(grunn, "opphør", data.barnetillegg)).filter(tekst => tekst != none)
}
#show: apply-styles
#show: page-setup(data)

#let title = "Vedtaksbrev for Tiltakspenger"
#show: dokument(title)
#show: innholdsheader(data)

= Vedtaket ditt om tiltakspenger er endret

#brødtekst[
    Nav har vurdert saken din på nytt. Vi har omgjort vedtaket slik at du ikke har rett til tiltakspenger #if data.barnetillegg [og barnetillegg ]fra og med #data.vedtaksperiode.fraOgMed til og med #data.vedtaksperiode.tilOgMed.
]

// Hvert «\n\n»-skilte avsnitt blir eget avsnitt i brevet, med vanlig avstand mellom avsnitt.
#if hjemmeltekster.len() > 0 {
    for avsnitt in hjemmeltekster.at(0).split("\n\n") {
        brødtekst[#medLinjeskift(avsnitt)]
    }
}

#brødtekst[
    Når et vedtak bygger på et uriktig faktisk grunnlag, kan Nav omgjøre vedtaket til ugunst for deg. Dette gjelder selv om det ikke var din skyld at vedtaket ble feil.
]

#brødtekst[
    Dette kommer frem av forvaltningsloven § 35 første ledd bokstav c.
]

// Blokken lages bare når det finnes tilleggstekst, ellers gir den tomme blokken ekstra luft før «Du har rett til å klage».
#if "tilleggstekst" in data and data.tilleggstekst != none and data.tilleggstekst != "" [
    #block(above: space-26, below: space-26)[
        #block(above: space-26, below: space-6)[
            #h2("Slik har vi vurdert saken din")
        ]
        #brødtekst[#data.tilleggstekst.split("\n").join(linebreak())]
    ]
]

#show: vedtaksinfo
#show: signatur(data)
