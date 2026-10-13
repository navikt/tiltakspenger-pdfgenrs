#import "/lib/typography.typ": *
#import "/lib/styles.typ": *
#import "/lib/hjemmeltekster.typ": *

#let medLinjeskift(tekst) = tekst.split("\n").join(linebreak())

// Tekstene lages fra avslagsgrunner med lib/hjemmeltekster.typ.
// Én avslagsgrunn: hele teksten med hjemler fullfører innledningen.
// Flere avslagsgrunner: én punkttekst per grunn, med setningen om de samlede hjemlene under punktlisten, laget fra hjemler med hjemmelsetning.
#let avslagsgrunner(data) = {
    assert(data.at("avslagsgrunner", default: ()).len() > 0, message: "Avslagsbrevet mangler avslagsgrunner")
    let grunner = data.avslagsgrunner
    let tekster = if grunner.len() == 1 {
        (hjemmeltekst(grunner.first(), "avslag", data.harSøktMedBarn),)
    } else {
        grunner.map(grunn => avslagspunkttekst(grunn, data.harSøktMedBarn))
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
        assert(data.at("hjemler", default: ()).len() > 0, message: "Avslagsbrevet mangler hjemler")
        brødtekst[#hjemmelsetning(data.hjemler)]
    }
}
