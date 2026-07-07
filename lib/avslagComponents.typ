#import "/lib/typography.typ": *
#import "/lib/styles.typ": *

#let barnetillegg(medBarn) = if medBarn { " og barnetillegg" } else { "" }

// Enkeltgrunn (kun én avslagsgrunn): full brødtekst med hjemler.
#let avslagsgrunnEnkelt(grunn, data) = {
    let medBarn = data.harSøktMedBarn
    let barn = barnetillegg(medBarn)
    let fom = data.avslagFraOgMed
    let tom = data.avslagTilOgMed

    if grunn == "DELTAR_IKKE_PÅ_ARBEIDSMARKEDSTILTAK" {
        brødtekst[Du får ikke tiltakspenger#barn fra og med #fom til og med #tom fordi du ikke deltar på arbeidsmarkedstiltak som gir rett til tiltakspenger.]
        if medBarn {
            brødtekst[For å få tiltakspenger og barnetillegg må du delta i arbeidsmarkedstiltak som gir rett til tiltakspenger og barnetillegg.]
            brødtekst[Dette kommer frem av arbeidsmarkedsloven § 13, tiltakspengeforskriften §§ 2 og 3.]
        } else {
            brødtekst[For å få tiltakspenger må du delta i arbeidsmarkedstiltak som gir rett til tiltakspenger.]
            brødtekst[Dette kommer frem av arbeidsmarkedsloven § 13 og tiltakspengeforskriften § 2.]
        }
    } else if grunn == "ALDER" {
        brødtekst[Du får ikke tiltakspenger#barn fra og med #fom til og med #tom fordi du ikke har fylt 18 år. Du må ha fylt 18 år for å ha rett til å få tiltakspenger#barn.]
        brødtekst[Det kommer frem av tiltakspengeforskriften § 3.]
    } else if grunn == "LIVSOPPHOLDYTELSE" {
        brødtekst[Du får ikke tiltakspenger#barn fra og med #fom til og med #tom fordi du mottar en annen pengestøtte til livsopphold. Deltakere som har rett til andre pengestøtter til livsopphold har ikke samtidig rett til å få tiltakspenger#barn.]
        brødtekst[Dette kommer frem av arbeidsmarkedsloven § 13 første ledd og forskrift om tiltakspenger § 7.]
    } else if grunn == "KVALIFISERINGSPROGRAMMET" {
        brødtekst[Du får ikke tiltakspenger#barn fra og med #fom til og med #tom fordi du deltar på kvalifiseringsprogram. Deltakere i kvalifiseringsprogram, har ikke rett til tiltakspenger#barn.]
        brødtekst[Dette kommer frem av tiltakspengeforskriften § 7 tredje ledd.]
    } else if grunn == "INTRODUKSJONSPROGRAMMET" {
        brødtekst[Du får ikke tiltakspenger#barn fra og med #fom til og med #tom fordi du deltar på introduksjonsprogram. Deltakere i introduksjonsprogram, har ikke rett til tiltakspenger#barn.]
        brødtekst[Dette kommer frem av tiltakspengeforskriften § 7 tredje ledd.]
    } else if grunn == "LØNN_FRA_TILTAKSARRANGØR" {
        brødtekst[Du får ikke tiltakspenger#barn fra og med #fom til og med #tom fordi du mottar lønn fra tiltaksarrangør for tiden i arbeidsmarkedstiltaket.]
        brødtekst[Deltakere som mottar lønn fra tiltaksarrangør for tid i arbeidsmarkedstiltaket har ikke rett til tiltakspenger#barn.]
        brødtekst[Dette kommer frem av tiltakspengeforskriften § 8.]
    } else if grunn == "LØNN_FRA_ANDRE" {
        brødtekst[Du får ikke tiltakspenger#barn fra og med #fom til og med #tom fordi du mottar lønn for arbeid som er en del av tiltaksdeltakelsen og du derfor har dekning av utgifter til livsopphold.]
        brødtekst[Deltaker i arbeidsmarkedstiltak som har rett til å få dekket utgifter til livsopphold på annen måte har ikke rett til tiltakspenger#barn. Lønn anses som dekning av utgifter til livsopphold på annen måte, når du får lønnen for arbeid som er en del av tiltaksdeltakelsen.]
        brødtekst[Lønn fra arbeid utenom tiltaksdeltakelsen har ikke betydning for din rett til tiltakspenger.]
        brødtekst[Dette kommer frem av arbeidsmarkedsloven § 13 og tiltakspengeforskriften § 8 andre ledd.]
    } else if grunn == "INSTITUSJONSOPPHOLD" {
        brødtekst[Du får ikke tiltakspenger#barn fra og med #fom til og med #tom fordi du oppholder deg på en institusjon med gratis opphold, mat og drikke.]
        brødtekst[Deltakere som har opphold i institusjon, med gratis opphold, mat og drikke. Under gjennomføringen av arbeidsmarkedstiltaket, har ikke rett til tiltakspenger#barn.]
        brødtekst[Det er gjort unntak for opphold i barneverns-institusjoner. Dette kommer frem av tiltakspengeforskriften § 9.]
    } else if grunn == "FREMMET_FOR_SENT" {
        brødtekst[Du får ikke tiltakspenger#barn fra og med #fom til og med #tom fordi du har søkt om tiltakspenger#barn for sent.]
        brødtekst[Tiltakspenger gis for opptil tre måneder før den måneden tiltaksdeltakeren søkte om tiltakspenger#barn.]
        brødtekst[Dette kommer frem av tiltakspengeforskriften § 11.]
    }
}

// Grunn i punktliste (flere avslagsgrunner): kortere formulering uten hjemler.
#let avslagsgrunnListe(grunn, data) = {
    let medBarn = data.harSøktMedBarn
    let barn = barnetillegg(medBarn)

    if grunn == "DELTAR_IKKE_PÅ_ARBEIDSMARKEDSTILTAK" {
        [
            #brødtekst[Du ikke deltar på arbeidsmarkedstiltak som gir rett til tiltakspenger.]
            #brødtekst[For å få tiltakspenger#barn må du delta i arbeidsmarkedstiltak som gir rett til tiltakspenger#barn.]
        ]
    } else if grunn == "ALDER" {
        [
            #brødtekst[Du ikke har fylt 18 år. Du må ha fylt 18 år for å ha rett til å få tiltakspenger.]
        ]
    } else if grunn == "LIVSOPPHOLDYTELSE" {
        [
            #brødtekst[Du mottar en annen pengestøtte til livsopphold.]
            #brødtekst[Deltakere som har rett til andre pengestøtter til livsopphold har ikke samtidig rett til å få tiltakspenger#barn.]
        ]
    } else if grunn == "KVALIFISERINGSPROGRAMMET" {
        [
            #brødtekst[Du deltar på kvalifiseringsprogram.]
            #brødtekst[Deltakere i kvalifiseringsprogram har ikke rett til tiltakspenger#barn.]
        ]
    } else if grunn == "INTRODUKSJONSPROGRAMMET" {
        [
            #brødtekst[Du deltar på introduksjonsprogram.]
            #brødtekst[Deltakere i introduksjonsprogram har ikke rett til tiltakspenger#barn.]
        ]
    } else if grunn == "LØNN_FRA_TILTAKSARRANGØR" {
        [
            #brødtekst[Du mottar lønn fra tiltaksarrangør for tiden i arbeidsmarkedstiltaket.]
            #brødtekst[Deltakere som mottar lønn fra tiltaksarrangør for tid i arbeidsmarkedstiltaket har ikke rett til tiltakspenger#barn.]
        ]
    } else if grunn == "LØNN_FRA_ANDRE" {
        [
            #brødtekst[Du mottar lønn for arbeid som er en del av tiltaksdeltakelsen og du derfor har dekning av utgifter til livsopphold.]
            #brødtekst[Deltaker i arbeidsmarkedstiltak som har rett til å få dekket utgifter til livsopphold på annen måte har ikke rett til tiltakspenger#barn. Lønn anses som dekning av utgifter til livsopphold på annen måte, når du får lønnen for arbeid som er en del av tiltaksdeltakelsen.]
            #brødtekst[Lønn fra arbeid utenom tiltaksdeltakelsen har ikke betydning for din rett til tiltakspenger.]
        ]
    } else if grunn == "INSTITUSJONSOPPHOLD" {
        [
            #brødtekst[Du oppholder deg på en institusjon med gratis opphold, mat og drikke.]
            #brødtekst[Deltakere som har opphold i institusjon, med gratis opphold, mat og drikke under gjennomføringen av arbeidsmarkedstiltaket, har ikke rett til tiltakspenger#barn.]
        ]
    } else if grunn == "FREMMET_FOR_SENT" {
        [
            #brødtekst[Du har søkt om tiltakspenger#barn for sent.]
            #brødtekst[Tiltakspenger gis for opptil tre måneder før den måneden tiltaksdeltakeren søkte om tiltakspenger#barn.]
        ]
    }
}

// Rendrer avslagsgrunnene: én enkeltgrunn med hjemler, eller punktliste med felles hjemler.
#let avslagsgrunner(data) = {
    let grunner = data.avslagsgrunner
    let barn = barnetillegg(data.harSøktMedBarn)

    if grunner.len() == 1 {
        avslagsgrunnEnkelt(grunner.at(0), data)
    } else if grunner.len() > 1 {
        brødtekst[Du får ikke tiltakspenger#barn fra og med #data.avslagFraOgMed til og med #data.avslagTilOgMed fordi:]
        block(below: space-16)[
            #list(
                ..grunner.map(grunn => avslagsgrunnListe(grunn, data)),
            )
        ]
        brødtekst[#data.hjemlerTekst]
    }
}
