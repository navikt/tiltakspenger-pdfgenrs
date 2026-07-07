#import "/lib/mod.typ": *

#let data = json("/data/tpts/vedtakAvslag.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Vedtaksbrev for Tiltakspenger"
#show: dokument(title)
#show: innholdsheader(data)

= Du har fått avslag på din søknad om tiltakspenger

#avslagsgrunner(data)

#if "tilleggstekst" in data and data.tilleggstekst != none [
    #block(above: space-26, below: space-6)[
        #h2("Slik har vi vurdert saken din")
    ]
    #brødtekst[#data.tilleggstekst.split("\n").join(linebreak())]
]

#show: vedtaksinfo
#show: signatur(data)
