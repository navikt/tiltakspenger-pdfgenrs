#import "/lib/mod.typ": *

#let data = json("/data/tpts/vedtakInnvilgelse.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Vedtaksbrev for Tiltakspenger"
#show: dokument(title)
#show: innholdsheader(data)

= Du har fått innvilget tiltakspenger

#h2("Vedtak")
#innvilgelsesperioder(data, true)

#barnetilleggPerioder(data)

#brødtekst[#data.satser.map(s => [Tiltakspengene for #s.år er #kroner(s.ordinær) kroner per dag.]).join([ ])]

#if data.harBarnetillegg [
    #brødtekst[#data.satser.map(s => [Barnetillegget for #s.år er #kroner(s.barnetillegg) kroner per barn, per dag.]).join([ ])]
]

#brødtekst[For å få tiltakspenger må du gjennomføre avtalt aktivitet og delta hele den avtalte tiden i tiltaket ditt.]

#brødtekst[Du har ikke rett på tiltakspenger de dagene du ikke gjennomfører avtalt aktivitet, eller de dagene du har lønnet arbeid som en del av oppfølgingen i tiltaket ditt.]

#block(above: space-26, below: space-26)[
#if "tilleggstekst" in data and data.tilleggstekst != none and data.tilleggstekst != "" [
    #block(above: space-26, below: space-6)[
        #h2("Slik har vi vurdert saken din")
    ]
    #brødtekst[#data.tilleggstekst.split("\n").join(linebreak())]
]

#brødtekst[Vedtaket er gjort etter arbeidsmarkedsloven § 13 første ledd og tiltakspengeforskriften §§ 2, 3 og 6.]
]

#show: meldekortinfo
#show: vedtaksinfo
#show: signatur(data)
