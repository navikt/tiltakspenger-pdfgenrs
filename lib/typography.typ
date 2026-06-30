#import "/lib/styles.typ": *

#let h1(content) = block(below: space-26)[
    #set par(leading: leading-h1)
    #text(..h1-style)[#content]
]

#let h2(content) = block(below: space-6)[
    #set par(leading: leading-h2)
    #text(..h2-style)[#content]
]

#let h3(content) = block(below: space-6)[
    #set par(leading: leading-h3)
    #text(..h3-style)[#content]
]

#let h4(content) = block(below: space-6)[
    #set par(leading: leading-h4)
    #text(..h4-style)[#content]
]

#let brødtekst(content) = par(leading: leading-brodtekst)[
    #text(..brødtekst-style)[#content]
]

#let bunntekst(content) = box[
    #set par(leading: leading-bunntekst)
    #text(..bunntekst-style)[#content]
]