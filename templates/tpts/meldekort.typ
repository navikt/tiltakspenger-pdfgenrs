#import "/lib/mod.typ": *

#let data = json("/data/tpts/meldekort.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Meldekort for tiltakspenger"
#show: dokument(title)

#let labels = meldekortLabelsNo

#block(below: space-26, width: 100%)[
    #brevlogo

    #personaliaInnsendt(
        (
            ("Fødselsnummer:", data.fnr),
            ("Saksnummer:", data.saksnummer),
            ("Meldekort-ID:", data.id),
        ),
        [Mottatt: #data.mottatt],
    )

    = #title

    #h2([#data.periode.fraOgMed - #data.periode.tilOgMed (uke #(data.uke1)-#(data.uke2))])

    #block(below: space-26)[
        #brødtekst[
            Ta kontakt med Nav hvis du er usikker på hvordan du skal fylle inn meldekortet #navLenke("nav.no/kontaktoss")[(nav.no/kontaktoss)].
        ]
        #brødtekst[
            For å få utbetalt tiltakspenger må du som deltar på tiltak hos Nav, sende meldekort hver 14. dag. Vi bruker informasjonen til å regne ut hvor mye du skal ha utbetalt i tiltakspenger. Utbetalingen skjer normalt automatisk.
        ]
        #brødtekst[
            Vi deler informasjon fra meldekortet med andre systemer i Nav fordi informasjonen har betydning for oppfølgingen du får av Nav.
        ]
        #bekreftet[Jeg bekrefter at jeg vil fylle ut meldekortet så riktig som jeg kan.]
    ]
]

#block(below: space-26)[
    #h2([Fravær])
    #brødtekst[
        Hvis du ikke har vært syk eller hatt annet fravær fra tiltaket i denne perioden, svarer du «nei». Hvis du har vært syk eller hatt annet fravær hele eller deler av dager, svarer du «ja». Deretter oppgir du hvilke dager det gjelder, og hvilken type fravær du har hatt.
    ]
    #brødtekst[*Har du vært syk eller hatt annet fravær noen av dagene du skulle vært på tiltaket?*]
    #brødtekst[Nei, jeg har ikke vært syk eller hatt annet fravær]
    #brødtekst[Ja, jeg har vært syk eller hatt annet fravær]

    #h3([Slik fyller du ut fravær])
    #brødtekst[
        Noen typer fravær gir til rett til tiltakspenger selv om du ikke har deltatt på tiltaket. Kryss av for hvilke dager det gjelder, og hvilken type fravær du har hatt.
    ]

    #shadowBox[
        #brødtekst[*Når skal du velge "syk"?*]
        - #brødtekst[Du skal velge «syk» hvis du har vært for syk til å kunne delta på tiltaksdagen. Du kan ha rett til tiltakspenger når du er syk. Det er derfor viktig at du melder om dette.]
        - #brødtekst[Du får utbetalt full stønad de 3 første dagene du er syk. Er du syk mer enn 3 dager, får du utbetalt 75 prosent av full stønad resten av arbeidsgiverperioden. En arbeidsgiverperiode er på til sammen 16 virkedager.]
        - #brødtekst[Du må ha sykmelding for å ha rett til tiltakspenger i mer enn 3 dager.]

        #brødtekst[*Når skal du velge "sykt barn eller syk barnepasser"?*]
        - #brødtekst[Du skal velge «sykt barn eller syk barnepasser» hvis du ikke kunne delta på tiltaksdagen fordi barnet ditt eller barnets barnepasser var syk.]
        - #brødtekst[Det er de samme reglene som gjelder for sykt barn/barnepasser som ved egen sykdom. Det vil si at du har rett til full utbetaling de tre første dagene og 75 prosent resten av arbeidsgiverperioden.]
        - #brødtekst[Du må sende legeerklæring for barnet ditt eller bekreftelse fra barnepasseren fra dag 4 for å ha rett til tiltakspenger i mer enn 3 dager.]

        #brødtekst[*Når skal du velge "sterke velferdsgrunner eller jobbintervju"?*]
        - #brødtekst[Du skal velge dette alternativet hvis Nav har godkjent at du har fravær fra tiltaket denne dagen på grunn av:]
            - #brødtekst[jobbintervju]
            - #brødtekst[timeavtaler i det offentlige hjelpeapparatet]
            - #brødtekst[begravelse eller bisettelse i den nærmeste familien din]
            - #brødtekst[andre sterke velferdsgrunner]
        - #brødtekst[Det er kun Nav-veilederen din som kan godkjenne fraværet, ikke tiltaksarrangøren.]

        #brødtekst[*Når skal du velge "annet fravær"?*]
        - #brødtekst[Du skal velge «annet fravær» hvis du har vært fraværende hele eller deler av den aktuelle tiltaksdagen.]
        - #brødtekst[Du skal velge «annet fravær» hvis du ikke møter opp til avtalt tiltak eller aktivitet, eller ikke gjennomfører andre aktiviteter som er avtalt med Nav.]
        - #brødtekst[Du skal velge «annet fravær» hvis du har arbeidet i stedet for å delta på tiltaket. For eksempel: Du har avtalt tiltakstid 09-15 og arbeidet fra 09-10 i stedet for å delta hele den avtalte tiden på tiltaket.]
        - #brødtekst[Du skal velge «annet fravær» hvis du har hatt fri/ferie utenom planlagt ferieperiode for tiltaket.]
        - #brødtekst[Du skal velge «annet fravær» hvis du venter på godkjenning av fravær. Du kan endre meldekortet senere når fraværet er godkjent av Nav-veilederen din.]
    ]

    #brødtekst[Velg hva slags fravær du hadde]
    - #brødtekst[*Syk:* Du var for syk til å delta på tiltaksdagen.]
    - #brødtekst[*Sykt barn eller syk barnepasser:* Du kunne ikke delta på tiltaksdagen fordi barnet ditt eller barnepasseren var syk.]
    - #brødtekst[*Sterke velferdsgrunner eller jobbintervju:* Du har hatt fravær fra tiltaket på grunn av sterke velferdsgrunner eller jobbintervju og Nav-veilederen har godkjent fraværet.]
    - #brødtekst[*Annet fravær:* Du har vært borte hele eller deler av tiltaksdagen, og fraværet er ikke godkjent av Nav. Dette gir ikke rett til tiltakspenger.]
]

#block(below: space-26)[
    #h2([Lønn])
    #brødtekst[
        Hvis du får lønn (ikke tiltakspenger) som en del av tiltaket ditt, svarer du "ja". Deretter oppgir du hvilke dager det gjelder.
    ]
    #brødtekst[*Mottar du lønn (ikke tiltakspenger) som en del av tiltaket?*]
    #brødtekst[Nei, jeg skal bare motta tiltakspenger]
    #brødtekst[Ja, jeg mottar lønn som en del av tiltaket]
    #brødtekst[Kryss av for de dagene du mottar lønn]
]

#block(below: space-26)[
    #h2([Oppmøte])
    #brødtekst[
        Kryss av for de dagene du har deltatt på tiltaket som avtalt. Kryss også av for «deltok» hvis dagen er en offentlig fridag og du ikke får deltatt fordi tiltaket er stengt.
    ]
    #brødtekst[Kryss av for de dagene du deltok på tiltaket.]
]

#block(below: space-26)[
    #h2([Oppsummering])
    #brødtekst[
        Her er en oppsummering av det du har fylt ut i meldekortet for denne perioden. Sjekk at det er korrekt før du sender inn. Du kan gå tilbake og rette opp hvis noe er feil.
    ]
]

#block(below: space-26)[
    #h3([Meldekortdager])
    #meldekortTabell(data.dager, labels)
    #bekreftet[Jeg bekrefter at disse opplysningene stemmer.]
]
