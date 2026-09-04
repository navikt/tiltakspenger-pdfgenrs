# Demo-appen i dev: brev-preview-siden servert av sin egen Python-server, med
# pdfgenrs som separat nais-app. Kun dev - se «Demo i dev» i repoets README.
# Bygges fra repo-rota, siden siden leser flettedataene i testdata/tpts direkte.
# Baseimage er Navs Chainguard-mirror, som er anbefalingen på sikkerhet.nav.no.
# imagene bygges om daglig, og de har verken shell, pakkebehandler eller installert pip.
# Serveren bruker kun stdlib og trenger ingenting av det som er fjernet.
# Taggen 3.14 er flytende innenfor 3.14-linja, så nye patcher kommer ved neste bygg og ikke som dependabot-PR.
# I CI logger nais/docker-build-push inn selv; lokalt kreves `gcloud auth configure-docker europe-north1-docker.pkg.dev` én gang.
FROM europe-north1-docker.pkg.dev/cgr-nav/pull-through/nav.no/python:3.14

WORKDIR /app

# serve.py finner repo-rota to nivåer opp fra sin egen plassering og serverer den,
# så filene må ligge likt her som i repoet. Rota inneholder bare disse to.
COPY devtools/brev-preview/ /app/devtools/brev-preview/
COPY testdata/tpts/ /app/testdata/tpts/

# Uten dette bufres stdout, og loggen i nais kommer først når containeren stopper.
ENV PYTHONUNBUFFERED=1

EXPOSE 8087
# imaget har ingen bruker 1069, men nonroot (uid 65532), som også er default der.
# I nais spiller det uansett ingen rolle: poden får runAsUser 1069 fra naiserator, og alt appen leser er lesbart for alle.
USER nonroot

# Baseimaget har python-binæren som ENTRYPOINT, så CMD er argumentlista til den.
CMD ["/app/devtools/brev-preview/serve.py"]
