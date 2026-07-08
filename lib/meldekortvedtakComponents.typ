#import "/lib/styles.typ": *
#import "/lib/typography.typ": *

/*
Komponenter for utbetalingsvedtak (meldekortvedtak) med støtte for flere
meldeperioder i én behandling, samt korrigeringer.
*/

// --a-surface-subtle, brukt for å markere endrede dager ved korrigering
#let mv-endret-fill = rgb("#F2F3F5")
#let mv-stroke = (bottom: 0.5pt + black)

// En dag skal kun markeres som endret ved korrigering, og aldri når den
// korrigeres til "Ikke besvart"/"Ikke tiltaksdag".
#let mv-skal-markeres(dag, korrigering) = {
    korrigering and dag.harEndring and dag.status.gjeldende != "Ikke besvart" and dag.status.gjeldende != "Ikke tiltaksdag"
}

#let mv-forrige-og-gjeldende(felt, suffix) = brødtekst[#felt.forrige#suffix #h(space-9) *#felt.gjeldende#suffix*]

#let mv-dag-celler(dag, korrigering, harBarnetillegg) = {
    let endret = mv-skal-markeres(dag, korrigering)
    let fyll = if endret { mv-endret-fill } else { none }
    let c(body) = table.cell(fill: fyll, stroke: mv-stroke)[#body]

    let celler = ()

    // Blyantikon vises kun når statusen faktisk er endret
    celler.push(c(
        if endret and dag.status.harEndring [
            #image("/resources/pencil.svg", height: space-11, alt: "Korrigert")
        ] else []
    ))

    celler.push(c(brødtekst[#dag.dato]))

    // Status: forrige verdi og korrigert (gjeldende) verdi i hver sin kolonne
    if endret and dag.status.harEndring {
        celler.push(c(brødtekst[#dag.status.forrige]))
        celler.push(c(brødtekst[*#dag.status.gjeldende*]))
    } else {
        celler.push(c(brødtekst[#dag.status.gjeldende]))
        celler.push(c[])
    }

    // Beløp
    if endret and dag.beløp.harEndring {
        celler.push(c(mv-forrige-og-gjeldende(dag.beløp, "")))
    } else {
        celler.push(c(brødtekst[#dag.beløp.gjeldende]))
    }

    // Barnetillegg (kun når meldeperioden har barnetillegg)
    if harBarnetillegg {
        if endret and dag.barnetillegg.harEndring {
            celler.push(c(mv-forrige-og-gjeldende(dag.barnetillegg, "")))
        } else {
            celler.push(c(brødtekst[#dag.barnetillegg.gjeldende]))
        }
    }

    // Prosent
    if endret and dag.prosent.harEndring {
        celler.push(c(mv-forrige-og-gjeldende(dag.prosent, "%")))
    } else {
        celler.push(c(brødtekst[#dag.prosent.gjeldende%]))
    }

    celler
}

#let meldekortvedtakTabell(meldeperiode) = {
    let korrigering = meldeperiode.korrigering
    let harBarnetillegg = meldeperiode.harBarnetillegg

    let cols = (auto, 1fr, auto, auto, auto)
    if harBarnetillegg { cols.push(auto) }
    cols.push(auto)

    let hdr(body) = table.cell(stroke: mv-stroke)[#brødtekst[*#body*]]
    let header = (
        hdr[],
        hdr[Dato],
        hdr[Status],
        hdr[#if korrigering [Korrigert] else []],
        hdr[Beløp],
    )
    if harBarnetillegg { header.push(hdr[Barnetillegg]) }
    header.push(hdr[Prosent])

    table(
        columns: cols,
        align: left + horizon,
        stroke: none,
        inset: (x: space-6, y: space-9),
        table.header(..header),
        ..meldeperiode.dager.map(dag => mv-dag-celler(dag, korrigering, harBarnetillegg)).flatten(),
    )
}

// Saksbehandlere: beslutter - saksbehandler, med rød placeholder når navn mangler
#let mv-navn(navn, manglerTekst) = if navn != none [#navn] else [#placeholder(manglerTekst)]

#let meldekortvedtakSaksbehandlere(data) = brødtekst[*Saksbehandlere:* #mv-navn(data.beslutterNavn, "ingen beslutter tildelt") - #mv-navn(data.saksbehandlerNavn, "ingen saksbehandler tildelt")]

// Utfall av korrigeringen: Resultat - Økning/Reduksjon/Ingen endring - beløp
#let meldekortvedtakUtfall(beløpDiff) = block(below: space-26)[
    #grid(
        columns: (auto, 1fr, auto),
        column-gutter: space-32,
        brødtekst[Resultat],
        brødtekst[#if beløpDiff > 0 [Økning] else if beløpDiff < 0 [Reduksjon] else [Ingen endring]],
        brødtekst[#beløpDiff kroner],
    )
    #line(length: 100%, stroke: 1.5pt + mv-endret-fill)
]

#let meldekortvedtakKlagerett = block(below: space-26)[
    #h2("Du har rett til å klage")
    #brødtekst("Hvis du mener vedtaket er feil, kan du klage innen 6 uker fra den datoen vedtaket har kommet fram til deg. Dette følger av arbeidsmarkedsloven § 17. Du finner skjema og informasjon på nav.no/klage.")

    #brødtekst("Nav kan veilede deg på telefon om hvordan du sender en klage. Nav-kontoret ditt kan også hjelpe deg med å skrive en klage.")

    #brødtekst("Hvis du får medhold i klagen, kan du få dekket vesentlige utgifter som har vært nødvendige for å få endret vedtaket, for eksempel hjelp fra advokat. Du kan ha krav på fri rettshjelp etter rettshjelploven. Du kan få mer informasjon om denne ordningen hos advokater, statsforvalteren, eller Nav.")

    #brødtekst("Du kan lese om saksomkostninger i forvaltningsloven § 36.")

    #brødtekst("Hvis du sender klage i posten, må du signere klagen.")

    #brødtekst("Mer informasjon om klagerettigheter finner du på nav.no/klagerettigheter.")
]

#let meldekortvedtakSporsmal = block(below: space-32)[
    #h2("Har du spørsmål?")
    #brødtekst("Du finner mer informasjon om tiltakspenger på nav.no/tiltakspenger. På nav.no/kontakt kan du chatte eller skrive til oss. Hvis du ikke finner svar på nav.no kan du ringe oss på telefon 55 55 33 33, hverdager 09.00-15.00.")
]
