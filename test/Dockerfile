# Testrunner for run-tests.py — all verifisering skjer i denne containeren, ikke på utviklermaskinen.
# Digest-pinnet, så referansen er uforanderlig: en tagg kan flyttes, en digest kan ikke.
# Dependabot bumper tagg og digest sammen.
FROM python:3.14-slim@sha256:cad9a2c871761c413caa6fdd6441c783451e740a48aaeba60ae62a8b53525ef6

RUN pip install --no-cache-dir pypdfium2 pillow
