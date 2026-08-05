#!/usr/bin/env bash
# Kjører brevtestene (test/run-tests.py) i Docker — samme kommando lokalt og i CI.
# Ved feil ligger debugfiler i build/test/.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Eget prosjektnavn. Uten det arver testkjøringen prosjektnavnet fra katalogen, og
# `down --remove-orphans` river ned utviklings-containeren fra docker-compose.yml
# (port 8084) fordi den ikke finnes i testoppsettet.
PROSJEKT=tiltakspenger-pdfgenrs-test

cleanup() { docker compose -p "$PROSJEKT" -f docker-compose.test.yml down --remove-orphans >/dev/null 2>&1 || true; }
trap cleanup EXIT

docker compose -p "$PROSJEKT" -f docker-compose.test.yml up --build --exit-code-from test --attach test
