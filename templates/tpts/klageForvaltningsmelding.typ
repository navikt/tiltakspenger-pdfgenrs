#import "/lib/mod.typ": *

#let data = json("/data/tpts/klageForvaltningsmelding.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Forvaltningsmelding Tiltakspenger"
#show: dokument(title)
#show: innholdsheader(data)

= Informasjon om saksbehandlingstiden vår

#block(above: space-26, below: space-26)[
    #brødtekst[
        Vi viser til klagen din av #dato(data.innsendingsdato).
    ]

    #for tillegg in data.tilleggstekst {
        h2(tillegg.tittel)
        brødtekst[#tillegg.tekst.split("\n").join(linebreak())]
    }

    #h2([Du må melde fra om endringer])
    #brødtekst[
        Skjer det endringer som kan ha betydning for saken din, må du melde fra til oss med en gang.
    ]
]

#block(below: space-32)[
    #h2([Har du spørsmål?])
    #brødtekst[
        Du finner mer informasjon på #navLenke("nav.no")[nav.no].
    ]

    #brødtekst[
        På #navLenke("nav.no/kontakt")[nav.no/kontakt] kan du chatte eller skrive til oss.
    ]

    #brødtekst[
        Hvis du ikke finner svar på #navLenke("nav.no")[nav.no], kan du ringe oss på telefon 55 55 33 33, hverdager 09.00–15.00.
    ]
]

#show: signatur(data)
