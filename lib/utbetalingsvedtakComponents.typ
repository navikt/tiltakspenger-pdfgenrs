#import "/lib/styles.typ": *
#import "/lib/typography.typ": *

/*
Komponenter for utbetalingsvedtak (V1) — én meldekortperiode per behandling,
med støtte for korrigering (forrige/gjeldende-verdier og blyantikon).
*/

// --a-surface-subtle, brukt for å markere endrede dager ved korrigering
#let uv-endret-fill = rgb("#F2F3F5")
#let uv-stroke = (bottom: 1pt + black)

#let uv-forrige-og-gjeldende(felt, suffix) = [#felt.forrige#suffix #h(space-9) *#felt.gjeldende#suffix*]

#let uv-dag-rad(dag, harBarnetillegg) = {
    let endret = dag.harEndretSeg
    let fyll = if endret { uv-endret-fill } else { none }
    let c(body) = table.cell(fill: fyll, stroke: uv-stroke)[#body]
    let ct(body) = table.cell(fill: fyll, stroke: uv-stroke)[#brødtekst[#body]]

    let celler = ()

    celler.push(c(
        if dag.status.harEndretSeg [
            #image("/resources/pencil.svg", height: space-11, alt: "Korrigert")
        ] else []
    ))

    celler.push(ct[#dag.dato])

    if dag.status.harEndretSeg {
        celler.push(ct[#dag.status.forrige])
        celler.push(ct[*#dag.status.gjeldende*])
    } else {
        celler.push(ct[#dag.status.gjeldende])
        celler.push(ct[])
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

#let uv-tabell(meldeperiode) = {
    let harBarnetillegg = meldeperiode.harBarnetillegg

    let cols = (auto, 1fr, auto, auto, auto)
    if harBarnetillegg { cols.push(auto) }
    cols.push(auto)

    let hdr(body) = table.cell(stroke: uv-stroke)[#brødtekst[*#body*]]
    let header = (
        hdr[],
        hdr[Dato],
        hdr[Status],
        hdr[],
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
        ..meldeperiode.dager.map(dag => uv-dag-rad(dag, harBarnetillegg)).flatten(),
    )
}
