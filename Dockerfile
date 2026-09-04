# Dockerfile
FROM ghcr.io/navikt/pdfgenrs:1.0.32

# Søknadsvedleggene konverteres bilde → PDF via /api/v1/genpdf/image, og serverens default på 2 MiB er for lavt for dem.
# Grensen gjelder per request (RequestBodyLimitLayer), altså hver enkelt fil og hver enkelt rendrede PDF-side — ikke hele søknaden.
# 10 MiB er bevisst satt litt over frontendgrensen på 10 MB, slik at en fil som slipper gjennom skjemaet aldri kan bli avvist her.
ENV REQUEST_BODY_LIMIT_BYTES=10485760

# Fra 1.0.24 avvises bilder også på antall piksler, med 8192 piksler per side og 25 megapiksler i alt som default.
# Defaultene er for lave for vedleggene våre: et mobilbilde på 48 megapiksler (8064 × 6048) er godt under 10 MB og slipper gjennom skjemaet, men ville blitt avvist her.
# PDF-vedlegg rastreres side for side i tiltakspenger-soknad-api, der en side kan være 20 megapiksler stor og 14400 punkter bred (maksimum i PDF-formatet).
# Avvisningen er 413 og dermed permanent, så ett bilde som stanses her stanser journalføringen av hele søknaden.
# Grensene er fortsatt en sikkerhetsgrense mot dekomprimeringsbomber — 50 megapiksler dekodes til rundt 200 MiB, og poden har 2 GiB.
ENV MAX_IMAGE_DIMENSION_PIXELS=16384
ENV MAX_IMAGE_PIXELS=50000000

COPY templates /app/templates
COPY fonts /app/fonts
COPY resources /app/resources
COPY lib /app/lib
