/*
Språktekster som de vendorerte komponentene i lib/pensjonsbrev/ trenger (footer.typ og content/table.typ).
Verdiene er hentet fra oppstrøms LanguageSettings.kt slik at tekstene blir identiske.
Kun nøklene vi faktisk bruker er tatt med.
*/

#let språkinnstillinger-nb = (
    saksnummerprefix: "Saksnummer:",
    sideprefix: "side",
    sideinfix: "av",
    tablecontinuedfrompreviouspage: "Fortsettelse fra forrige side",
    tablenextpagecontinuation: "Tabellen fortsetter på neste side",
)

#let språkinnstillinger-en = (
    saksnummerprefix: "Case number:",
    sideprefix: "page",
    sideinfix: "of",
    tablecontinuedfrompreviouspage: "Continuation from previous page",
    tablenextpagecontinuation: "Continued on next page",
)

#let språkinnstillinger(lang) = if lang == "en" { språkinnstillinger-en } else { språkinnstillinger-nb }
