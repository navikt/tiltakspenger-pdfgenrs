// Kjernen: flettedata-state, mal-valg, skjema/JSON-redigering og hovedpanelet.
// Ekstra paneler (compare.js) kobler seg på via window.brevPreview.
const $ = (id) => document.getElementById(id);

let defaults = null; // original flettedata fra data/tpts
let current = null; // gjeldende (redigerte) flettedata
let mode = "form";
let generateTimer = null;
let generateSeq = 0;
let lastGenerate = null; // {template, body} - så paneler som kobler seg på sent får siste generering
const generateHooks = []; // kalles med (template, body) ved hver generering
let mainTarget = null; // compare.js overstyrer hvor hovedpanelet genereres (async (template) -> url)

const mainPanel = pdfPanel($("pdf"), showError);

window.brevPreview = {
  get current() {
    return current;
  },
  compareActive: false, // settes av compare.js
  setMainCaption,
  setMainTarget(fn) {
    mainTarget = fn;
  },
  onGenerate(fn) {
    generateHooks.push(fn);
    if (lastGenerate) fn(lastGenerate.template, lastGenerate.body);
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
  lastGenerate = { template, body: JSON.stringify(current) };
  for (const fn of generateHooks) fn(template, lastGenerate.body);
  const seq = ++generateSeq;
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
  defaults = await (await fetch(`/data/tpts/${name}.json`)).json();
  current = structuredClone(defaults);
  render();
  generate();
}

async function init() {
  const names = await (await fetch("/api/templates")).json();
  for (const name of names) $("template").append(new Option(name, name));
  const saved = localStorage.getItem("devtools-template");
  if (names.includes(saved)) $("template").value = saved;

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
