#import "/lib/mod.typ": *

#let data = json("/data/tpts/meldekort-korrigert-en.json")
#show: apply-styles
#show: page-setup(data)

#let title = "Edited employment status form for employment scheme benefits"
#show: dokument(title, lang: "en")

#let labels = meldekortLabelsEn

#block(below: space-26, width: 100%)[
    #brevlogo

    #personaliaInnsendt(
        (
            ("Norwegian national identification number:", data.fnr),
            ("Case number:", data.saksnummer),
            ("Employment status form ID:", data.id),
        ),
        [Received: #data.mottatt],
    )

    = Employment status form for employment scheme benefits

    #h2([#data.periode.fraOgMed - #data.periode.tilOgMed (week #(data.uke1)-#(data.uke2))])
]

#block(below: space-26)[
    #h2([Edit employment status form])

    #shadowBox[
        #h3("When do I select \"received pay\"?")
        #brødtekst[If you receive pay (not employment scheme benefits) as part of your programme, choose "Received pay".]
    ]

    #shadowBox[
        #h3("When do I select “sick”?")
        #brødtekst[*Sick*]
        - #brødtekst[Please select “sick” if you were too sick to participate in the employment scheme activity. You may be entitled to employment scheme benefits when you are sick. It is therefore very important that you specify this on the form.]
        - #brødtekst[You will be paid the full benefit for the first 3 days you are sick. If you are sick more than 3 days, you will receive 75 percent of the full benefit payment for the rest of the employer liability period. An employer liability period is a total of 16 business days.]
        - #brødtekst[You need a medical certificate in order to be entitled to employment scheme benefits beyond 3 days.]

        #brødtekst[*Sick child or sick child carer*]
        - #brødtekst[Please select “Sick child or child carer” if you were unable to participate because your child or your child carer was sick.]
        - #brødtekst[The same rules apply when your child or child carer is sick as when you are sick. This means you are entitled to full payment for the first three days and then 75 percent for the rest of the employer liability period.]
        - #brødtekst[You must submit a medical certificate for your child or a certificate from your child carer from day 4 in order to be entitled to employment scheme benefits beyond 3 days.]
    ]

    #shadowBox[
        #h3("When do I select absence?")
        #brødtekst[*Strong welfare reasons or job interview*]
        - #brødtekst[You should choose this option if Nav has approved your absence from the programme on this day due to:]
            - #brødtekst[a job interview]
            - #brødtekst[appointments with public support services]
            - #brødtekst[a funeral or memorial service for an immediate family member]
            - #brødtekst[other strong welfare reasons]
        - #brødtekst[Only your Nav counsellor can approve your absence – not the programme provider.]

        #brødtekst[*Other absence*]
        - #brødtekst[Please select “other absence” if you were absent for all or part of a day with employment scheme activities.]
        - #brødtekst[Please select “other absence” if you do not attend the agreed programme or activity, or if you do not participate in other activities that have been agreed with Nav.]
        - #brødtekst[Please select “other absence” if you worked instead of participating in employment scheme activities. For example: Your agreed employment scheme participation is from 09:00 to 15:00, and you worked from 09:00 to 10:00 instead of participating in employment scheme activities the entire day.]
        - #brødtekst[Please select “other absence” if you took time off/went on holiday outside of the scheduled holiday periods for the employment scheme.]
        - #brødtekst[Please select “other absence” if you are waiting for approval of your absence. You can always change your employment status form later after your Nav counsellor has approved your absence.]
    ]
]

#block(below: space-26)[
    #h2([How to edit your employment status form])
    #brødtekst[
        Below, you can see what you previously registered in the employment status form. Update the selections on the days where the information is incorrect. After you submit the changes, they will be processed before any adjustments are made to your payment.
    ]
]

#block(below: space-26)[
    #h3([Summary of edited employment status form])
    #meldekortTabell(data.dager, labels)
    #bekreftet[I confirm that the above information is correct.]
]
