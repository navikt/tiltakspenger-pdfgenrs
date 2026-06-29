#import "/templates/tpts/lib/styles.typ": *

#let h1(content) = block(below: space-26)[
    #text(..h1-style)[#content]
]

#let h2(content) = block(below: space-6)[
    #text(..h2-style)[#content]
]

#let h3(content) = block(below: space-6)[
    #text(..h3-style)[#content]
]

#let h4(content) = block(below: space-6)[
    #text(..h4-style)[#content]
]

#let brødtekst(content) = text(..brødtekst-style)[#content]
