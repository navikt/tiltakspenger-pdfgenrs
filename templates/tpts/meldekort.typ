#import "/lib/mod.typ": *

#let data = json("/data/tpts/meldekort.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Meldekort for tiltakspenger"

#set document(
    title: title,
    description: title,
    author: "Team tiltakspenger",
)

// Farger hentet fra Aksel
#let ikkeBesvartFarge = (bg: rgb("#ECEEF0"), border: rgb("#AAB0BA")) /* --a-gray-100 --a-gray-400 */
#let deltattFarge = (bg: rgb("#CCF1D6"), border: rgb("#2AA758")) /* --a-green-100 --a-green-600 */
#let fraværFarge = (bg: rgb("#FFECCC"), border: rgb("#FFAA33")) /* --a-yellow-100 --a-yellow-400 */
#let mottokLønnFarge = (bg: rgb("#FFC2C2"), border: rgb("#C30000")) /* -a-surface-danger-subtle -a-border-danger */
#let ikkeTiltaksdagFarge = (
    bg: rgb("#E6F0FF"),
    border: rgb("#0067C5"),
) /* --a-surface-action-subtle --a-surface-action */

#let dagStatus(status) = {
    if status == "DELTATT_UTEN_LØNN_I_TILTAKET" {
        (farge: deltattFarge, label: "Har deltatt")
    } else if status == "DELTATT_MED_LØNN_I_TILTAKET" {
        (farge: mottokLønnFarge, label: "Mottok lønn")
    } else if status == "FRAVÆR_SYK" {
        (farge: fraværFarge, label: "Syk")
    } else if status == "FRAVÆR_SYKT_BARN" {
        (farge: fraværFarge, label: "Sykt barn eller syk barnepasser")
    } else if status == "FRAVÆR_STERKE_VELFERDSGRUNNER_ELLER_JOBBINTERVJU" {
        (farge: deltattFarge, label: "Sterke velferdsgrunner eller jobbintervju")
    } else if status == "FRAVÆR_GODKJENT_AV_NAV" {
        (farge: deltattFarge, label: "Fravær godkjent av Nav")
    } else if status == "FRAVÆR_ANNET" {
        (farge: mottokLønnFarge, label: "Annet fravær")
    } else if status == "IKKE_TILTAKSDAG" {
        (farge: ikkeTiltaksdagFarge, label: "Ikke tiltaksdag")
    } else if status == "IKKE_RETT_TIL_TILTAKSPENGER" {
        (farge: ikkeBesvartFarge, label: "Ikke rett til tiltakspenger")
    } else {
        (farge: ikkeBesvartFarge, label: "Ikke besvart")
    }
}

#let bekreftet(content) = brødtekst[#text(fill: deltattFarge.border)[#sym.checkmark] #content]

#block(below: space-26, width: 100%)[
    #align(center)[
        #image("/resources/img.png", height: space-16, alt: "NAV logo")
    ]

    = #title

    == #data.periode.fraOgMed - #data.periode.tilOgMed (uke #(data.uke1)-#(data.uke2))

    #stack(
        spacing: 3pt,
        brødtekst[*Fødselsnummer:* #data.fnr],
        brødtekst[*Saksnummer:* #data.saksnummer],
        brødtekst[*Mottatt:* #data.mottatt],
        brødtekst[*Meldekort-ID:* #data.id],
    )[
        \
        #brødtekst[
            Ta kontakt med Nav hvis du er usikker på hvordan du skal fylle inn meldekortet (nav.no/kontaktoss).
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
    == Fravær
    #brødtekst[
        Hvis du ikke har vært syk eller hatt annet fravær fra tiltaket i denne perioden, svarer du «nei». Hvis du har vært syk eller hatt annet fravær hele eller deler av dager, svarer du «ja». Deretter oppgir du hvilke dager det gjelder, og hvilken type fravær du har hatt.
    ]
    #brødtekst[*Har du vært syk eller hatt annet fravær noen av dagene du skulle vært på tiltaket?*]
    #brødtekst[Nei, jeg har ikke vært syk eller hatt annet fravær]
    #brødtekst[Ja, jeg har vært syk eller hatt annet fravær]

    === Slik fyller du ut fravær
    #brødtekst[
        Noen typer fravær gir til rett til tiltakspenger selv om du ikke har deltatt på tiltaket. Kryss av for hvilke dager det gjelder, og hvilken type fravær du har hatt.
    ]

    #block(
        fill: rgb("#F2F3F5"),
        inset: space-16,
        below: space-26,
    )[
        #brødtekst[*Når skal du velge "syk"?*]
        - Du skal velge «syk» hvis du har vært for syk til å kunne delta på tiltaksdagen. Du kan ha rett til tiltakspenger når du er syk. Det er derfor viktig at du melder om dette.
        - Du får utbetalt full stønad de 3 første dagene du er syk. Er du syk mer enn 3 dager, får du utbetalt 75 prosent av full stønad resten av arbeidsgiverperioden. En arbeidsgiverperiode er på til sammen 16 virkedager.
        - Du må ha sykmelding for å ha rett til tiltakspenger i mer enn 3 dager.

        #brødtekst[*Når skal du velge "sykt barn eller syk barnepasser"?*]
        - Du skal velge «sykt barn eller syk barnepasser» hvis du ikke kunne delta på tiltaksdagen fordi barnet ditt eller barnets barnepasser var syk.
        - Det er de samme reglene som gjelder for sykt barn/barnepasser som ved egen sykdom. Det vil si at du har rett til full utbetaling de tre første dagene og 75 prosent resten av arbeidsgiverperioden.
        - Du må sende legeerklæring for barnet ditt eller bekreftelse fra barnepasseren fra dag 4 for å ha rett til tiltakspenger i mer enn 3 dager.

        #brødtekst[*Når skal du velge "sterke velferdsgrunner eller jobbintervju"?*]
        - Du skal velge dette alternativet hvis Nav har godkjent at du har fravær fra tiltaket denne dagen på grunn av:
            - jobbintervju
            - timeavtaler i det offentlige hjelpeapparatet
            - begravelse eller bisettelse i den nærmeste familien din
            - andre sterke velferdsgrunner
        - Det er kun Nav-veilederen din som kan godkjenne fraværet, ikke tiltaksarrangøren.

        #brødtekst[*Når skal du velge "annet fravær"?*]
        - Du skal velge «annet fravær» hvis du har vært fraværende hele eller deler av den aktuelle tiltaksdagen.
        - Du skal velge «annet fravær» hvis du ikke møter opp til avtalt tiltak eller aktivitet, eller ikke gjennomfører andre aktiviteter som er avtalt med Nav.
        - Du skal velge «annet fravær» hvis du har arbeidet i stedet for å delta på tiltaket. For eksempel: Du har avtalt tiltakstid 09-15 og arbeidet fra 09-10 i stedet for å delta hele den avtalte tiden på tiltaket.
        - Du skal velge «annet fravær» hvis du har hatt fri/ferie utenom planlagt ferieperiode for tiltaket.
        - Du skal velge «annet fravær» hvis du venter på godkjenning av fravær. Du kan endre meldekortet senere når fraværet er godkjent av Nav-veilederen din.
    ]

    #brødtekst[Velg hva slags fravær du hadde]
    - *Syk:* Du var for syk til å delta på tiltaksdagen.
    - *Sykt barn eller syk barnepasser:* Du kunne ikke delta på tiltaksdagen fordi barnet ditt eller barnepasseren var syk.
    - *Sterke velferdsgrunner eller jobbintervju:* Du har hatt fravær fra tiltaket på grunn av sterke velferdsgrunner eller jobbintervju og Nav-veilederen har godkjent fraværet.
    - *Annet fravær:* Du har vært borte hele eller deler av tiltaksdagen, og fraværet er ikke godkjent av Nav. Dette gir ikke rett til tiltakspenger.
]

#block(below: space-26)[
    == Lønn
    #brødtekst[
        Hvis du får lønn (ikke tiltakspenger) som en del av tiltaket ditt, svarer du "ja". Deretter oppgir du hvilke dager det gjelder.
    ]
    #brødtekst[*Mottar du lønn (ikke tiltakspenger) som en del av tiltaket?*]
    #brødtekst[Nei, jeg skal bare motta tiltakspenger]
    #brødtekst[Ja, jeg mottar lønn som en del av tiltaket]
    #brødtekst[Kryss av for de dagene du mottar lønn]
]

#block(below: space-26)[
    == Oppmøte
    #brødtekst[
        Kryss av for de dagene du har deltatt på tiltaket som avtalt. Kryss også av for «deltok» hvis dagen er en offentlig fridag og du ikke får deltatt fordi tiltaket er stengt.
    ]
    #brødtekst[Kryss av for de dagene du deltok på tiltaket.]
]

#block(below: space-26)[
    == Oppsummering
    #brødtekst[
        Her er en oppsummering av det du har fylt ut i meldekortet for denne perioden. Sjekk at det er korrekt før du sender inn. Du kan gå tilbake og rette opp hvis noe er feil.
    ]
]

#block(below: space-26)[
    === Meldekortdager
    #table(
        columns: (35%, 65%),
        stroke: none,
        inset: space-9,
        ..data
            .dager
            .map(d => {
                let s = dagStatus(d.status)
                (
                    table.cell(fill: s.farge.bg, stroke: (bottom: 1pt + s.farge.border))[#brødtekst[#d.dag:]],
                    table.cell(fill: s.farge.bg, stroke: (bottom: 1pt + s.farge.border))[#brødtekst[*#s.label*]],
                )
            })
            .flatten()
    )
    #bekreftet[Jeg bekrefter at disse opplysningene stemmer.]
]
