// Kjernen: flettedata-state, mal-valg, skjema/JSON-redigering og hovedpanelet.
// Ekstra paneler (compare.js) kobler seg på via window.brevPreview.
const $ = (id) => document.getElementById(id);

let defaults = null; // original flettedata fra data/tpts
let current = null; // gjeldende (redigerte) flettedata
let felt = { enum: {}, avledet: {} }; // enums.js/avledet.js for valgt datasett
let fraLenke = null; // flettedata fra en delt lenke, brukes kun ved første lasting
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

// Ved hver endring i skjemaet: regn ut de avledede feltene på nytt og vis dem,
// før genereringen planlegges. JSON-modus er rå og røres ikke — der setter du hva du vil.
function endret() {
  beregnAvledede(current, felt.avledet);
  for (const visning of $("form").querySelectorAll(".avledet")) visning.oppdater();
  scheduleGenerate();
}

function render() {
  $("form").hidden = mode !== "form";
  $("json").hidden = mode !== "json";
  if (mode === "form") {
    beregnAvledede(current, felt.avledet); // også når skjemaet åpnes etter en runde i JSON-modus
    $("form").replaceChildren(buildEditor(current, (v) => (current = v), endret, felt));
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
  // Ikke await: adressefeltet trenger ikke være oppdatert før PDF-en hentes
  skrivLenke(template, current, erEndret()).catch(() => {});
  try {
    const url = mainTarget ? await mainTarget(template) : `/api/genpdf/tpts/${template}`;
    if (seq !== generateSeq) return; // en nyere generering er underveis
    await mainPanel.load(url, lastGenerate.body);
  } catch (e) {
    showError(String(e)); // f.eks. klargjøring av valgt versjon feilet
  }
  if (seq === generateSeq) $("status").textContent = "";
}

// Flettedataene er endret når de ikke lenger er datasettet i data/tpts.
// Styrer om lenken må bære med seg innholdet, eller bare peke på brevet.
function erEndret() {
  return JSON.stringify(current) !== JSON.stringify(defaults);
}

async function loadTemplate() {
  const name = $("template").value;
  localStorage.setItem("devtools-template", name);
  felt = { enum: enumFeltFor(name), avledet: avledetFeltFor(name) };
  defaults = await (await fetch(`/data/tpts/${name}.json`)).json();
  current = fraLenke ?? structuredClone(defaults);
  fraLenke = null; // gjelder kun den første lastingen; bytter du brev, er du tilbake på datasettet
  render();
  await generate(); // ventes på, så init kan si fra om lenken uten at genereringen tømmer meldingen
}

// «Kopier lenke» bygger lenken på nytt i stedet for å lese adressefeltet, så den
// får med endringer som ennå ikke har rukket å utløse en generering.
async function kopierLenke() {
  try {
    await navigator.clipboard.writeText(await byggLenke($("template").value, current, erEndret()));
    $("status").textContent = "Lenke kopiert";
    setTimeout(() => ($("status").textContent = ""), 2000);
  } catch (e) {
    showError(`Fikk ikke kopiert lenken: ${e.message}`);
  }
}

async function init() {
  const names = await (await fetch("/api/templates")).json();
  for (const name of names) $("template").append(new Option(name, name));

  // Delt lenke går foran det sist brukte brevet. Er lenken ødelagt, viser vi
  // datasettet i stedet for å stå igjen med en tom side, og sier fra om hvorfor.
  const lenke = await lesLenke();
  const saved = localStorage.getItem("devtools-template");
  let lenkefeil = lenke?.feil ?? null;
  if (lenke && names.includes(lenke.brev)) {
    $("template").value = lenke.brev;
    fraLenke = lenke.data;
  } else {
    if (lenke) lenkefeil = `Lenken peker på brevet «${lenke.brev}», som ikke finnes.`;
    if (names.includes(saved)) $("template").value = saved;
  }

  $("template").onchange = loadTemplate;
  $("generate").onclick = generate;
  $("share").onclick = kopierLenke;
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
  if (lenkefeil) showError(lenkefeil);
}

init();
