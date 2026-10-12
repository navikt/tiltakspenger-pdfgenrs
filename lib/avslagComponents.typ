#import "/lib/typography.typ": *
#import "/lib/styles.typ": *
#import "/lib/hjemmeltekster.typ": *

#let medLinjeskift(tekst) = tekst.split("\n").join(linebreak())

// Brevtekstene lages i tiltakspenger-saksbehandling-api (BrevSøknadAvslagDTO.kt) og kommer i valgtHjemmelTekst.
// Mangler valgtHjemmelTekst, lages tekstene fra avslagsgrunner med lib/hjemmeltekster.typ.
// Én avslagsgrunn: hele teksten med hjemler fullfører innledningen.
// Flere avslagsgrunner: én punkttekst per grunn, med de samlede hjemlene i hjemlerTekst under punktlisten.
// Mangler hjemlerTekst, lages setningen fra hjemler med hjemmelsetning i lib/hjemmeltekster.typ.
#let avslagsgrunner(data) = {
    let tekster = data.at("valgtHjemmelTekst", default: none)
    if tekster == none {
        assert(data.at("avslagsgrunner", default: ()).len() > 0, message: "Avslagsbrevet mangler både valgtHjemmelTekst og avslagsgrunner")
        let grunner = data.avslagsgrunner
        tekster = if grunner.len() == 1 {
            (hjemmeltekst(grunner.first(), "avslag", data.harSøktMedBarn),)
        } else {
            grunner.map(grunn => avslagspunkttekst(grunn, data.harSøktMedBarn))
        }
    }
    let barn = if data.harSøktMedBarn { " og barnetillegg" } else { "" }
    let innledning = [Du får ikke tiltakspenger#barn fra og med #data.avslagFraOgMed til og med #data.avslagTilOgMed fordi]

    if tekster.len() == 1 {
        // Hvert «\n\n»-skilte avsnitt blir eget avsnitt i brevet; det første fullfører innledningen.
        let avsnitt = tekster.at(0).split("\n\n")
        brødtekst[#innledning #medLinjeskift(avsnitt.first())]
        for resten in avsnitt.slice(1) {
            brødtekst[#medLinjeskift(resten)]
        }
    } else if tekster.len() > 1 {
        brødtekst[#innledning:]
        block(below: space-16)[
            #list(
                spacing: space-16,
                ..tekster.map(tekst => {
                    // Første linje er selve punktet, resten er forklarende tekst under punktet.
                    set block(spacing: space-4)
                    brødtekst[#medLinjeskift(tekst)]
                }),
            )
        ]
        let hjemlerTekst = data.at("hjemlerTekst", default: none)
        if hjemlerTekst == none {
            assert(data.at("hjemler", default: none) != none, message: "Avslagsbrevet mangler både hjemlerTekst og hjemler")
            hjemlerTekst = hjemmelsetning(data.hjemler)
        }
        brødtekst[#hjemlerTekst]
    }
}
