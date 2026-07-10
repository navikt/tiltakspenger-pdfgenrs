#import "/lib/mod.typ": *

#let data = json("/data/tpts/klageAvvis.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Vedtaksbrev for Tiltakspenger"
#show: dokument(title)
#show: innholdsheader(data)

= Vi har avvist klagen din på vedtak om tiltakspenger

#block(above: space-26, below: space-26)[
    #(
        data
            .tilleggstekst
            .map(item => [
                #h2[#item.tittel]
                #brødtekst[#item.tekst]
            ])
            .join()
    )
]

#show: vedtaksinfo
#show: signatur(data)







