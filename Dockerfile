# Dockerfile
FROM ghcr.io/navikt/pdfgenrs:1.0.24

# Søknadsvedleggene konverteres bilde → PDF via /api/v1/genpdf/image, og serverens default på 2 MiB er for lavt for dem.
# Grensen gjelder per request (RequestBodyLimitLayer), altså hver enkelt fil og hver enkelt rendrede PDF-side — ikke hele søknaden.
# 10 MiB er bevisst satt litt over frontendgrensen på 10 MB, slik at en fil som slipper gjennom skjemaet aldri kan bli avvist her.
ENV REQUEST_BODY_LIMIT_BYTES=10485760

COPY templates /app/templates
COPY fonts /app/fonts
COPY resources /app/resources
COPY lib /app/lib
