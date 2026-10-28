#let månedsnavn = ("januar", "februar", "mars", "april", "mai", "juni", "juli", "august", "september", "oktober", "november", "desember")

// "2025-01-07" -> "7. januar 2025" (tilsvarer pdfgen-helperen `iso_to_long_date`)
#let norskLangdato(iso) = {
    let deler = iso.slice(0, 10).split("-")
    str(int(deler.at(2))) + ". " + månedsnavn.at(int(deler.at(1)) - 1) + " " + deler.at(0)
}


// Datoene fra saksbehandling-api, formatert som `norskDatoFormatter` og `norskUkedagOgDatoUtenÅrFormatter` i tiltakspenger-libs.
// Overgang: saksbehandling-api sender fortsatt ferdigformatert tekst som slipper uendret gjennom, og grenen fjernes når saksbehandling-api bare sender ISO.
#let ukedager = ("mandag", "tirsdag", "onsdag", "torsdag", "fredag", "lørdag", "søndag")

#let erIsoDato(verdi) = verdi.match(regex("^\d{4}-\d{2}-\d{2}")) != none

// "2024-10-15" og "15.10.2024 13:05" (fra meldekort-api) -> "2024-10-15"; annen tekst gir none.
#let isoDato(verdi) = if erIsoDato(verdi) {
    verdi.slice(0, 10)
} else if verdi.match(regex("^\d{2}\.\d{2}\.\d{4}")) != none {
    let deler = verdi.slice(0, 10).split(".")
    deler.at(2) + "-" + deler.at(1) + "-" + deler.at(0)
}

#let engelskeMånedsnavn = ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")

// "2024-11-04" og "04.11.2024 13:05" -> "4. november 2024"
#let dato(verdi) = if isoDato(verdi) != none { norskLangdato(isoDato(verdi)) } else { verdi }

// "2024-11-04" og "04.11.2024 13:05" -> "4 November 2024", som `engelskDatoFormatter` i tiltakspenger-libs.
#let engelskDato(verdi) = if isoDato(verdi) != none {
    let deler = isoDato(verdi).split("-")
    str(int(deler.at(2))) + " " + engelskeMånedsnavn.at(int(deler.at(1)) - 1) + " " + deler.at(0)
} else { verdi }

// "2024-11-04" -> "mandag 4. november"
#let ukedagOgDato(verdi) = if erIsoDato(verdi) {
    let deler = verdi.slice(0, 10).split("-").map(int)
    let ukedag = datetime(year: deler.at(0), month: deler.at(1), day: deler.at(2)).weekday()
    ukedager.at(ukedag - 1) + " " + str(deler.at(2)) + ". " + månedsnavn.at(deler.at(1) - 1)
} else { verdi }

// Mottakstidspunktet for innsendte dokumenter etter Navs skriveregel: "2025-01-05T12:30:15" og "05.01.2025 12:30" -> "5. januar 2025 kl. 12.30".
#let klokkeslett(verdi) = { let treff = verdi.match(regex("\d{2}:\d{2}")); if treff != none { treff.text } }
#let tidspunkt(verdi) = dato(verdi) + if klokkeslett(verdi) != none { " kl. " + klokkeslett(verdi).replace(":", ".") }
#let engelskTidspunkt(verdi) = engelskDato(verdi) + if klokkeslett(verdi) != none { " at " + klokkeslett(verdi) }

// Formaterer et heltall som norsk beløp uten desimaler, med hardt mellomrom som tusenskille (tilsvarer pdfgen-helperen `currency_no <n> true`).
#let kroner(n) = {
    let verdi = int(n)
    let s = str(calc.abs(verdi))
    let chars = s.clusters()
    let total = chars.len()
    let result = ""
    for (i, c) in chars.enumerate() {
        let posFromRight = total - i
        result += c
        if posFromRight > 1 and calc.rem(posFromRight - 1, 3) == 0 {
            result += "\u{00A0}"
        }
    }
    if verdi < 0 { "−" + result } else { result }
}

// Tall fra 1 til 15 skrives med bokstaver, større tall med sifre, som `toTekst` i tiltakspenger-saksbehandling-api.
// https://sprakradet.no/godt-og-korrekt-sprak/rettskriving-og-grammatikk/tall-tid-dato/
#let tallSomOrd(tall) = if tall >= 1 and tall <= 15 {
    ("ett", "to", "tre", "fire", "fem", "seks", "syv", "åtte", "ni", "ti", "elleve", "tolv", "tretten", "fjorten", "femten").at(tall - 1)
} else { str(tall) }
