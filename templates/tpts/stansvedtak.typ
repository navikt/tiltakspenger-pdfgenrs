#import "/lib/mod.typ": *

#let data = json("/data/tpts/stansvedtak.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Vedtaksbrev for Tiltakspenger"

#set document(
    title: title,
    description: title,
    author: "Team tiltakspenger",
)
#set text(lang: "no")
#show: innholdsheader(data)

= Nav har stanset tiltakspengene dine

#h2("Vedtak")
#brødtekst[
    Tiltakspenger #if data.barnetillegg [og barnetillegg ]stanses fra og med #data.stansFraOgMedDato fordi #data.valgtHjemmelTekst.at(0).split("\n").join(linebreak())
]

#if "tilleggstekst" in data and data.tilleggstekst != none and data.tilleggstekst != "" [
    #block(above: space-26, below: space-6)[
        #h2("Slik har vi vurdert saken din")
    ]
    #brødtekst[#data.tilleggstekst.split("\n").join(linebreak())]
]

#show: vedtaksinfo
#show: signatur(data)
