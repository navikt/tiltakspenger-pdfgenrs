#import "/lib/mod.typ": *
#import "/lib/meldekortvedtakComponents.typ": meldekortvedtakKlagerett, meldekortvedtakSporsmal, meldekortvedtakUtfall
#import "/lib/utbetalingsvedtakComponents.typ": *

#let data = json("/data/tpts/utbetalingsvedtak.json")
#show: apply-styles
#show: page-setup(data)

#let title = if data.korrigering { "Korrigert utbetalingsvedtak" } else { "Utbetalingsvedtak" }
#show: dokument(title)

#block(below: space-26, width: 100%)[
    #senterlogo

    = #title

    #brødtekst[*Fødselsnummer:* #data.fødselsnummer]
    #brødtekst[*Saksnummer:* #data.saksnummer]
]

#block(below: space-26)[
    #brødtekst[
        Totalt utbetalt for perioden
        #if "meldekortPeriode" in data and data.meldekortPeriode != none [
            #data.meldekortPeriode.fom - #data.meldekortPeriode.tom
        ] else [
            #placeholder[beregningsperiode finnes ikke]
        ]:
        #if "totaltBelop" in data and data.totaltBelop != none [
            *#data.totaltBelop kroner*
        ] else [
            #placeholder[totalsbeløp finnes ikke]
        ]
    ]
]

#if "brevTekst" in data and data.brevTekst != none [
    #block(fill: none, stroke: 3pt + uv-endret-fill, inset: space-16, below: space-26)[
        #h3("Slik har vi vurdert saken din")
        #brødtekst[#data.brevTekst]
    ]
]

#if "sammenligningAvBeregninger" in data and data.sammenligningAvBeregninger != none [
    #let sammenligning = data.sammenligningAvBeregninger
    #if data.korrigering [
        #h3("Utfall av korrigeringen")
        #meldekortvedtakUtfall(sammenligning.totalDifferanse)
    ]
    #for mp in sammenligning.meldeperioder [
        #block(below: space-26)[
            #h2[#mp.tittel]
            #uv-tabell(mp)
        ]
    ]
] else [
    #placeholder[Beregning finnes ikke]
]

#if "iverksattTidspunkt" in data and data.iverksattTidspunkt != none [
    #brødtekst[*Iverksatt:* #data.iverksattTidspunkt]
]

#let harBeslutter = "beslutter" in data and data.beslutter != none
#let harSaksbehandler = "saksbehandler" in data and data.saksbehandler != none

#block(below: space-26)[
    #if harBeslutter [
        #if data.beslutter.type == "MANUELL" [
            #brødtekst[*Saksbehandlere:* #data.beslutter.navn - #if harSaksbehandler and data.saksbehandler.type == "MANUELL" [#data.saksbehandler.navn] else [#placeholder[ingen saksbehandler tildelt]]]
        ] else [
            #if harSaksbehandler [
                #if data.saksbehandler.type == "MANUELL" [
                    #brødtekst[*Saksbehandlere:* #placeholder[ingen beslutter tildelt] - #data.saksbehandler.navn]
                ] else if data.saksbehandler.type == "AUTOMATISK" and data.beslutter.type == "AUTOMATISK" [
                    #brødtekst[Automatisk behandlet]
                ]
            ]
        ]
    ] else if harSaksbehandler and data.saksbehandler.type == "MANUELL" [
        #brødtekst[*Saksbehandlere:* #placeholder[ingen beslutter tildelt] - #data.saksbehandler.navn]
    ]
]

#if "tiltak" in data and data.tiltak.len() > 0 [
    #block(below: space-26)[
        #h4("Tiltak")
        #stack(
            dir: ttb,
            spacing: space-6,
            ..data.tiltak.map(t => brødtekst[#t.tiltakstypenavn]),
        )
    ]
]

#meldekortvedtakKlagerett
#meldekortvedtakSporsmal
