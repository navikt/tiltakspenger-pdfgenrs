// LEGACY PDFGEN (overgangsfase)
// Viser PDF fra gammel pdfgen (../tiltakspenger-pdfgen) ved siden av pdfgenrs,
// slik at de nye brevene kan sammenliknes med de gamle. Når pdfgen fjernes:
// slett denne fila og alt annet merket "LEGACY PDFGEN" (grep i devtools/brev-preview).
(async () => {
  let templates;
  try {
    templates = await (await fetch("/api/legacy/templates")).json();
  } catch {
    templates = [];
  }
  if (!templates.length) return; // pdfgen-repoet finnes ikke ved siden av dette repoet

  const figure = $("figure-legacy");
  const panel = pdfPanel($("pdf-legacy"), (message) => (figure.querySelector(".err").textContent = message || ""));

  window.brevPreview.legacyActive = true;
  if (!window.brevPreview.compareActive) window.brevPreview.setMainCaption("pdfgenrs (ny)");

  window.brevPreview.onGenerate((template, body) => {
    if (window.brevPreview.compareActive) {
      figure.hidden = true; // versjonssammenligning har overtatt høyresiden
      return;
    }
    figure.hidden = false;
    if (!templates.includes(template)) {
      panel.blank("— finnes ikke i pdfgen");
      return;
    }
    panel.load(`/api/legacy/genpdf/tpts/${template}`, body);
  });
})();
