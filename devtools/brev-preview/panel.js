// Gjenbrukbart PDF-panel: laster en generert PDF inn i en iframe.
// Holder styr på objectURL-er og ignorerer svar som er utdaterte fordi en
// nyere generering rakk å starte. Feil rapporteres via setError-callbacken.
function pdfPanel(iframe, setError) {
  let objectUrl = null;
  let seq = 0;

  async function load(url, body) {
    const mySeq = ++seq;
    try {
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body,
      });
      if (mySeq !== seq) return;
      if (!res.ok) {
        setError(`${res.status}: ${await res.text()}`);
        return;
      }
      setError("");
      if (objectUrl) URL.revokeObjectURL(objectUrl);
      objectUrl = URL.createObjectURL(await res.blob());
      iframe.src = objectUrl;
    } catch (e) {
      if (mySeq === seq) setError(String(e));
    }
  }

  function blank(message) {
    ++seq; // en eventuell pågående load skal ikke overskrive blankingen
    setError(message ?? "");
    if (objectUrl) {
      URL.revokeObjectURL(objectUrl);
      objectUrl = null;
    }
    iframe.src = "about:blank";
  }

  return { load, blank };
}
