#import "/lib/mod.typ": *

#let data = json("/data/tpts/vedtakForlengelse.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Vedtaksbrev for Tiltakspenger"
#show: dokument(title)
#show: innholdsheader(data)

= Tiltakspengene dine er forlenget

#brødtekst[Tiltaket ditt er forlenget. Vi forlenger derfor vedtaket ditt om tiltakspenger#if data.harBarnetillegg [ og barnetillegg].]

#innvilgelsesperioder(data, false)

// Barn som fyller 16 år i forlengelsen, slik at barnetillegget stopper for dem.
// Samme tekster som fritekst ved automatisk forlengelse i tiltakspenger-saksbehandling-api.
#let barnSomFyller16 = data.at("barnSomFyller16", default: none)
#if barnSomFyller16 != none {
    if barnSomFyller16.antallBarnIVedtaket == 1 {
        brødtekst[Du er innvilget barnetillegg til og med #dato(barnSomFyller16.sisteDagMedBarnetillegg) fordi du ikke har rett til barnetillegg for barn over 16 år. Vi viser til forskriften om tiltakspenger § 3.]
    } else if barnSomFyller16.antall == 1 {
        brødtekst[Barnetillegg gis for hvert barn under 16 år. Ett av dine barn fyller 16 år i tiltaksperioden. Barnetillegget for dette barnet vil derfor stoppe fra den dagen barnet ditt fyller 16 år. Vi viser til forskriften om tiltakspenger § 3.]
    } else {
        let antall = tallSomOrd(barnSomFyller16.antall)
        brødtekst[Barnetillegg gis for hvert barn under 16 år. #(upper(antall.first()) + antall.slice(antall.first().len())) av dine barn fyller 16 år i tiltaksperioden. Barnetillegget for disse barna vil derfor stoppe fra den dagen hvert av barna fyller 16 år. Vi viser til forskriften om tiltakspenger § 3.]
    }
}

#barnetilleggPerioder(data)

#brødtekst[#data.satser.map(s => [Tiltakspengene for #s.år er #kroner(s.ordinær) kroner per dag du deltar i arbeidsmarkedstiltak.]).join([ ])]

#if data.harBarnetillegg [
    #brødtekst[#data.satser.map(s => [Barnetillegget for #s.år er #kroner(s.barnetillegg) kroner per barn per dag du deltar i arbeidsmarkedstiltak.]).join([ ])]
]

#brødtekst[For å få tiltakspenger må du gjennomføre avtalt aktivitet og delta hele den avtalte tiden i tiltaket ditt.]

#brødtekst[Du har ikke rett til tiltakspenger de dagene du ikke gjennomfører avtalt aktivitet, eller de dagene du har lønnet arbeid som en del av oppfølgingen i tiltaket ditt.]

#block(above: space-26, below: space-26)[
#if "tilleggstekst" in data and data.tilleggstekst != none and data.tilleggstekst != "" [
    #block(above: space-26, below: space-6)[
        #h2("Vurderingen vår")
    ]
    #brødtekst[#data.tilleggstekst.split("\n").join(linebreak())]
]

#brødtekst[Vedtaket er gjort etter arbeidsmarkedsloven § 13 første ledd og tiltakspengeforskriften §§ 2, 3 og 6.]
]

#show: meldekortinfo
#show: vedtaksinfo
#show: signatur(data)
