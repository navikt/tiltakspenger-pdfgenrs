#import "/lib/styles.typ": *
#import "/lib/pensjonsbrev/template.typ": mainTitle
#import "/lib/pensjonsbrev/content/title.typ": title1, title2, title3
#import "/lib/pensjonsbrev/content/paragraph.typ": paragraph

/*
Overskrifter og brødtekst delegerer til det vendorerte oppsettet i lib/pensjonsbrev/, som også styrer vertikal avstand mellom elementer via kollisjonsmatrisen i content/spacing.typ.
Ikke redefiner størrelser eller avstander her — endringer skal skje oppstrøms.
*/
#let h1(content) = mainTitle(content)
#let h2(content) = title1(content)
#let h3(content) = title2(content)
#let h4(content) = title3(content)
#let brødtekst(content) = paragraph(content)

// Bunntekst brukes av fallback-footeren for dokumenter uten saksnummer (samme 9pt som footer.typ)
#let bunntekst(content) = box[
    #text(size: 9pt)[#content]
]

#let navLenke(path, content) = link(path)[
    #set text(fill: rgb("#005bb6"))
    #content
]

// Rød markør for manglende data, kun ment å være synlig i utvikling/forhåndsvisning
#let placeholder(t) = text(fill: red)[#t]
