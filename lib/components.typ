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

// Logo: venstrestilt, 16pt høy (én linje i baselinegrid) og 48pt luft under (Aksel)
#let brevlogo = block(below: space-48)[
    #image("/resources/img.png", height: space-16, alt: "NAV logo")
]

// Ren tekst i grid-cellene: brødtekst (withSpacing) er for flyt-avsnitt og skal ikke brukes i celler (jf. casedetails.typ i lib/pensjonsbrev).
#let personalia(data) = body => {
    block(below: space-48)[
        #stack(
            dir: ltr,
            grid(
                columns: (20%, 1fr),
                gutter: 0.5em,
                [Navn:], [#data.personalia.fornavn #data.personalia.etternavn],
                [Fødselsnummer:], [#data.personalia.ident],
                [Saksnummer:], [#data.saksnummer],
            ),
            [#align(right + bottom)[#data.datoForUtsending]],
        )
    ]
    body
}

#let innholdsheader(data) = body => {
    [
        #brevlogo
        #show: personalia(data)
        #body
    ]
}

/*
Personinfo for innsendte dokumenter (meldekort/søknad): samme layout som utgående brev (personalia), men med mottatt-tidspunkt der utgående har utsendingsdato.
Labels er parametre siden innsendte dokumenter også finnes på engelsk.
*/
#let personaliaInnsendt(rader, mottatt) = block(below: space-48)[
    #stack(
        dir: ltr,
        grid(
            columns: (auto, 1fr),
            gutter: 0.5em,
            ..rader.map(((label, verdi)) => ([#label], [#verdi])).flatten(),
        ),
    )
    #align(right + bottom)[#mottatt]
]


/*
Felles hale for alle utgående vedtaksbrev — skal være identisk fra og med «Du har rett til å klage».
Tekstene er fasit fra pdfgen (partials/klagerett.hbs, base.hbs og partials/sporsmal.hbs).
*/
#let vedtaksinfo = body => [
    #block(below: space-26)[
        #h2("Du har rett til å klage")
        #brødtekst("Hvis du mener vedtaket er feil, kan du klage innen 6 uker fra den datoen vedtaket har kommet fram til deg. Dette følger av arbeidsmarkedsloven § 17. Du finner skjema og informasjon på nav.no/klage.")

        #brødtekst("Nav kan veilede deg på telefon om hvordan du sender en klage. Nav-kontoret ditt kan også hjelpe deg med å skrive en klage.")

        #brødtekst("Hvis du får medhold i klagen, kan du få dekket vesentlige utgifter som har vært nødvendige for å få endret vedtaket, for eksempel hjelp fra advokat. Du kan ha krav på fri rettshjelp etter rettshjelploven. Du kan få mer informasjon om denne ordningen hos advokater, statsforvalteren, eller Nav.")

        #brødtekst("Du kan lese om saksomkostninger i forvaltningsloven § 36.")

        #brødtekst("Hvis du sender klage i posten, må du signere klagen.")

        #brødtekst("Mer informasjon om klagerettigheter finner du på nav.no/klagerettigheter.")
    ]

    #block(below: space-26)[
        #h2("Du har rett til innsyn")
        #brødtekst("Du har rett til å se dokumentene i saken din. Dette følger av forvaltningsloven § 18. Du kan kontakte saksbehandler på nav.no eller på telefon om du vil se dokumentene i saken din. Du kan lese mer om innsynsretten på nav.no/personvernerklaering.")
    ]

    #block(below: space-26)[
        #h2("Du har rettigheter knyttet til personopplysningene dine")
        #brødtekst("Du finner informasjon om hvordan Nav behandler personopplysningene dine, og hvilke rettigheter du har, på nav.no/personvernerklaering#hvordan.")
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


/*
Felles signatur for alle utgående brev.
Avstandene følger closing.typ i lib/pensjonsbrev (13pt mellom hilsen og navn, 26pt før kontor), med 32pt luft før og 40pt etter signaturen.
Beslutter er nullable og vises kun når den finnes — da til venstre, med saksbehandler til høyre.
*/
#let signatur-navn(navn) = if navn != none [#navn] else [#placeholder("ingen saksbehandler tildelt")]

// Tomme/blanke navn regnes som manglende, slik Handlebars' {{#if}} gjorde i gammel pdfgen.
#let navn-eller-none(navn) = if navn == none or (type(navn) == str and navn.trim() == "") { none } else { navn }

// Avsenderenheten er hardkodet fordi kun ett kontor behandler tiltakspengesaker.
#let avsenderenhet = "Nav Tiltak Oslo"

#let signatur(data) = body => {
    let beslutterNavn = navn-eller-none(data.at("beslutterNavn", default: none))
    let saksbehandlerNavn = navn-eller-none(data.at("saksbehandlerNavn", default: none))

    block(above: space-32, below: space-40)[
        Med vennlig hilsen
        #block(above: 13pt)[
            #if beslutterNavn != none [
                #grid(
                    columns: (1fr, 1fr),
                    [#beslutterNavn], [#signatur-navn(saksbehandlerNavn)],
                )
            ] else [
                #signatur-navn(saksbehandlerNavn)
            ]
        ]
        // Aksel krever avsenderenhet i alle signerte brev
        #block(above: space-26)[#avsenderenhet]
    ]
    body
}


#let shadowBox(body) = block(
    fill: surface-subtle,
    inset: space-16,
    below: space-26,
)[#body]


#let nøkkelinfo(items) = block(below: space-26)[
    #stack(
        dir: ttb,
        spacing: space-6,
        ..items.map(((label, value)) => [*#label* #value]),
    )
]