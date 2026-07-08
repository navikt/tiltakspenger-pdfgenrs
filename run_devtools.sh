#!/bin/bash
# Starter brev-preview-devtoolsen på http://localhost:8087.
# serve.py finner en kjørende pdfgenrs (port 8084 eller 8085), og starter den
# selv med `docker compose up -d --build` om den ikke kjører (tilsvarer
# run_development.sh, bare uten å låse terminalen).

CURRENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

exec python3 "$CURRENT_PATH/devtools/brev-preview/serve.py" "$@"
