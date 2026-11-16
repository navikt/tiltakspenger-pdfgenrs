// Gjenbrukbart PDF-panel: nettleserens PDF-viser er standard, PDF.js kan velges for synkronisert rulling.
// Holder styr på objectURL-er og ignorerer svar som er utdaterte fordi en nyere generering rakk å starte.
function pdfPanel(iframe, viewer, setError) {
  const pages = viewer.querySelector(".pdfjs-pages");
  const nativeLink = viewer.querySelector(".pdfjs-native-link a");
  const pdfjsBase = new URL("./vendor/pdfjs/6.5.438/build/", document.baseURI);
  let objectUrl = null;
  let seq = 0;
  let renderSeq = 0;
  let bytes = null;
  let mode = "native";
  let pdfLoadingTask = null;
  let pdfjsPromise = null;
  let renderedWidth = 0;

  function loadPdfjs() {
    if (!pdfjsPromise) {
      pdfjsPromise = import(new URL("pdf.min.mjs", pdfjsBase).href).then((pdfjs) => {
        pdfjs.GlobalWorkerOptions.workerSrc = new URL("pdf.worker.min.mjs", pdfjsBase).href;
        return pdfjs;
      });
    }
    return pdfjsPromise;
  }

  async function render() {
    const mySeq = ++renderSeq;
    const oldLoadingTask = pdfLoadingTask;
    pdfLoadingTask = null;
    iframe.hidden = mode === "pdfjs";
    viewer.hidden = mode !== "pdfjs";
    try {
      if (oldLoadingTask) await oldLoadingTask.destroy();
      if (mode === "native") {
        pages.replaceChildren();
        viewer.removeAttribute("aria-busy");
        if (objectUrl) iframe.src = objectUrl;
        return;
      }
      if (!bytes) return;
      const width = viewer.clientWidth;
      if (!width) return;
      renderedWidth = width;
      pages.replaceChildren();
      viewer.setAttribute("aria-busy", "true");
      setError("");
      const pdfjs = await loadPdfjs();
      if (mySeq !== renderSeq) return;
      const loadingTask = pdfjs.getDocument({ data: bytes.slice() });
      pdfLoadingTask = loadingTask;
      const pdfDoc = await loadingTask.promise;
      if (mySeq !== renderSeq) {
        if (pdfLoadingTask === loadingTask) {
          pdfLoadingTask = null;
          await loadingTask.destroy();
        }
        return;
      }
      for (let number = 1; number <= pdfDoc.numPages; number++) {
        if (mySeq !== renderSeq) return;
        const page = await pdfDoc.getPage(number);
        if (mySeq !== renderSeq) return;
        const original = page.getViewport({ scale: 1 });
        const scale = Math.max(0.1, (width - 24) / original.width);
        const viewport = page.getViewport({ scale });
        const outputScale = window.devicePixelRatio || 1;
        const canvas = window.document.createElement("canvas");
        canvas.className = "pdfjs-page";
        canvas.width = Math.ceil(viewport.width * outputScale);
        canvas.height = Math.ceil(viewport.height * outputScale);
        canvas.style.width = `${viewport.width}px`;
        canvas.style.height = `${viewport.height}px`;
        const context = canvas.getContext("2d");
        context.setTransform(outputScale, 0, 0, outputScale, 0, 0);
        pages.append(canvas);
        await page.render({ canvasContext: context, viewport }).promise;
      }
    } catch (e) {
      if (mySeq === renderSeq) setError(String(e));
    } finally {
      if (mySeq === renderSeq) viewer.removeAttribute("aria-busy");
    }
  }

  new ResizeObserver(() => {
    const width = viewer.clientWidth;
    if (mode === "pdfjs" && bytes && width && width !== renderedWidth) render();
  }).observe(viewer);

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
      const blob = await res.blob();
      const data = new Uint8Array(await blob.arrayBuffer());
      if (mySeq !== seq) return;
      if (objectUrl) URL.revokeObjectURL(objectUrl);
      objectUrl = URL.createObjectURL(blob);
      nativeLink.href = objectUrl;
      nativeLink.hidden = false;
      bytes = data;
      setError("");
      await render();
    } catch (e) {
      if (mySeq === seq) setError(String(e));
    }
  }

  function setMode(nextMode) {
    if (nextMode !== mode) {
      mode = nextMode;
      render();
    }
  }

  return { load, setMode };
}
