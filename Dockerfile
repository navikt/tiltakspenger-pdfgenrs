# Dockerfile
FROM ghcr.io/navikt/pdfgenrs:1.0.17

COPY templates /app/templates
COPY fonts /app/fonts
COPY resources /app/resources
COPY lib /app/lib
