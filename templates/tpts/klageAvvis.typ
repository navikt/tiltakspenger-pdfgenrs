#import "/templates/tpts/lib/mod.typ": *

#let data = json("/data/tpts/klageAvvis.json")
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

= Vi har avvist klagen din på vedtak om tiltakspenger

#(
    data
        .tilleggstekst
        .map(item => [
            #h2[#item.tittel]
            #brødtekst[#item.tekst]
        ])
        .join()
)

#show: vedtaksinfo
#show: signatur(data)







