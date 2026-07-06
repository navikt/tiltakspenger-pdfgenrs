#import "/lib/mod.typ": *

#let data = json("/data/tpts/meldekort-en.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Employment status form for employment scheme benefits"

#set document(
    title: title,
    description: title,
    author: "Team tiltakspenger",
)
#set text(lang: "en")

#let labels = (
    "DELTATT_UTEN_LØNN_I_TILTAKET": "Participated",
    "DELTATT_MED_LØNN_I_TILTAKET": "Received pay",
    "FRAVÆR_SYK": "Sick",
    "FRAVÆR_SYKT_BARN": "Sick child or sick child carer",
    "FRAVÆR_STERKE_VELFERDSGRUNNER_ELLER_JOBBINTERVJU": "Strong welfare reasons or job interview",
    "FRAVÆR_GODKJENT_AV_NAV": "Absence approved by Nav",
    "FRAVÆR_ANNET": "Other absence",
    "IKKE_TILTAKSDAG": "No employment scheme activity",
    "IKKE_RETT_TIL_TILTAKSPENGER": "Not entitled",
    "IKKE_BESVART": "No report",
)

#block(below: space-26, width: 100%)[
    #align(center)[
        #image("/resources/img.png", height: space-16, alt: "NAV logo")
    ]

    = #title

    == #data.periode.fraOgMed - #data.periode.tilOgMed (week #(data.uke1)-#(data.uke2))

    #nøkkelinfo((
        ("Norwegian national identification number:", data.fnr),
        ("Case number:", data.saksnummer),
        ("Received:", data.mottatt),
        ("Employment status form ID:", data.id),
    ))
    #block(below: space-26)[
        #brødtekst[
            Please contact Nav if you are not sure how to fill out the employment status form #navLenke("nav.no/kontaktoss")[(nav.no/kontaktoss)].
        ]
        #brødtekst[
            To receive employment scheme benefits, all scheme participants must submit an employment status form every 14 days. We use this information to calculate your employment scheme benefits. The payment is normally processed automatically.
        ]
        #brødtekst[
            We share the information you provide in the employment status form with other systems within Nav, because this information is relevant for the follow-up you receive from Nav.
        ]
        #bekreftet[I confirm that I will fill out the employment status form correctly, to the best of my ability.]
    ]
]

#block(below: space-26)[
    == Absence
    #brødtekst[
        If you have not been sick or absent for other reasons this period, please answer "no". If you have been sick or absent for other reasons for an entire day or part of a day with employment scheme activities, please answer "yes". Then specify which days you were absent, as well as the type of absence.
    ]
    #brødtekst[*Have you been sick or absent for other reasons on any of the days you were supposed to participate in employment scheme activities?*]
    #brødtekst[No, I have not been sick or absent for other reasons]
    #brødtekst[Yes, I have been sick or absent for other reasons]

    === How to specify your absence
    #brødtekst[
        Some types of absence mean you are entitled to employment scheme benefits even if you did not participate. Please select the day(s) you were absent, as well as the type of absence.
    ]

    #shadowBox[
        #brødtekst[*When do I select "sick"?*]
        - #brødtekst[Please select "sick" if you were too sick to participate in the employment scheme activity. You may be entitled to employment scheme benefits when you are sick. It is therefore very important that you specify this on the form.]
        - #brødtekst[You will be paid the full benefit for the first 3 days you are sick. If you are sick more than 3 days, you will receive 75 percent of the full benefit payment for the rest of the employer liability period. An employer liability period is a total of 16 business days.]
        - #brødtekst[You need a medical certificate in order to be entitled to employment scheme benefits beyond 3 days.]

        #brødtekst[*When do I select "sick child or child carer"?*]
        - #brødtekst[Please select "Sick child or child carer" if you were unable to participate because your child or your child carer was sick.]
        - #brødtekst[The same rules apply when your child or child carer is sick as when you are sick. This means you are entitled to full payment for the first three days and then 75 percent for the rest of the employer liability period.]
        - #brødtekst[You must submit a medical certificate for your child or a certificate from your child carer from day 4 in order to be entitled to employment scheme benefits beyond 3 days.]

        #brødtekst[*When do I select "strong welfare reasons or job interview"?*]
        - #brødtekst[You should choose this option if Nav has approved your absence from the programme on this day due to:]
          - #brødtekst[a job interview]
          - #brødtekst[appointments with public support services]
          - #brødtekst[a funeral or memorial service for an immediate family member]
          - #brødtekst[other strong welfare reasons]
        - #brødtekst[Only your Nav counsellor can approve your absence – not the programme provider.]

        #brødtekst[*When do I select "other absence"?*]
        - #brødtekst[Please select "other absence" if you were absent for all or part of a day with employment scheme activities.]
        - #brødtekst[Please select "other absence" if you do not attend the agreed programme or activity, or if you do not participate in other activities that have been agreed with Nav.]
        - #brødtekst[Please select "other absence" if you worked instead of participating in employment scheme activities. For example: Your agreed employment scheme participation is from 09:00 to 15:00, and you worked from 09:00 to 10:00 instead of participating in employment scheme activities the entire day.]
        - #brødtekst[Please select "other absence" if you took time off/went on holiday outside of the scheduled holiday periods for the employment scheme.]
        - #brødtekst[Please select "other absence" if you are waiting for approval of your absence. You can always change your employment status form later after your Nav counsellor has approved your absence.]
    ]

    #brødtekst[Please select your type of absence]
    - #brødtekst[*Sick:* You were too sick to participate in the employment scheme activity.]
    - #brødtekst[*Sick child or sick child carer:* You were unable to participate because your child or child carer was sick.]
    - #brødtekst[*Strong welfare reasons or job interview:* You have been absent from the programme due to strong welfare reasons or a job interview, and your Nav counsellor has approved the absence.]
    - #brødtekst[*Other absence:* You were absent from activities all day or part of the day, and this absence has not been approved by Nav. You are not entitled to employment scheme benefits for this day.]
]

#block(below: space-26)[
    == Pay
    #brødtekst[
        If you are receiving pay (not employment scheme benefits) as part of your participation, answer "yes". Then specify which days you are receiving pay for.
    ]
    #brødtekst[*Are you receiving pay (not employment scheme benefits) as part of your participation?*]
    #brødtekst[No, I am only receiving employment scheme benefits]
    #brødtekst[Yes, I am receiving pay as part of my participation]
    #brødtekst[Please select the days you are receiving pay for]
]

#block(below: space-26)[
    == Attendance
    #brødtekst[
        Please select the days you participated in activities as agreed. You should select "participated" if the day was a public holiday and you did not participate because the employment scheme was closed.
    ]
    #brødtekst[Please select the days you participated in activities.]
]

#block(below: space-26)[
    == Summary
    #brødtekst[
        Below is a summary of the information you reported on your employment status form this period. Please make sure it is correct before you submit the form. You can go back and correct any incorrect information.
    ]
]

#block(below: space-26)[
    === Employment status form days
    #meldekortTabell(data.dager, labels)
    #bekreftet[I confirm that the above information is correct.]
]
