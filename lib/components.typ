#import "/lib/typography.typ": *
#import "/lib/styles.typ": *

#let dokument(title, lang: "no") = body => {
    set document(
        title: title,
        description: title,
        author: "Team tiltakspenger",
    )
    set text(lang: lang)
    body
}

#let senterlogo = align(center)[
    #image("/resources/img.png", height: space-16, alt: "NAV logo")
]

#let personalia(data) = body => {
    block(below: space-48)[
        #stack(
            dir: ltr,
            grid(
                columns: (20%, 1fr),
                gutter: 0.5em,
                [#brødtekst[Navn:]], [#brødtekst[#data.personalia.fornavn #data.personalia.etternavn]],
                [#brødtekst[Fødselsnummer:]], [#brødtekst[#data.personalia.ident]],
                [#brødtekst[Saksnummer:]], [#brødtekst[#data.saksnummer]],
            ),
            [#align(right + bottom)[#brødtekst[#data.datoForUtsending]]],
        )
    ]
    body
}

#let innholdsheader(data) = body => {
    [
        #block(below: space-48)[
            #image(
                "/resources/img.png",
                height: space-16,
                alt: "NAV logo",
            )
        ]
        #show: personalia(data)
        #body
    ]
}


#let vedtaksinfo = body => [
    #block(below: space-26)[
        #h2("Du har rett til å klage")
        #brødtekst("Hvis du mener vedtaket er feil, kan du klage innen 6 uker fra den datoen vedtaket har kommet fram til deg. Dette følger av arbeidsmarkedsloven § 17. Du finner skjema og informasjon på nav.no/klage.")

        #brødtekst("Nav kan veilede deg på telefon om hvordan du sender en klage. Nav-kontoret ditt kan også hjelpe deg med å skrive en klage.")

        #brødtekst("Hvis du får medhold i klagen, kan du få dekket vesentlige utgifter som har vært nødvendige for å få endret vedtaket, for eksempel hjelp fra advokat. Du kan ha krav på fri rettshjelp etter rettshjelploven. Du kan få mer informasjon om denne ordningen hos advokater, statsforvalteren, eller Nav.")

        #brødtekst("Du kan lese om saksomkostninger i forvaltningsloven § 36.")

        #brødtekst("Hvis du sender klage i posten, må du signere klagen.")

        #brødtekst("Mer informasjon om klagerettigheter finner du på nav.no")
    ]

    #block(below: space-26)[
        #h2("Du har rettigheter knyttet til personopplysningene dine")
        #brødtekst("Du har rett til å se dokumentene i saken din. Dette følger av forvaltningsloven § 18. Du kan kontakte saksbehandler på nav.no eller på telefon om du vil se dokumentene i saken din. Du kan lese mer om innsynsretten på nav.no/personvernerklaering.")

        #brødtekst("Nav kan veilede deg på telefon om hvordan du sender en klage. Nav-kontoret ditt kan også hjelpe deg med å skrive en klage.")
    ]

    #block(below: space-26)[
        #h2("Du har rett til å få veiledning fra Nav")
        #brødtekst("Vi har plikt til å veilede deg om dine rettigheter og plikter i saken din, både før, under og etter saksbehandlingen. Dette følger av forvaltningsloven § 11.")
    ]

    #block(below: space-32)[
        #h2("Har du spørsmål?")
        #brødtekst("Du finner mer informasjon om tiltakspenger på nav.no/tiltakspenger. På nav.no/kontakt kan du chatte eller skrive til oss. Hvis du ikke finner svar på nav.no kan du ringe oss på telefon 55 55 33 33, hverdager 09.00-15.00.")
    ]
    #body
]


#let signatur(data) = body => {
    let finnesBeslutter = "beslutterNavn" in data

    block(below: space-40)[
        #stack(
            spacing: 3pt,
            brødtekst("Med vennlig hilsen"),
            grid(
                columns: if finnesBeslutter { (1fr, 1fr) } else { 1fr },
                [#if finnesBeslutter [#brødtekst[#data.beslutterNavn]]], [#brødtekst[#data.saksbehandlerNavn]],
            ),
        )
        #if "kontor" in data [#brødtekst[#data.kontor]]
    ]
    body
}


#let shadowBox(body) = block(
    fill: rgb("#F2F3F5"),
    inset: space-16,
    below: space-26,
)[#body]


#let nøkkelinfo(items) = block(below: space-26)[
    #stack(
        dir: ttb,
        spacing: space-6,
        ..items.map(((label, value)) => brødtekst[*#label* #value]),
    )
]