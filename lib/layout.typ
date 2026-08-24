#import "/lib/spraak.typ": språkinnstillinger
#import "/lib/pensjonsbrev/footer.typ": footer as pensjonsbrevFooter
#import "/lib/pensjonsbrev/content/pagesetup.typ": pageSetup
#import "/lib/pensjonsbrev/content/state.typ": section-start, section-end

/*
Font, marger, avsnittsavstander og footer-descent kommer fra pageSetup i lib/pensjonsbrev — samme oppsett som brev- og dokumentrøttene der bruker.
Her legger vi bare på det som er vårt eget: forhåndsvisningsvannmerket og footeren for dokumenter uten saksnummer.
*/
#let page-setup(data) = body => {
    // pageSetup tar ikke imot header, så vannmerket settes utenfor. Set-reglene slås sammen, så margene derfra består.
    set page(
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
    )
    pageSetup(
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
        {
            // footer.typ og letter-table i lib/pensjonsbrev forutsetter seksjonsmarkører
            section-start(1)
            body
            section-end(1)
        },
    )
}
