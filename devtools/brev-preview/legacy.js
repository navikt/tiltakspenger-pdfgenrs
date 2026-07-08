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

  const newPdf = document.getElementById("pdf");
  const oldPdf = document.getElementById("pdf-legacy");
  oldPdf.hidden = false;

  const wrap = (iframe, label) => {
    const figure = document.createElement("figure");
    const caption = document.createElement("figcaption");
    caption.textContent = label;
    const error = document.createElement("span");
    error.className = "err";
    caption.append(error);
    iframe.replaceWith(figure);
    figure.append(caption, iframe);
    return error;
  };
  wrap(newPdf, "pdfgenrs (ny)");
  const legacyError = wrap(oldPdf, "pdfgen (gammel)");

  let objectUrl = null;
  let seq = 0;

  async function generateLegacy() {
    const name = document.getElementById("template").value;
    const current = window.brevPreview.current;
    if (!current) return;
    if (!templates.includes(name)) {
      legacyError.textContent = "— finnes ikke i pdfgen";
      oldPdf.src = "about:blank";
      return;
    }
    const mySeq = ++seq;
    try {
      const res = await fetch(`/api/legacy/genpdf/tpts/${name}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(current),
      });
      if (mySeq !== seq) return; // en nyere generering er underveis
      if (!res.ok) {
        legacyError.textContent = `${res.status}: ${await res.text()}`;
        return;
      }
      legacyError.textContent = "";
      if (objectUrl) URL.revokeObjectURL(objectUrl);
      objectUrl = URL.createObjectURL(await res.blob());
      oldPdf.src = objectUrl;
    } catch (e) {
      if (mySeq === seq) legacyError.textContent = String(e);
    }
  }

  // Regenerer den gamle PDF-en hver gang den nye oppdaterer seg
  new MutationObserver(generateLegacy).observe(newPdf, { attributes: true, attributeFilter: ["src"] });
  if (newPdf.src) generateLegacy();
})();
