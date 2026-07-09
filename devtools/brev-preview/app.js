const $ = (id) => document.getElementById(id);

let defaults = null; // original flettedata fra data/tpts
let current = null; // gjeldende (redigerte) flettedata
let mode = "form";
let pdfObjectUrl = null;
let generateTimer = null;
let generateSeq = 0;

// LEGACY PDFGEN (overgangsfase): leses av legacy.js, slett når pdfgen fjernes
window.brevPreview = { get current() { return current; } };

// LEGACY PDFGEN (overgangsfase): maler som ikke er migrert til pdfgenrs ennå,
// vises med flettedata fra pdfgen-repoet. Slett når pdfgen fjernes.
let legacyOnly = new Set();

function el(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function scheduleGenerate() {
  clearTimeout(generateTimer);
  generateTimer = setTimeout(generate, 400);
}

/* ---- skjema generert fra JSON-strukturen ---- */

function buildEditor(value, set) {
  if (Array.isArray(value)) return buildArray(value);
  if (value !== null && typeof value === "object") return buildObject(value);
  return buildScalar(value, set);
}

function buildObject(obj) {
  const wrap = el("div", "object");
  for (const key of Object.keys(obj)) {
    const nested = obj[key] !== null && typeof obj[key] === "object";
    const row = el("div", nested ? "row nested" : "row");
    row.append(el("span", "key", key));
    row.append(buildEditor(obj[key], (v) => (obj[key] = v)));
    wrap.append(row);
  }
  return wrap;
}

function buildArray(arr) {
  const wrap = el("div", "array");
  const render = () => {
    wrap.replaceChildren();
    arr.forEach((item, i) => {
      const box = el("div", "item");
      const remove = el("button", "small", "Fjern");
      remove.type = "button";
      remove.onclick = () => {
        arr.splice(i, 1);
        render();
        scheduleGenerate();
      };
      box.append(buildEditor(item, (v) => (arr[i] = v)), remove);
      wrap.append(box);
    });
    const add = el("button", "small", "+ Legg til");
    add.type = "button";
    add.onclick = () => {
      arr.push(structuredClone(arr[arr.length - 1] ?? ""));
      render();
      scheduleGenerate();
    };
    wrap.append(add);
  };
  render();
  return wrap;
}

function buildScalar(value, set) {
  let input;
  if (typeof value === "boolean") {
    input = el("input");
    input.type = "checkbox";
    input.checked = value;
    input.oninput = () => {
      set(input.checked);
      scheduleGenerate();
    };
  } else if (typeof value === "number") {
    input = el("input");
    input.type = "number";
    input.step = "any";
    input.value = value;
    input.oninput = () => {
      set(input.value === "" ? 0 : Number(input.value));
      scheduleGenerate();
    };
  } else {
    const text = value ?? "";
    input = text.length > 60 || text.includes("\n") ? el("textarea") : el("input");
    input.value = text;
    input.oninput = () => {
      set(input.value);
      scheduleGenerate();
    };
  }
  return input;
}

/* ---- visning ---- */

function render() {
  $("form").hidden = mode !== "form";
  $("json").hidden = mode !== "json";
  if (mode === "form") {
    $("form").replaceChildren(buildEditor(current, (v) => (current = v)));
  } else {
    $("json").value = JSON.stringify(current, null, 2);
  }
}

function showError(message) {
  $("error").hidden = !message;
  $("error").textContent = message ?? "";
}

async function generate() {
  clearTimeout(generateTimer);
  // LEGACY PDFGEN: ikke migrert ennå -> vis kun gammel pdfgen (src-endringen trigger legacy-panelet)
  if (legacyOnly.has($("template").value)) {
    ++generateSeq;
    showError(null);
    if (pdfObjectUrl) {
      URL.revokeObjectURL(pdfObjectUrl);
      pdfObjectUrl = null;
    }
    $("pdf").src = "about:blank";
    $("status").textContent = "Ikke migrert til pdfgenrs ennå — viser kun gammel pdfgen.";
    return;
  }
  const seq = ++generateSeq;
  $("status").textContent = "Genererer …";
  try {
    const res = await fetch(`/api/genpdf/tpts/${$("template").value}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(current),
    });
    if (seq !== generateSeq) return; // en nyere generering er underveis
    if (!res.ok) {
      showError(`${res.status}: ${await res.text()}`);
      $("status").textContent = "";
      return;
    }
    showError(null);
    if (pdfObjectUrl) URL.revokeObjectURL(pdfObjectUrl);
    pdfObjectUrl = URL.createObjectURL(await res.blob());
    $("pdf").src = pdfObjectUrl;
    $("status").textContent = "";
  } catch (e) {
    if (seq === generateSeq) {
      showError(String(e));
      $("status").textContent = "";
    }
  }
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
