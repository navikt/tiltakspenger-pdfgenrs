#import "/lib/typography.typ": *
#import "/lib/styles.typ": *

// De tre seksjonene fra `innvilgelseBase.hbs` som legges mellom vedtaksinnholdet
// og den felles vedtaksinfoen (klagerett osv.).
#let meldekortinfo = body => [
    #block(below: space-26)[
        #h2("Du må sende meldekort")
        #brødtekst[Du må sende inn meldekort hver 14. dag. Logg inn på #navLenke("nav.no")[nav.no] for å se når du skal sende neste meldekort og hvilken periode meldekortet gjelder for. Du er på en ny meldekortløsning for tiltakspenger. Du finner informasjonen du trenger når du åpner det nye meldekortet. Informasjonen om utfylling av meldekort på #navLenke("nav.no")[nav.no] gjelder for den gamle løsningen og passer derfor ikke helt for ditt meldekort.]

        #brødtekst("På meldekortet må du gi oss opplysninger om hvilke dager du har deltatt i tiltaket som avtalt og hvilke avtalte tiltaksdager du har hatt fravær eller mottatt lønn. Dersom du har hatt fravær må du i tillegg oppgi grunnen til at du ikke deltok i tiltaket som avtalt. Nav trenger dette for å beregne hvor mye du skal ha i tiltakspenger.")

        #brødtekst("Du skal ikke oppgi noe for dager som ikke er en avtalt tiltaksdag.")

        #brødtekst("Du må levere meldekort hver 14. dag for å få tiltakspenger. Nav sender deg informasjon når meldekortet skal sendes inn.")

        #brødtekst("Ta kontakt med veilederen din hvis du er usikker på hva du skal føre på meldekortet.")
    ]

    #block(below: space-26)[
        #h2("Når får du pengene?")
        #brødtekst[Når du har sendt meldekortet på #navLenke("nav.no")[nav.no,] blir pengene vanligvis utbetalt til kontoen din etter to til tre virkedager. Hvis du sender meldekort i posten, kan det ta noe lengre tid. Dersom Nav trenger mer informasjon fra deg, for eksempel dokumentasjon ved sykefravær, kan det ta noe lenger tid før pengene blir utbetalt. Du skal ikke betale skatt av tiltakspengene.]

        #brødtekst[Du kan se alle utbetalingene dine på #navLenke("nav.no/minside")[nav.no/minside.] Der kan du også endre kontonummer. Hvis du har reservert deg mot digital kommunikasjon fra det offentlige, får du utbetalingsmelding i posten.]

        #brødtekst("Du kan også melde fra om endring i kontonummer via post.")

        #brødtekst[Les mer om utbetaling på #navLenke("nav.no/utbetalinger")[nav.no/utbetalinger.]]
    ]

    #block(below: space-26)[
        #h2("Du må melde om endringer")
        #brødtekst("Det er viktig å gi Nav riktige opplysninger. Dersom det skjer endringer som kan ha betydning for dine ytelser, må du straks melde fra til Nav.")

        #brødtekst("Du må melde fra til Nav hvis:")
        #list(
            [Du ikke lenger deltar i tiltaket.],
            [Du får en annen pengestøtte.],
            [Du deltar i kommunens kvalifiseringsprogram eller introduksjonsprogram.],
            [Du bor på en institusjon med gratis opphold, mat og drikke når du deltar i et arbeidsmarkedstiltak.],
            [Du har andre opplysninger som kan bety noe for retten til tiltakspenger.],
        )

        #brødtekst("Ta kontakt med oss hvis det har skjedd endringer som du er usikker på om du må melde fra om.")

        #brødtekst("Hvis du har fått utbetalt for mye fordi du ikke har meldt fra om endringer i din livssituasjon, må du vanligvis betale tilbake pengene. Det er derfor viktig at du selv følger med på utbetalinger fra Nav og melder fra om eventuelle feil.")

        #brødtekst[Hvis du flytter og endrer adresse kan du endre dette på #navLenke("skatteetaten.no/person/folkeregister")[skatteetaten.no/person/folkeregister.]]
    ]
    #body
]

// Perioder for tiltakspenger. `medBegrunnelse` legger til "fordi du deltar på
// arbeidsmarkedstiltak." i enkeltperiode-varianten (søknadsinnvilgelse).
#let innvilgelsesperioder(data, medBegrunnelse) = {
    let perioder = data.innvilgelsesperioder.perioder
    let dagerTekst = if "antallDagerTekst" in data.innvilgelsesperioder and data.innvilgelsesperioder.antallDagerTekst != none {
        [ for #data.innvilgelsesperioder.antallDagerTekst per uke]
    } else { [] }

    if perioder.len() == 1 {
        brødtekst[Du får tiltakspenger fra og med #perioder.at(0).fraOgMed til og med #perioder.at(0).tilOgMed#dagerTekst#if medBegrunnelse [ fordi du deltar på arbeidsmarkedstiltak].]
    } else if perioder.len() > 1 {
        brødtekst[Du får tiltakspenger#dagerTekst i disse periodene:]
        block(below: space-16)[
            #list(..perioder.map(p => [Fra og med #p.fraOgMed til og med #p.tilOgMed.]))
        ]
    }
}

#let barnetilleggPerioder(data) = {
    if "barnetillegg" not in data { return }
    let bt = data.barnetillegg
    if bt.len() == 1 {
        brødtekst[Du får barnetillegg fra og med #bt.at(0).periode.fraOgMed til og med #bt.at(0).periode.tilOgMed for #bt.at(0).antallBarnTekst barn.]
    } else if bt.len() > 1 {
        brødtekst[Du får barnetillegg i disse periodene:]
        block(below: space-16)[
            #list(..bt.map(b => [Fra og med #b.periode.fraOgMed til og med #b.periode.tilOgMed for #b.antallBarnTekst barn.]))
        ]
    }
}
