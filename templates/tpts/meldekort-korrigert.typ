#import "/lib/mod.typ": *

#let data = json("/data/tpts/meldekort-korrigert.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Korrigert meldekort for tiltakspenger"
#show: dokument(title)

#let labels = meldekortLabelsNo

#block(below: space-26, width: 100%)[
    #senterlogo

    = Meldekort for tiltakspenger

    == #data.periode.fraOgMed - #data.periode.tilOgMed (uke #(data.uke1)-#(data.uke2))

    #nøkkelinfo((
        ("Fødselsnummer:", data.fnr),
        ("Saksnummer:", data.saksnummer),
        ("Mottatt:", data.mottatt),
        ("Meldekort-ID:", data.id),
    ))
]

#block(below: space-26)[
    == Endre meldekort

    #shadowBox[
        #h3("Når skal jeg velge mottatt lønn?")
        #brødtekst[Hvis du får lønn (ikke tiltakspenger) som en del av tiltaket ditt velger du "Lønn".]
    ]

    #shadowBox[
        #h3("Når skal jeg velge sykdom?")
        #brødtekst[*Syk*]
        - #brødtekst[Du skal velge «syk» hvis du har vært for syk til å kunne delta på tiltaksdagen. Du kan ha rett til tiltakspenger når du er syk. Det er derfor viktig at du melder om dette.]
        - #brødtekst[Du får utbetalt full stønad de 3 første dagene du er syk. Er du syk mer enn 3 dager, får du utbetalt 75 prosent av full stønad resten av arbeidsgiverperioden. En arbeidsgiverperiode er på til sammen 16 virkedager.]
        - #brødtekst[Du må ha sykmelding for å ha rett til tiltakspenger i mer enn 3 dager.]

        #brødtekst[*Sykt barn eller syk barnepasser*]
        - #brødtekst[Du skal velge «sykt barn eller syk barnepasser» hvis du ikke kunne delta på tiltaksdagen fordi barnet ditt eller barnets barnepasser var syk.]
        - #brødtekst[Det er de samme reglene som gjelder for sykt barn/barnepasser som ved egen sykdom. Det vil si at du har rett til full utbetaling de tre første dagene og 75 prosent resten av arbeidsgiverperioden.]
        - #brødtekst[Du må sende legeerklæring for barnet ditt eller bekreftelse fra barnepasseren fra dag 4 for å ha rett til tiltakspenger i mer enn 3 dager.]
    ]

    #shadowBox[
        #h3("Når skal jeg velge fravær?")
        #brødtekst[*Sterke velferdsgrunner eller jobbintervju*]
        - #brødtekst[Du skal velge dette alternativet hvis Nav har godkjent at du har fravær fra tiltaket denne dagen på grunn av:]
            - #brødtekst[jobbintervju]
            - #brødtekst[timeavtaler i det offentlige hjelpeapparatet]
            - #brødtekst[begravelse eller bisettelse i den nærmeste familien din]
            - #brødtekst[andre sterke velferdsgrunner]
        - #brødtekst[Det er kun Nav-veilederen din som kan godkjenne fraværet, ikke tiltaksarrangøren.]

        #brødtekst[*Annet fravær*]
        - #brødtekst[Du skal velge «annet fravær» hvis du har vært fraværende hele eller deler av den aktuelle tiltaksdagen.]
        - #brødtekst[Du skal velge «annet fravær» hvis du har arbeidet i stedet for å delta på tiltaket. For eksempel: Du har avtalt tiltakstid 09-15 og arbeidet fra 09-10 i stedet for å delta hele den avtalte tiden på tiltaket.]
        - #brødtekst[Du skal velge «annet fravær» hvis du har hatt fri/ferie utenom planlagt ferieperiode for tiltaket.]
        - #brødtekst[Du skal velge «annet fravær» hvis du venter på godkjenning av fravær. Du kan endre meldekortet senere når fraværet er godkjent av Nav-veilederen din.]
    ]
]

#block(below: space-26)[
    == Slik endrer du meldekortet
    #brødtekst[
        Nedenfor ser du hva du har tidligere registrert i meldekortet. Endre valgene på de dagene som er feilregistrert. Etter du har sendt inn endringen vil endringen saksbehandles før det eventuelt blir endringer i utbetalingen din.
    ]
]

#block(below: space-26)[
    === Oppsummering av endret meldekort
    #meldekortTabell(data.dager, labels)
    #bekreftet[Jeg bekrefter at disse opplysningene stemmer.]
]
