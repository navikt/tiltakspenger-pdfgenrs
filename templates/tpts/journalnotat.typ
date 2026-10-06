#import "/lib/mod.typ": *

/*
Internt notat om et vedtak om tiltakspenger, journalført som NOTAT i Joark.
Notatet sendes ikke til bruker, men er synlig for Nav-ansatte i Gosys.
Det er ikke et brev, og har derfor verken klagerett-hale eller signatur.
Vedtakstype og periode står i vedtaksbrevet, som også er journalført, og gjentas derfor ikke her.
Payload-kontrakt: JournalnotatDokumentDto i tiltakspenger-saksbehandling-api.
*/

#let data = json("/data/tpts/journalnotat.json")
#show: apply-styles
#show: page-setup(data)

#show: dokument(data.tittel)

#brevlogo

#personaliaInnsendt(
    (
        ("Navn:", data.personalia.fornavn + " " + data.personalia.etternavn),
        ("Fødselsnummer:", data.personalia.ident),
        ("Saksnummer:", data.saksnummer),
    ),
    [Notatsdato: #data.notatsdato],
)

= #data.tittel

#nøkkelinfo((
    ("Saksbehandler:", data.saksbehandlerNavn),
    ("Beslutter:", data.beslutterNavn),
))

#block(below: space-26)[
    #h2(data.begrunnelseTittel)
    #brødtekst[#data.begrunnelse.split("\n").join(linebreak())]
]
