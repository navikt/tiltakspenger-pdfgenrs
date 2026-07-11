// Kjernen: flettedata-state, mal-valg, skjema/JSON-redigering og hovedpanelet.
// Ekstra paneler (compare.js, legacy.js) kobler seg på via window.brevPreview.
const $ = (id) => document.getElementById(id);

let defaults = null; // original flettedata fra data/tpts
let current = null; // gjeldende (redigerte) flettedata
let mode = "form";
let generateTimer = null;
let generateSeq = 0;
let lastGenerate = null; // {template, body, legacyOnly} - så paneler som kobler seg på sent får siste generering
const generateHooks = []; // kalles med (template, body, {legacyOnly}) ved hver generering
let mainTarget = null; // compare.js overstyrer hvor hovedpanelet genereres (async (template) -> url)

// LEGACY PDFGEN (overgangsfase): maler som ikke er migrert til pdfgenrs ennå,
// vises med flettedata fra pdfgen-repoet. Slett når pdfgen fjernes.
let legacyOnly = new Set();

const mainPanel = pdfPanel($("pdf"), showError);

window.brevPreview = {
  get current() {
    return current;
  },
  legacyActive: false, // settes av legacy.js (LEGACY PDFGEN)
  compareActive: false, // settes av compare.js
  setMainCaption,
  setMainTarget(fn) {
    mainTarget = fn;
  },
  onGenerate(fn) {
    generateHooks.push(fn);
    if (lastGenerate) fn(lastGenerate.template, lastGenerate.body, lastGenerate);
  },
  generate,
  scheduleGenerate,
};

function scheduleGenerate() {
  clearTimeout(generateTimer);
  generateTimer = setTimeout(generate, 400);
}

function render() {
  $("form").hidden = mode !== "form";
  $("json").hidden = mode !== "json";
  if (mode === "form") {
    $("form").replaceChildren(buildEditor(current, (v) => (current = v), scheduleGenerate));
  } else {
    $("json").value = JSON.stringify(current, null, 2);
  }
}

function showError(message) {
  $("error").hidden = !message;
  $("error").textContent = message || "";
}

function setMainCaption(label) {
  $("caption-a").hidden = !label;
  $("caption-a").querySelector(".label").textContent = label || "";
}

async function generate() {
  clearTimeout(generateTimer);
  if (current === null) return; // init er ikke ferdig ennå
  const template = $("template").value;
  lastGenerate = { template, body: JSON.stringify(current), legacyOnly: legacyOnly.has(template) };
  for (const fn of generateHooks) fn(template, lastGenerate.body, lastGenerate);
  const seq = ++generateSeq;
  // LEGACY PDFGEN: ikke migrert ennå -> vis kun gammel pdfgen (via legacy.js sin hook)
  if (lastGenerate.legacyOnly) {
    mainPanel.blank();
    $("status").textContent = "Ikke migrert til pdfgenrs ennå — viser kun gammel pdfgen.";
    return;
  }
  $("status").textContent = "Genererer …";
  try {
    const url = mainTarget ? await mainTarget(template) : `/api/genpdf/tpts/${template}`;
    if (seq !== generateSeq) return; // en nyere generering er underveis
    await mainPanel.load(url, lastGenerate.body);
  } catch (e) {
    showError(String(e)); // f.eks. klargjøring av valgt versjon feilet
  }
  if (seq === generateSeq) $("status").textContent = "";
}

async function loadTemplate() {
  const name = $("template").value;
  localStorage.setItem("devtools-template", name);
  // LEGACY PDFGEN: umigrerte maler har flettedataene sine i pdfgen-repoet
  const dataUrl = legacyOnly.has(name) ? `/api/legacy/data/${name}` : `/data/tpts/${name}.json`;
  defaults = await (await fetch(dataUrl)).json();
  current = structuredClone(defaults);
  render();
  generate();
}

async function init() {
  const names = await (await fetch("/api/templates")).json();
  for (const name of names) $("template").append(new Option(name, name));
  // LEGACY PDFGEN: vis også maler som kun finnes i gammel pdfgen (ikke migrert ennå)
  try {
    const legacyNames = await (await fetch("/api/legacy/templates")).json();
    legacyOnly = new Set(legacyNames.filter((n) => !names.includes(n)));
    for (const name of [...legacyOnly].sort()) {
      $("template").append(new Option(`${name} (kun i pdfgen)`, name));
    }
  } catch {
    legacyOnly = new Set();
  }
  const saved = localStorage.getItem("devtools-template");
  if (names.includes(saved) || legacyOnly.has(saved)) $("template").value = saved;

  $("template").onchange = loadTemplate;
  $("generate").onclick = generate;
  $("reset").onclick = () => {
    current = structuredClone(defaults);
    render();
    generate();
  };
  for (const button of $("mode").querySelectorAll("button")) {
    button.onclick = () => {
      mode = button.dataset.mode;
      for (const b of $("mode").querySelectorAll("button")) b.classList.toggle("active", b === button);
      showError(null);
      render();
    };
  }
  $("json").oninput = () => {
    try {
      current = JSON.parse($("json").value);
      showError(null);
      scheduleGenerate();
    } catch (e) {
      showError(`Ugyldig JSON: ${e.message}`);
    }
  };

  await loadTemplate();
}

init();
