#import "/lib/mod.typ": *
#import "/lib/meldekortvedtakComponents.typ": *

#let data = json("/data/tpts/meldekortvedtak.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Utbetalingsvedtak"

#set document(
    title: title,
    description: title,
    author: "Team tiltakspenger",
)
#set text(lang: "no")

#block(below: space-26, width: 100%)[
    #align(center)[
        #image("/resources/img.png", height: space-16, alt: "NAV logo")
    ]

    = #title

    #nøkkelinfo((
        ("Fødselsnummer:", data.fødselsnummer),
        ("Saksnummer:", data.saksnummer),
    ))

    // Sammendrag med informasjon om hver meldeperiode
    #block(below: space-26)[
        #stack(
            dir: ttb,
            spacing: space-9,
            ..data.meldeperioder.map(mp => {
                if mp.korrigering {
                    stack(
                        dir: ttb,
                        spacing: space-6,
                        brødtekst[Totalt utbetalt for perioden #mp.periode.fraOgMed - #mp.periode.tilOgMed: *#mp.beløpDiff kroner*],
                        brødtekst[Ny beregning for perioden #mp.periode.fraOgMed - #mp.periode.tilOgMed: *#mp.beløp kroner*],
                    )
                } else {
                    brødtekst[Totalt utbetalt for perioden #mp.periode.fraOgMed - #mp.periode.tilOgMed: *#mp.beløp kroner*]
                }
            }),
        )
    ]
]

#if "brevTekst" in data and data.brevTekst != none [
    #shadowBox[
        #h3("Slik har vi vurdert saken din")
        #brødtekst[#data.brevTekst]
    ]
]

// En tabell per meldeperiode, kronologisk under hverandre
#for mp in data.meldeperioder [
    #block(below: space-26)[
        #if mp.korrigering [
            #h2[Korrigert meldekort #mp.periode.fraOgMed - #mp.periode.tilOgMed]
            #h3("Utfall av korrigeringen")
            #meldekortvedtakUtfall(mp.beløpDiff)
        ] else [
            #h2[Meldekort #mp.periode.fraOgMed - #mp.periode.tilOgMed]
        ]
        #meldekortvedtakTabell(mp)
    ]
]

#if "iverksattTidspunkt" in data and data.iverksattTidspunkt != none [
    #brødtekst[*Iverksatt:* #data.iverksattTidspunkt]
]

#block(below: space-26)[
    #if data.erAutomatiskBehandlet [
        #brødtekst[Automatisk behandlet]
    ] else [
        #brødtekst[*Saksbehandlere:* #data.beslutterNavn - #data.saksbehandlerNavn]
    ]
]

#if data.tiltak.len() > 0 [
    #block(below: space-26)[
        #h4("Tiltak")
        #stack(
            dir: ttb,
            spacing: space-6,
            ..data.tiltak.map(t => brødtekst[#t]),
        )
    ]
]

#meldekortvedtakKlagerett
#meldekortvedtakSporsmal
