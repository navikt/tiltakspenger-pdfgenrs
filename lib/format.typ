#let månedsnavn = ("januar", "februar", "mars", "april", "mai", "juni", "juli", "august", "september", "oktober", "november", "desember")

// "2025-01-07" -> "7. januar 2025" (tilsvarer pdfgen-helperen `iso_to_long_date`)
#let langdato(iso) = {
    let deler = iso.slice(0, 10).split("-")
    str(int(deler.at(2))) + ". " + månedsnavn.at(int(deler.at(1)) - 1) + " " + deler.at(0)
}

// "2025-01-07T12:30:00" -> "07.01.2025 12:30" (tilsvarer pdfgen-helperen `iso_to_nor_datetime`)
#let norDatoTid(iso) = {
    let dato = iso.slice(0, 10).split("-")
    dato.at(2) + "." + dato.at(1) + "." + dato.at(0) + " " + iso.slice(11, 16)
}

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
