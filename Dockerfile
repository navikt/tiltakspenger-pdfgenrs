# Dockerfile
FROM ghcr.io/navikt/pdfgenrs:1.0.4

COPY templates /app/templates
COPY fonts /app/fonts
COPY resources /app/resources

ENV ENABLE_HTML_ENDPOINT=false
