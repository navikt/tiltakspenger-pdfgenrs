#import "/lib/styles.typ": *
#import "/lib/typography.typ": *

/*
Spesifikke komponentert delt mellom meldekort.typ & meldekort-en.typ
*/

// Farger hentet fra Aksel
#let meldekortFarger = (
    ikkeBesvart: (bg: rgb("#ECEEF0"), border: rgb("#AAB0BA")), /* --a-gray-100 --a-gray-400 */
    deltatt: (bg: rgb("#CCF1D6"), border: rgb("#2AA758")),/* --a-green-100 --a-green-600 */
    fravær: (bg: rgb("#FFECCC"), border: rgb("#FFAA33")),/* --a-yellow-100 --a-yellow-400 */
    mottokLønn: (bg: rgb("#FFC2C2"), border: rgb("#C30000")),/* -a-surface-danger-subtle -a-border-danger */
    ikkeTiltaksdag: (bg: rgb("#E6F0FF"), border: rgb("#0067C5")), /* --a-surface-action-subtle --a-surface-action */
)

#let meldekortStatusFarge(status) = {
    if status == "DELTATT_UTEN_LØNN_I_TILTAKET" {
        meldekortFarger.deltatt
    } else if status == "DELTATT_MED_LØNN_I_TILTAKET" {
        meldekortFarger.mottokLønn
    } else if status == "FRAVÆR_SYK" {
        meldekortFarger.fravær
    } else if status == "FRAVÆR_SYKT_BARN" {
        meldekortFarger.fravær
    } else if status == "FRAVÆR_STERKE_VELFERDSGRUNNER_ELLER_JOBBINTERVJU" {
        meldekortFarger.deltatt
    } else if status == "FRAVÆR_GODKJENT_AV_NAV" {
        meldekortFarger.deltatt
    } else if status == "FRAVÆR_ANNET" {
        meldekortFarger.mottokLønn
    } else if status == "IKKE_TILTAKSDAG" {
        meldekortFarger.ikkeTiltaksdag
    } else {
        // IKKE_BESVART og IKKE_RETT_TIL_TILTAKSPENGER
        meldekortFarger.ikkeBesvart
    }
}

#let bekreftet(content) = brødtekst[
    #text(fill: meldekortFarger.deltatt.border)[#sym.checkmark] #content
]

#let meldekortTabell(dager, labels) = table(
    columns: (35%, 65%),
    stroke: none,
    inset: space-9,
    ..dager
        .map(dag => {
            let farge = meldekortStatusFarge(dag.status)
            let label = labels.at(dag.status, default: dag.status)
            (
                table.cell(fill: farge.bg, stroke: (bottom: 1pt + farge.border))[#brødtekst[#dag.dag:]],
                table.cell(fill: farge.bg, stroke: (bottom: 1pt + farge.border))[#brødtekst[*#label*]],
            )
        })
        .flatten(),
)
