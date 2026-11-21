# Testrunner for run-tests.py — all verifisering skjer i denne containeren, ikke på utviklermaskinen.
# Digest-pinnet, så referansen er uforanderlig: en tagg kan flyttes, en digest kan ikke.
# Dependabot bumper tagg og digest sammen.
FROM python:3.15-slim@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928

RUN pip install --no-cache-dir pypdfium2 pillow
