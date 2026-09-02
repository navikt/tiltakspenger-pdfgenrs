# Demo-appen i dev: brev-preview-siden servert av sin egen Python-server, med
# pdfgenrs som separat nais-app. Kun dev - se «Demo i dev» i repoets README.
# Bygges fra repo-rota, siden siden leser flettedataene i testdata/tpts direkte.
FROM python:3.14-slim

WORKDIR /app

# serve.py finner repo-rota to nivåer opp fra sin egen plassering og serverer den,
# så filene må ligge likt her som i repoet. Rota inneholder bare disse to.
COPY devtools/brev-preview/ /app/devtools/brev-preview/
COPY testdata/tpts/ /app/testdata/tpts/

# Uten dette bufres stdout, og loggen i nais kommer først når containeren stopper.
ENV PYTHONUNBUFFERED=1

EXPOSE 8087
USER 1069

CMD ["python3", "/app/devtools/brev-preview/serve.py"]
