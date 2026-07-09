#import "/lib/styles.typ": *
#import "/lib/typography.typ": *
#import "/lib/spraak.typ": språkinnstillinger-nb
#import "/lib/pensjonsbrev/content/table.typ": letter-table

/*
Komponenter for utbetalingsvedtak (meldekortvedtak) med støtte for flere meldeperioder i én behandling, samt korrigeringer.
*/


// En dag skal kun markeres som endret ved korrigering, og aldri når den korrigeres til "Ikke besvart"/"Ikke tiltaksdag".
#let mv-skal-markeres(dag, korrigering) = {
    korrigering and dag.harEndring and dag.status.gjeldende != "Ikke besvart" and dag.status.gjeldende != "Ikke tiltaksdag"
}

#let mv-forrige-og-gjeldende(felt, suffix) = [#felt.forrige#suffix #h(space-6) *#felt.gjeldende#suffix*]

/*
Celleinnhold for én dag.
Tabellstilen (sebrastriper, header, linjer) kommer fra letter-table i lib/pensjonsbrev — endrede dager markeres derfor kun med blyantikon og fet korrigert verdi, ikke med egen bakgrunnsfarge.
*/
#let mv-dag-celler(dag, korrigering, harBarnetillegg) = {
    let endret = mv-skal-markeres(dag, korrigering)

    let celler = ()

    // Ikon- og Korrigert-kolonnene finnes kun i korrigeringstabeller
    if korrigering {
        // Blyantikon vises kun når statusen faktisk er endret
        celler.push(
            if endret and dag.status.harEndring [
                #image("/resources/pencil.svg", height: space-11, alt: "Korrigert")
            ] else []
        )
    }

    celler.push([#dag.dato])

    // Status: forrige verdi og korrigert (gjeldende) verdi i hver sin kolonne
    if endret and dag.status.harEndring {
        celler.push([#dag.status.forrige])
        celler.push([*#dag.status.gjeldende*])
    } else {
        celler.push([#dag.status.gjeldende])
        if korrigering { celler.push([]) }
    }

    // Beløp
    if endret and dag.beløp.harEndring {
        celler.push(mv-forrige-og-gjeldende(dag.beløp, ""))
    } else {
        celler.push([#dag.beløp.gjeldende])
    }

    // Barnetillegg (kun når meldeperioden har barnetillegg)
    if harBarnetillegg {
        if endret and dag.barnetillegg.harEndring {
            celler.push(mv-forrige-og-gjeldende(dag.barnetillegg, ""))
        } else {
            celler.push([#dag.barnetillegg.gjeldende])
        }
    }

    // Prosent
    if endret and dag.prosent.harEndring {
        celler.push(mv-forrige-og-gjeldende(dag.prosent, "%"))
    } else {
        celler.push([#dag.prosent.gjeldende%])
    }

    celler
}

#let meldekortvedtakTabell(meldeperiode) = {
    let korrigering = meldeperiode.korrigering
    let harBarnetillegg = meldeperiode.harBarnetillegg

    // Alle kolonner sizes etter innhold; ikon- og Korrigert-kolonnene finnes kun ved korrigering
    let cols = if korrigering { (auto, auto, auto, auto, auto) } else { (auto, auto, auto) }
    if harBarnetillegg { cols.push(auto) }
    cols.push(auto)

    let header = if korrigering {
        ([], [Dato], [Status], [Korrigert], [Beløp])
    } else {
        ([Dato], [Status], [Beløp])
    }
    if harBarnetillegg { header.push([Barnetillegg]) }
    header.push([Prosent])

    letter-table(
        språkinnstillinger-nb,
        column-align: left + horizon,
        columns: cols,
        ..header,
        ..meldeperiode.dager.map(dag => mv-dag-celler(dag, korrigering, harBarnetillegg)).flatten(),
    )
}

// Utfall av korrigeringen: Resultat - Økning/Reduksjon/Ingen endring - beløp
#let meldekortvedtakUtfall(beløpDiff) = block(below: space-26)[
    #grid(
        columns: (auto, 1fr, auto),
        column-gutter: space-32,
        [Resultat],
        [#if beløpDiff > 0 [Økning] else if beløpDiff < 0 [Reduksjon] else [Ingen endring]],
        [#beløpDiff kroner],
    )
    #line(length: 100%, stroke: 1.5pt + surface-subtle)
]
