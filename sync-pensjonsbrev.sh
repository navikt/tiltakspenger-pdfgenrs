#!/usr/bin/env bash
# Synker lib/pensjonsbrev/ 1-1 med Typst-oppsettet i navikt/pensjonsbrev (brevbaker/pdf-bygger/containerFiles/typst).
# Filene der er fasit og skal aldri redigeres lokalt — gjør endringer oppstrøms eller i egne adaptere.
#
# Bruk:
#   ./sync-pensjonsbrev.sh                  kopier inn siste versjon fra GitHub
#   ./sync-pensjonsbrev.sh ../pensjonsbrev  kopier fra en lokal klone
#   ./sync-pensjonsbrev.sh --check [klone]  kun diff, feiler ved avvik (brukes i CI)
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

UPSTREAM_REPO="https://github.com/navikt/pensjonsbrev"
UPSTREAM_PATH="brevbaker/pdf-bygger/containerFiles/typst"
LOCAL_PATH="lib/pensjonsbrev"

mode="sync"
if [[ "${1:-}" == "--check" ]]; then
    mode="check"
    shift
fi
kilde="${1:-}"

if [[ -z "$kilde" ]]; then
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    echo "Henter $UPSTREAM_REPO ..."
    git clone --quiet --depth 1 --filter=blob:none --sparse "$UPSTREAM_REPO" "$tmp"
    git -C "$tmp" sparse-checkout set --no-cone "$UPSTREAM_PATH" >/dev/null
    kilde="$tmp"
fi

src="$kilde/$UPSTREAM_PATH"
[[ -d "$src" ]] || { echo "FEIL: fant ikke $src" >&2; exit 1; }

if [[ "$mode" == "check" ]]; then
    if diff -r "$src" "$LOCAL_PATH"; then
        echo "OK: $LOCAL_PATH er identisk med upstream ($UPSTREAM_PATH)."
    else
        echo "" >&2
        echo "FEIL: $LOCAL_PATH avviker fra upstream ($UPSTREAM_PATH)." >&2
        echo "Kjør ./sync-pensjonsbrev.sh for å hente siste versjon (lokale endringer skal ikke skje der)." >&2
        exit 1
    fi
else
    rm -rf "$LOCAL_PATH"
    mkdir -p "$LOCAL_PATH"
    cp -R "$src/." "$LOCAL_PATH/"
    echo "OK: $LOCAL_PATH er oppdatert fra upstream."
    git status --short -- "$LOCAL_PATH" || true
fi
