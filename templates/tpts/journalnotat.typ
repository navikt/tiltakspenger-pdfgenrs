#import "/lib/mod.typ": *

/*
Internt notat om et vedtak om tiltakspenger, journalført som NOTAT i Joark.
Notatet sendes ikke til bruker, men er synlig for Nav-ansatte i Gosys.
Det er ikke et brev, og har derfor verken klagerett-hale eller signatur.
Vedtakstype og periode står i vedtaksbrevet, som også er journalført, og gjentas derfor ikke her.
Notatet kan ha flere begrunnelser (f.eks. for vilkårsvurderingen og for barnetillegg), hver med overskrift ut fra typen og en skillelinje mellom.
Tittelen er den samme som journalposten får i Joark (JOURNALNOTAT_TITTEL i tiltakspenger-saksbehandling-api).
Payload-kontrakt: JournalnotatDokumentDto i tiltakspenger-saksbehandling-api.
*/

#let data = json("/data/tpts/journalnotat.json")
#let tittel = "Notat om vedtak om tiltakspenger"
#show: apply-styles
#show: page-setup(data)

#show: dokument(tittel)

#brevlogo

#personaliaInnsendt(
    (
        ("Navn:", data.personalia.fornavn + " " + data.personalia.etternavn),
        ("Fødselsnummer:", data.personalia.ident),
        ("Saksnummer:", data.saksnummer),
    ),
    [Notatsdato: #data.notatsdato],
)

= #tittel

#nøkkelinfo((
    ("Saksbehandler:", data.saksbehandlerNavn),
    ("Beslutter:", data.beslutterNavn),
))

// Overskriften for hver begrunnelse settes her ut fra typen, så saksbehandling-api sender bare typen og teksten.
#let begrunnelsestitler = (
    VILKÅRSVURDERING: "Begrunnelse for vilkårsvurderingen",
    BARNETILLEGG: "Begrunnelse for barnetillegg",
    MELDEKORT: "Begrunnelse",
)

// Det gamle formatet med én begrunnelse og ferdig tittel kan fjernes når saksbehandling-api sender begrunnelser.
#let begrunnelser = if "begrunnelser" in data {
    data.begrunnelser.map(b => {
        if b.type not in begrunnelsestitler { panic("Ukjent begrunnelsestype: " + b.type) }
        (tittel: begrunnelsestitler.at(b.type), tekst: b.begrunnelse)
    })
} else {
    ((tittel: data.begrunnelseTittel, tekst: data.begrunnelse),)
}

#for (i, begrunnelse) in begrunnelser.enumerate() {
    if i > 0 {
        block(below: space-26, line(length: 100%, stroke: 1pt + border-divider))
    }
    block(below: space-26)[
        #h2(begrunnelse.tittel)
        #brødtekst[#begrunnelse.tekst.split("\n").join(linebreak())]
    ]
}
