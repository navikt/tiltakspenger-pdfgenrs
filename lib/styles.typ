/*
   Stylingene her følger navs rettningslinjer for brev
   https://aksel.nav.no/god-praksis/artikler/visuelle-retningslinjer-for-brev
*/

// Spacing (baseline 16px)
#let space-6 = 4.5pt // 6px
#let space-9 = 6.75pt // 9px
#let space-11 = 8.25pt // 11px
#let space-12 = 9pt // 12px
#let space-13 = 9.75pt // 13px
#let space-16 = 12pt // 16px
#let space-20 = 15pt // 20px
#let space-26 = 19.5pt // 26px
#let space-32 = 24pt // 32px
#let space-40 = 30pt // 40px
#let space-48 = 36pt // 48px
#let space-64 = 48pt // 64px
#let space-74 = 55.5pt // 74px
#let space-128 = 96pt // 128px

#let h1-style = (size: space-16, weight: "bold", tracking: 0.3pt)
#let h2-style = (size: space-13, weight: "bold", tracking: 0.25pt)
#let h3-style = (size: space-12, weight: "bold", tracking: 0.2pt)
#let h4-style = (size: space-11, weight: "bold", tracking: 0.1pt)
#let brødtekst-style = (size: space-11)
#let bunntekst-style = (size: space-9)

/*
Linjehøyde i aksel er ikke akkurat det samme som leading i typst.
For å finne riktig linjehøyde for hver tekst bruker vi denne formelen:
    leading = line-height - font-size
*/
#let leading-h1 = space-20 - space-16
#let leading-h2 = space-16 - space-13
#let leading-h3 = space-16 - space-12
#let leading-h4 = space-16 - space-11
#let leading-brodtekst = space-16 - space-11
#let leading-bunntekst = space-16 - space-9

#let apply-styles(body) = {
    show heading.where(level: 1): it => {
        set text(..h1-style)
        set par(leading: space-20)
        it.body
    }
    show heading.where(level: 2): it => {
        set text(..h2-style)
        set par(leading: space-16)
        it.body
    }
    show heading.where(level: 3): it => {
        set text(..h3-style)
        set par(leading: space-16)
        it.body
    }
    show heading.where(level: 4): it => {
        set text(..h4-style)
        set par(leading: space-16)
        it.body
    }
    body
}
