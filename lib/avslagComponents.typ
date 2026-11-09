#import "/lib/typography.typ": *
#import "/lib/styles.typ": *
#import "/lib/hjemmeltekster.typ": *
#import "/lib/format.typ": dato

// Faktum i halvfet, regelen rett under i vanlig skrift; blokken deles ikke over sideskift.
#let grunnblokk(begrunnelse) = block(breakable: false)[
    #strong(begrunnelse.faktum + ".")#linebreak()#begrunnelse.forklaring.first()
    #for avsnitt in begrunnelse.forklaring.slice(1) {
        block(above: space-12, below: 0pt, avsnitt)
    }
]

// Én grunn står i konklusjonen etter «fordi»; flere grunner står som punktliste etter «Grunnene er:».
#let avslagsgrunner(data) = {
    assert(data.at("avslagsgrunner", default: ()).len() > 0, message: "Avslagsbrevet mangler avslagsgrunner")
    assert(data.at("hjemler", default: ()).len() > 0, message: "Avslagsbrevet mangler hjemler")
    let ytelse = ytelsen(data.harSøktMedBarn)
    let periode = [fra og med #dato(data.avslagFraOgMed) til og med #dato(data.avslagTilOgMed)]
    let begrunnelser = data.avslagsgrunner.map(grunn => avslagsbegrunnelse(grunn, data.harSøktMedBarn))
    if begrunnelser.len() == 1 {
        let begrunnelse = begrunnelser.first()
        brødtekst[Du får ikke #ytelse #periode fordi #begrunnelse.fordi.]
        for avsnitt in begrunnelse.forklaring { brødtekst(avsnitt) }
    } else {
        // Konklusjonen følger første punkt over sideskift, og ekstra luft under listen skiller hjemmelsetningen fra siste punkt.
        block(sticky: true, brødtekst[Du får ikke #ytelse #periode.#linebreak()Grunnene er:])
        block(below: space-26)[
            #list(spacing: space-20, ..begrunnelser.map(grunnblokk))
        ]
    }
    brødtekst[#hjemmelsetning(data.hjemler)]
}
