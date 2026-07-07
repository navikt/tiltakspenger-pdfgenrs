#import "/lib/styles.typ": *
#import "/lib/typography.typ": *

/*
Spesifikke komponentert delt mellom meldekort.typ & meldekort-en.typ
*/

// Statuslabels delt mellom meldekort.typ & meldekort-korrigert.typ
#let meldekortLabelsNo = (
    "DELTATT_UTEN_LØNN_I_TILTAKET": "Har deltatt",
    "DELTATT_MED_LØNN_I_TILTAKET": "Mottok lønn",
    "FRAVÆR_SYK": "Syk",
    "FRAVÆR_SYKT_BARN": "Sykt barn eller syk barnepasser",
    "FRAVÆR_STERKE_VELFERDSGRUNNER_ELLER_JOBBINTERVJU": "Sterke velferdsgrunner eller jobbintervju",
    "FRAVÆR_GODKJENT_AV_NAV": "Fravær godkjent av Nav",
    "FRAVÆR_ANNET": "Annet fravær",
    "IKKE_TILTAKSDAG": "Ikke tiltaksdag",
    "IKKE_RETT_TIL_TILTAKSPENGER": "Ikke rett til tiltakspenger",
    "IKKE_BESVART": "Ikke besvart",
)

// Statuslabels delt mellom meldekort-en.typ & meldekort-korrigert-en.typ
#let meldekortLabelsEn = (
    "DELTATT_UTEN_LØNN_I_TILTAKET": "Participated",
    "DELTATT_MED_LØNN_I_TILTAKET": "Received pay",
    "FRAVÆR_SYK": "Sick",
    "FRAVÆR_SYKT_BARN": "Sick child or sick child carer",
    "FRAVÆR_STERKE_VELFERDSGRUNNER_ELLER_JOBBINTERVJU": "Strong welfare reasons or job interview",
    "FRAVÆR_GODKJENT_AV_NAV": "Absence approved by Nav",
    "FRAVÆR_ANNET": "Other absence",
    "IKKE_TILTAKSDAG": "No employment scheme activity",
    "IKKE_RETT_TIL_TILTAKSPENGER": "Not entitled",
    "IKKE_BESVART": "No report",
)

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
