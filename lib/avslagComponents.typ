#import "/lib/typography.typ": *
#import "/lib/styles.typ": *
#import "/lib/hjemmeltekster.typ": *
#import "/lib/format.typ": dato

// Faktum i halvfet, regelen rett under i vanlig skrift; blokken deles ikke over sideskift.
#let grunnblokk(begrunnelse) = block(breakable: false)[
    #strong(begrunnelse.faktum + ".")#linebreak()#begrunnelse.forklaring.first()
    #for avsnitt in begrunnelse.forklaring.slice(1) {
        block(above: space-12, below: 0pt, avsnitt)
    }
]

// Én grunn står i konklusjonen etter «fordi»; flere grunner står som punktliste etter «Grunnene er:».
#let avslagsgrunner(data) = {
    assert(data.at("avslagsgrunner", default: ()).len() > 0, message: "Avslagsbrevet mangler avslagsgrunner")
    assert(data.at("hjemler", default: ()).len() > 0, message: "Avslagsbrevet mangler hjemler")
    let ytelse = ytelsen(data.harSøktMedBarn)
    let periode = [fra og med #dato(data.avslagFraOgMed) til og med #dato(data.avslagTilOgMed)]
    let tidligereInnvilgelse = data.at("tidligereInnvilgelse", default: none)
    let begrunnelser = data.avslagsgrunner.map(grunn => avslagsbegrunnelse(grunn, data.harSøktMedBarn, tidligereInnvilgelse: tidligereInnvilgelse))
    if begrunnelser.len() == 1 {
        let begrunnelse = begrunnelser.first()
        brødtekst[Du får ikke #ytelse #periode fordi #begrunnelse.fordi.]
        for avsnitt in begrunnelse.forklaring { brødtekst(avsnitt) }
    } else {
        // Konklusjonen følger første punkt over sideskift, og ekstra luft under listen skiller hjemmelsetningen fra siste punkt.
        block(sticky: true, brødtekst[Du får ikke #ytelse #periode.#linebreak()Grunnene er:])
        block(below: space-26)[
            #list(spacing: space-20, ..begrunnelser.map(grunnblokk))
        ]
    }
    brødtekst[#hjemmelsetning(data.hjemler)]
}

// Avslaget har sin egen første del når eneste grunn er at brukeren allerede er innvilget tiltakspenger.
// Kombinert med andre grunner står den i punktlisten i `avslagsgrunner` som før.
#let erAlleredeInnvilget(data) = data.at("avslagsgrunner", default: ()) == ("INNVILGET_TILTAKSPENGER",)

// Første del av avslagsbrevet når brukeren allerede er innvilget tiltakspenger for perioden.
// Resten av brevet er likt de andre avslagsbrevene.
// `tidligereInnvilgelse` er none når søknadsperioden ikke er lik hele perioden i ett innvilget vedtak.
// Da vises avslagsperioden uten tiltak og vedtaksdato, og saksbehandler skriver detaljene i tilleggsteksten.
// Ett tiltak står i setningen, flere tiltak står som punktliste etter setningen.
// `tidligereInnvilgelse.tiltak` mangler i payload fra før saksbehandling-api sendte tiltakene, og da utelates tiltaket.
#let alleredeInnvilget(data) = {
    assert(data.at("hjemler", default: ()).len() > 0, message: "Avslagsbrevet mangler hjemler")
    let tidligereInnvilgelse = data.at("tidligereInnvilgelse", default: none)
    if tidligereInnvilgelse == none {
        brødtekst[Du har allerede fått innvilget tiltakspenger for hele eller deler av perioden fra og med #dato(data.avslagFraOgMed) til og med #dato(data.avslagTilOgMed), og vi avslår derfor søknaden din.]
        brødtekst[Utbetalingene dine følger det som allerede er innvilget.]
    } else {
        let vedtaksdato = dato(tidligereInnvilgelse.vedtaksdato)
        let periodeOgVedtak = [for perioden fra og med #dato(tidligereInnvilgelse.fraOgMed) til og med #dato(tidligereInnvilgelse.tilOgMed) i vedtak av #vedtaksdato]
        let tiltak = tidligereInnvilgelse.at("tiltak", default: ())
        if tiltak.len() > 1 {
            brødtekst[Du er allerede innvilget tiltakspenger #periodeOgVedtak fordi du deltar på tiltakene:]
            list(..tiltak.map(navn => [#navn]))
        } else if tiltak.len() == 1 {
            brødtekst[Du er allerede innvilget tiltakspenger #periodeOgVedtak fordi du deltar på #tiltak.first().]
        } else {
            brødtekst[Du er allerede innvilget tiltakspenger #periodeOgVedtak.]
        }
        brødtekst[Vi har derfor avslått søknaden din.]
        brødtekst[Du vil motta #ytelsen(tidligereInnvilgelse.harBarnetillegg) i henhold til vedtaket om tiltakspenger av #vedtaksdato.]
    }
    brødtekst[#hjemmelsetning(data.hjemler)]
}
