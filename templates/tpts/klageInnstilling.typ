#import "/lib/mod.typ": *

#let data = json("/data/tpts/klageInnstilling.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Opprettholdelsesbrev Tiltakspenger"

#set document(
    title: title,
    description: title,
    author: "Team tiltakspenger",
)

#show: innholdsheader(data)

#block(below: space-26)[
    = Klage - Tiltakspenger
    #brødtekst[
        Vi viser til din klage av #data.innsendingsdato på vedtak av #data.vedtaksdato.
    ]

    #brødtekst[
        Vi har vurdert vedtaket vårt på nytt, men har ikke endret det.
    ]

    #brødtekst[
        Klagesaken er derfor oversendt til Nav Klageinstans for behandling. Kopi av innstillingen vår er vedlagt.
    ]


    #brødtekst[
        Klageinstansen vurderer alle sider av saken på selvstendig grunnlag. Resultatet av klagebehandlingen kan bli at vårt vedtak ikke blir endret, eller at det blir endret helt eller delvis. Klageinstansen kan også oppheve vedtaket vårt, og sende saken tilbake til oss for helt eller delvis ny behandling.
    ]


    #brødtekst[
        Du får melding fra Nav Klageinstans når de har mottatt saken.
    ]


    #brødtekst[
        Du finner oversikt over saksbehandlingstidene på nav.no/saksbehandlingstider. Du får beskjed fra Nav Klageinstans, dersom de trenger mer tid.
    ]


    #brødtekst[
        Du kan sende merknader og dokumentasjon til Nav Klageinstans. Du kan logge deg inn på nav.no/kontakt og sende skriftlig melding der. Hvis du ønsker å ettersende dokumentasjon, kan du gå til nav.no/klage og trykke på "Ettersend dokumentasjon" for det saken gjelder.
    ]
]

#block(below: space-32)[
    == Har du spørsmål?
    #brødtekst[
        Du finner mer informasjon på #navLenke("nav.no")[nav.no]
    ]

    #brødtekst[
        På nav.no/kontakt kan du chatte eller skrive til oss.
    ]

    #brødtekst[
        Hvis du ikke finner svar på nav.no, kan du ringe oss på telefon 55 55 33 33, hverdager 09.00-15.00.
    ]
]

#show: signatur(data)
