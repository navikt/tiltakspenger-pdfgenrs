// Formaterer et heltall som norsk beløp uten desimaler, med hardt mellomrom
// som tusenskille (tilsvarer pdfgen-helperen `currency_no <n> true`).
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
