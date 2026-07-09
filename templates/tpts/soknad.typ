#import "/lib/mod.typ": *

/*
Innsendt digital søknad om tiltakspenger, generert for journalføring.
Payload-kontrakt: Søknad/SpørsmålsbesvarelserDTO i tiltakspenger-soknad-api.
Innholdet er 1-til-1 med pdfgen-malen (soknad.hbs).
*/

#let data = json("/data/tpts/soknad.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Søknad om tiltakspenger"
#show: dokument(title)

#let spm = data.spørsmålsbesvarelser

// Nullable booleans (f.eks. jobbsjansen.mottar) skal kun regnes som ja når de er true
#let erJa(verdi) = verdi == true

#let seksjon(tittel, body) = block(below: space-26)[
    #h2(tittel)
    #body
]

#let jaNei(cond, ja, nei) = brødtekst[#if cond [#ja] else [#nei]]

#let periodetekst(periode) = [#langdato(periode.fra) - #langdato(periode.til)]

#let barnenavn(barn) = {
    let deler = (barn.at("fornavn", default: none), barn.at("mellomnavn", default: none), barn.at("etternavn", default: none))
    deler.filter(d => d != none and d != "").join(" ")
}

#let barneoppføring(tittel, barn) = [
    #brødtekst[#tittel]
    #list(
        if barn.oppholdInnenforEøs [
            #brødtekst[Ja, barnet oppholder seg i Norge eller et annet EØS-land i tiltaksperioden]
        ] else [
            #brødtekst[Nei, barnet oppholder seg ikke i Norge eller et annet EØS-land i tiltaksperioden]
        ],
    )
]

#brevlogo

#personaliaInnsendt(
    (
        ("Navn:", data.personopplysninger.fornavn + " " + data.personopplysninger.etternavn),
        ("Fødselsnummer:", data.personopplysninger.ident),
    ),
    [Sendt til Nav: #norDatoTid(data.innsendingTidspunkt)],
)

= #title

#seksjon("Perioden du søker tiltakspenger for")[
    #brødtekst[#periodetekst(spm.tiltak.periode)]
]

#seksjon("Kvalifiseringsstønad")[
    #if spm.kvalifiseringsprogram.deltar [
        #brødtekst[Ja, jeg mottar kvalifiseringsstønad i perioden #periodetekst(spm.kvalifiseringsprogram.periode)]
    ] else [
        #brødtekst[Nei, jeg mottar ikke kvalifiseringsstønad i perioden jeg deltar på tiltaket]
    ]
]

#seksjon("Introduksjonsstønad")[
    #if spm.introduksjonsprogram.deltar [
        #brødtekst[Ja, jeg mottar introduksjonsstønad i perioden #periodetekst(spm.introduksjonsprogram.periode)]
    ] else [
        #brødtekst[Nei, jeg mottar ikke introduksjonsstønad i perioden jeg deltar på tiltaket]
    ]
]

#seksjon("Institusjonsopphold")[
    #if spm.institusjonsopphold.borPåInstitusjon [
        #brødtekst[Ja, jeg bor på institusjon med fri kost og losji i perioden #periodetekst(spm.institusjonsopphold.periode)]
    ] else [
        #brødtekst[Nei, jeg bor ikke på institusjon med fri kost og losji i perioden jeg deltar på tiltaket]
    ]
]

#seksjon("Tiltak")[
    #if spm.tiltak.at("visningsnavn", default: none) != none [
        #brødtekst[#spm.tiltak.visningsnavn]
    ] else if spm.tiltak.at("arrangør", default: "") != "" [
        #brødtekst[#spm.tiltak.typeNavn - #spm.tiltak.arrangør]
    ] else [
        #brødtekst[#spm.tiltak.typeNavn]
    ]
    #list(
        brødtekst[Startdato *#langdato(spm.tiltak.periode.fra)* - Sluttdato *#langdato(spm.tiltak.periode.til)*],
    )
]

#seksjon("Etterlønn")[
    #jaNei(
        erJa(spm.etterlønn.mottar),
        [Ja, jeg mottar etterlønn i perioden jeg deltar på tiltaket],
        [Nei, jeg mottar ikke etterlønn i perioden jeg deltar på tiltaket],
    )
]

#seksjon("Sykepenger")[
    #if erJa(spm.sykepenger.mottar) [
        #brødtekst[Ja, jeg mottar sykepenger i perioden #periodetekst(spm.sykepenger.periode)]
    ] else [
        #brødtekst[Nei, jeg mottar ikke sykepenger i perioden jeg deltar på tiltaket]
    ]
]

#seksjon("Annen pengestøtte")[
    #jaNei(
        erJa(spm.mottarAndreUtbetalinger),
        [Ja, jeg mottar annen pengestøtte i perioden jeg går på tiltaket],
        [Nei, jeg mottar ikke annen pengestøtte i perioden jeg deltar på tiltaket],
    )
]

#seksjon("Gjenlevendepensjon og omstillingsstønad")[
    #if erJa(spm.gjenlevendepensjon.mottar) [
        #brødtekst[Ja, jeg mottar gjenlevendepensjon eller omstillingsstønad i perioden #periodetekst(spm.gjenlevendepensjon.periode)]
    ] else [
        #brødtekst[Nei, jeg mottar ikke gjenlevendepensjon eller omstillingsstønad i perioden jeg deltar på tiltaket]
    ]
]

#seksjon("Alderspensjon")[
    #if erJa(spm.alderspensjon.mottar) [
        #brødtekst[Ja, jeg mottar alderspensjon fra #langdato(spm.alderspensjon.fraDato)]
    ] else [
        #brødtekst[Nei, jeg mottar ikke alderspensjon i perioden jeg deltar på tiltaket]
    ]
]

#seksjon("Supplerende stønad for personer over 67 år")[
    #if erJa(spm.supplerendestønadover67.mottar) [
        #brødtekst[Ja, jeg mottar supplerende stønad for personer over 67 år i perioden #periodetekst(spm.supplerendestønadover67.periode)]
    ] else [
        #brødtekst[Nei, jeg mottar ikke supplerende stønad for personer over 67 år i perioden jeg deltar på tiltaket]
    ]
]

#seksjon("Supplerende stønad for uføre flyktninger")[
    #if erJa(spm.supplerendestønadflyktninger.mottar) [
        #brødtekst[Ja, jeg mottar supplerende stønad for uføre flyktninger i perioden #periodetekst(spm.supplerendestønadflyktninger.periode)]
    ] else [
        #brødtekst[Nei, jeg mottar ikke supplerende stønad for uføre flyktninger i perioden jeg deltar på tiltaket]
    ]
]

#seksjon("Pengestøtte fra andre trygde- eller pensjonsordninger")[
    #if erJa(spm.pensjonsordning.mottar) [
        #brødtekst[Ja, jeg mottar pengestøtte fra andre trygde- eller pensjonsordninger i perioden #periodetekst(spm.pensjonsordning.periode)]
    ] else [
        #brødtekst[Nei, jeg mottar ikke pengestøtte fra andre trygde- eller pensjonsordninger i perioden jeg deltar på tiltaket]
    ]
]

#seksjon("Jobbsjansen")[
    #if erJa(spm.jobbsjansen.mottar) [
        #brødtekst[Ja, jeg mottar stønad gjennom Jobbsjansen i perioden #periodetekst(spm.jobbsjansen.periode)]
    ] else [
        #brødtekst[Nei, jeg mottar ikke stønad gjennom Jobbsjansen i perioden jeg deltar på tiltaket]
    ]
]

#seksjon("Barnetillegg")[
    #let manuelleBarn = spm.barnetillegg.manueltRegistrerteBarnSøktBarnetilleggFor
    #let registrerteBarn = spm.barnetillegg.registrerteBarnSøktBarnetilleggFor

    #if manuelleBarn.len() == 0 and registrerteBarn.len() == 0 [
        #brødtekst[Jeg søker ikke om barnetillegg]
    ]
    #for barn in manuelleBarn [
        #barneoppføring([*#barnenavn(barn)* født #langdato(barn.fødselsdato)], barn)
    ]
    #for barn in registrerteBarn [
        #if barn.at("fornavn", default: none) != none [
            #barneoppføring([*#barnenavn(barn)* født #langdato(barn.fødselsdato)], barn)
        ] else [
            #barneoppføring([*Barn født #langdato(barn.fødselsdato)*], barn)
        ]
    ]
]

#seksjon("Bekreftelse")[
    #if spm.harBekreftetÅSvareSåGodtManKan [
        #brødtekst[Jeg vil svare så godt jeg kan på spørsmålene i søknaden.]
    ]
    #if spm.harBekreftetAlleOpplysninger [
        #brødtekst[Jeg har lest all informasjonen jeg har fått i søknaden og bekrefter at opplysningene jeg har gitt er korrekte.]
    ]
]

#if data.vedleggsnavn.len() > 0 [
    #seksjon("Dine opplastede vedlegg")[
        #stack(
            dir: ttb,
            spacing: space-6,
            ..data.vedleggsnavn.map(navn => brødtekst[#navn]),
        )
    ]
]
