#import "/lib/mod.typ": *

#let data = json("/data/tpts/stansvedtak.json")
// Mangler valgtHjemmelTekst, lages teksten fra stansgrunner; som før vises bare den første.
#let hjemmeltekster = if data.at("valgtHjemmelTekst", default: none) != none {
    data.valgtHjemmelTekst
} else {
    assert(data.at("stansgrunner", default: ()).len() > 0, message: "Stansbrevet mangler både valgtHjemmelTekst og stansgrunner")
    data.stansgrunner.map(grunn => hjemmeltekst(grunn, "stans", data.barnetillegg))
}
#show: apply-styles
#show: page-setup(data)

#let title = "Vedtaksbrev for Tiltakspenger"
#show: dokument(title)
#show: innholdsheader(data)

= Nav har stanset tiltakspengene dine

#h2("Vedtak")
// Hvert «\n\n»-skilte avsnitt blir eget avsnitt i brevet; det første fullfører innledningen.
#let avsnitt = hjemmeltekster.at(0).split("\n\n")
#brødtekst[
    Tiltakspenger #if data.barnetillegg [og barnetillegg ]stanses fra og med #data.stansFraOgMedDato fordi #medLinjeskift(avsnitt.first())
]
#for resten in avsnitt.slice(1) {
    brødtekst[#medLinjeskift(resten)]
}

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
