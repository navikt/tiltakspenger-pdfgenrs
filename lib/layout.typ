#import "/lib/styles.typ": *
#import "/lib/typography.typ": *

#let page-setup(data) = body => {
    set page(
        margin: (top: space-64, bottom: space-74, left: space-64, right: space-64),
        header: align(right)[
            #if data.forhandsvisning [
                #text(
                    "Forhåndsvisning",
                    weight: "bold",
                    fill: red,
                    size: 2em,
                )
            ]
        ],
        footer: context [
            #brødtekst[Saksnummer: #data.saksnummer] #h(1fr) #brødtekst[Side #counter(page).display() av #counter(page).final().first()]
        ],
    )
    set text(font: "Source Sans Pro", lang: "no")
    body
}
