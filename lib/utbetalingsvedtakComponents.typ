#import "/lib/styles.typ": *
#import "/lib/typography.typ": *
#import "/lib/spraak.typ": språkinnstillinger-nb
#import "/lib/pensjonsbrev/content/table.typ": letter-table

/*
Komponenter for utbetalingsvedtak (V1) — én meldekortperiode per behandling, med støtte for korrigering (forrige/gjeldende-verdier og blyantikon).
*/


#let uv-forrige-og-gjeldende(felt, suffix) = [#felt.forrige#suffix #h(space-6) *#felt.gjeldende#suffix*]

/*
Celleinnhold for én dag.
Tabellstilen (sebrastriper, header, linjer) kommer fra letter-table i lib/pensjonsbrev — endrede dager markeres derfor kun med blyantikon og fet korrigert verdi, ikke med egen bakgrunnsfarge.
*/
#let uv-dag-rad(dag, korrigering, harBarnetillegg) = {
    let c(body) = body
    let ct(body) = body

    let celler = ()

    // Ikon- og Korrigert-kolonnene finnes kun i korrigeringstabeller
    if korrigering {
        celler.push(c(
            if dag.status.harEndretSeg [
                #image("/resources/pencil.svg", height: space-11, alt: "Korrigert")
            ] else []
        ))
    }

    celler.push(ct[#dag.dato])

    // Forrige/gjeldende i hver sin kolonne finnes kun i korrigeringstabeller (som har Korrigert-kolonnen)
    if korrigering and dag.status.harEndretSeg {
        celler.push(ct[#dag.status.forrige])
        celler.push(ct[*#dag.status.gjeldende*])
    } else {
        celler.push(ct[#dag.status.gjeldende])
        if korrigering { celler.push(ct[]) }
    }

    if dag.beløp.harEndretSeg {
        celler.push(ct(uv-forrige-og-gjeldende(dag.beløp, "")))
    } else {
        celler.push(ct[#dag.beløp.gjeldende])
    }

    if harBarnetillegg {
        if dag.barnetillegg.harEndretSeg {
            celler.push(ct(uv-forrige-og-gjeldende(dag.barnetillegg, "")))
        } else {
            celler.push(ct[#dag.barnetillegg.gjeldende])
        }
    }

    if dag.prosent.harEndretSeg {
        celler.push(ct(uv-forrige-og-gjeldende(dag.prosent, "%")))
    } else {
        celler.push(ct[#dag.prosent.gjeldende%])
    }

    celler
}

#let uv-tabell(meldeperiode, korrigering) = {
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
        ..meldeperiode.dager.map(dag => uv-dag-rad(dag, korrigering, harBarnetillegg)).flatten(),
    )
}
