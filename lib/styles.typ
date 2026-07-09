/*
   Typografi, avstander og tabeller kommer fra det vendorerte Typst-oppsettet i lib/pensjonsbrev/ (synkes 1-1 fra oppstrøms, se ./sync-pensjonsbrev.sh).
   Verdiene der er nyere designvalg som ennå ikke er reflektert i Aksels brev-artikkel.
   Denne fila holder kun det som er spesifikt for tiltakspenger.
*/

// Spacing brukt av malene til egen blokk-layout (1pt per «px», jf. at A4 i brev-retningslinjene er 595 × 842, altså PDF-punkter).
#let space-4 = 4pt
#let space-6 = 6pt
#let space-8 = 8pt
#let space-9 = 9pt
#let space-11 = 11pt
#let space-12 = 12pt
#let space-13 = 13pt
#let space-16 = 16pt
#let space-20 = 20pt
#let space-26 = 26pt
#let space-32 = 32pt
#let space-40 = 40pt
#let space-48 = 48pt
#let space-64 = 64pt
#let space-74 = 74pt
#let space-128 = 128pt

// --a-surface-subtle (gray-50) fra Aksel-tokens: shadowBox og «Utfall av korrigeringen»-linjen
#let surface-subtle = rgb("#F2F3F5")

#let apply-styles(body) = {
    // Typst bruker "‣"-ikon for nøstede listeelementer.
    // Denne er ikke støttet i Source Sans 3.
    // Vi bytter derfor ut med en vanlig punktliste.
    set list(marker: ([•], [–]))

    // Tekst- og avsnittsverdier fra lib/pensjonsbrev/template.typ (de er ikke eksportert som konstanter der, så de gjentas her — hold dem i synk).
    set text(size: 11pt)
    set par(leading: 8.7pt, spacing: 24pt)

    // withSpacing-blokkene i lib/pensjonsbrev slutter med `below: 0pt` og forutsetter at neste element bringer avstanden via kollisjonsmatrisen.
    // Egne blokker/stacks i malene er ikke matrix-wrappet, så de trenger en default-avstand for ikke å kollidere med foregående withSpacing-blokk.
    set block(spacing: space-16)

    // `= tittel`-markup styles likt som mainTitle i lib/pensjonsbrev.
    // Bruk h2()/h3()/h4() (title1-3 fra lib/pensjonsbrev) for underoverskrifter, ikke ==/=== — de får riktig avstand via kollisjonsmatrisen der.
    show heading.where(level: 1): set text(size: 17pt, weight: "bold", tracking: 0.32pt)
    show heading.where(level: 1): set block(above: space-48, below: 0pt)
    body
}
