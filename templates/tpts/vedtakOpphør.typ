#import "/lib/mod.typ": *

#let data = json("/data/tpts/vedtakOpphør.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Vedtaksbrev for Tiltakspenger"
#show: dokument(title)
#show: innholdsheader(data)

= Vedtaket ditt om tiltakspenger er endret

#brødtekst[
    Nav har vurdert saken din på nytt. Vi har omgjort vedtaket slik at du ikke har rett til tiltakspenger #if data.barnetillegg [og barnetillegg ]fra og med #data.vedtaksperiode.fraOgMed til og med #data.vedtaksperiode.tilOgMed.
]

#if "valgtHjemmelTekst" in data and data.valgtHjemmelTekst != none and data.valgtHjemmelTekst.len() > 0 [
    #brødtekst[#data.valgtHjemmelTekst.at(0).split("\n").join(linebreak())]
]

#brødtekst[
    Når et vedtak bygger på et uriktig faktisk grunnlag, kan Nav omgjøre vedtaket til ugunst for deg. Dette gjelder selv om det ikke var din skyld at vedtaket ble feil.
]

#brødtekst[
    Dette kommer frem av forvaltningsloven § 35 første ledd bokstav c.
]

#block(above: space-26, below: space-26)[
    #if "tilleggstekst" in data and data.tilleggstekst != none and data.tilleggstekst != "" [
        #block(above: space-26, below: space-6)[
            #h2("Slik har vi vurdert saken din")
        ]
        #brødtekst[#data.tilleggstekst.split("\n").join(linebreak())]
    ]
]

#show: vedtaksinfo
#show: signatur(data)
