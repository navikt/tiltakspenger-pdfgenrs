#import "/lib/styles.typ": *
#import "/lib/typography.typ": *
#import "/lib/spraak.typ": språkinnstillinger
#import "/lib/pensjonsbrev/footer.typ": footer as pensjonsbrevFooter
#import "/lib/pensjonsbrev/content/state.typ": section-start, section-end

#let page-setup(data) = body => {
    // fallback: true faller tilbake til Noto-fonter for glyfer Source Sans 3 mangler
    set text(font: "Source Sans 3", fallback: true)
    set page(
        // Marger og footer-descent som i lib/pensjonsbrev/template.typ
        margin: (x: space-64, y: space-64, bottom: space-74),
        header: align(right)[
            #if data.at("forhandsvisning", default: false) [
                #text(
                    "Forhåndsvisning",
                    weight: "bold",
                    fill: red,
                    size: 2em,
                )
            ]
        ],
        footer: context {
            let språk = språkinnstillinger(text.lang)
            if "saksnummer" in data {
                pensjonsbrevFooter(data, språk)
            } else {
                // Innsendte dokumenter (f.eks. søknad) har ikke saksnummer i payloadet
                set text(9pt)
                set align(right)
                [#språk.sideprefix #counter(page).display() #språk.sideinfix #counter(page).final().first()]
            }
        },
        footer-descent: 30% + 4pt,
    )
    // footer.typ og letter-table i lib/pensjonsbrev forutsetter seksjonsmarkører
    section-start(1)
    body
    section-end(1)
}
