// Skjema generert rekursivt fra JSON-strukturen i flettedataene:
// boolske felt blir checkboxer, tall og tekst blir inputs, felt som er enum
// (se enums.js) blir nedtrekkslister, felt som regnes ut fra andre felt
// (se avledet.js) blir skrivebeskyttet, og arrays får «Legg til»/«Fjern»-knapper.
// Objekter og lister er sammenleggbare, så store brev er til å finne fram i.
// onChange kalles ved hver endring.
//
// «sti» er stien inn i flettedataene («meldeperioder[].dager[].status.gjeldende»,
// der «[]» er et array-ledd), og «felt» er {enum, avledet} for det valgte
// datasettet — begge slår opp på nettopp den stien.
function el(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

// Lister med flere ledd enn dette starter sammenlagt.
const ÅPNE_LEDD = 3;

function buildEditor(value, set, onChange, felt = {}, sti = "") {
  if (Array.isArray(value)) return buildArray(value, onChange, felt, sti);
  if (value !== null && typeof value === "object") return buildObject(value, onChange, felt, sti);
  return buildScalar(value, set, onChange, felt.enum?.[sti]);
}

function buildObject(obj, onChange, felt, sti) {
  const wrap = el("div", "object");
  for (const key of Object.keys(obj)) {
    const barnesti = sti ? `${sti}.${key}` : key;
    const set = (v) => (obj[key] = v);
    if (obj[key] !== null && typeof obj[key] === "object") {
      const gruppe = el("details", "gruppe");
      gruppe.open = true;
      gruppe.append(el("summary", "key", key), buildEditor(obj[key], set, onChange, felt, barnesti));
      wrap.append(gruppe);
    } else {
      // Kontrollen ligger inni etiketten, så klikk på nøkkelen treffer feltet.
      const row = el("label", "row");
      const kontroll = felt.avledet?.[barnesti]
        ? buildAvledet(() => obj[key])
        : buildEditor(obj[key], set, onChange, felt, barnesti);
      row.append(el("span", "key", key), kontroll);
      wrap.append(row);
    }
  }
  return wrap;
}

// Felt som regnes ut fra andre felt: vises, men kan ikke redigeres.
// `.oppdater()` henter verdien på nytt etter at grunnlaget er endret — app.js
// kaller den på alle `.avledet` i skjemaet ved hver endring.
function buildAvledet(les) {
  const input = el("input", "avledet");
  input.title = "Regnes ut fra de andre feltene";
  if (typeof les() === "boolean") {
    input.type = "checkbox";
    input.disabled = true;
    input.oppdater = () => (input.checked = les());
  } else {
    input.readOnly = true;
    input.oppdater = () => (input.value = les() ?? "");
  }
  input.oppdater();
  return input;
}

// Første tekst- eller tallverdi i leddet, brukt som overskrift på et sammenlagt ledd.
function ledetekst(item) {
  if (item === null || typeof item !== "object") return null;
  for (const verdi of Object.values(item)) {
    if (typeof verdi === "string" && verdi.trim()) return verdi.length > 60 ? `${verdi.slice(0, 60)}…` : verdi;
    if (typeof verdi === "number") return String(verdi);
    const nedover = ledetekst(verdi);
    if (nedover) return nedover;
  }
  return null;
}

function buildArray(arr, onChange, felt, sti) {
  const barnesti = `${sti}[]`;
  const wrap = el("div", "array");
  const render = () => {
    wrap.replaceChildren();
    arr.forEach((item, i) => {
      const remove = el("button", "fjern", "Fjern");
      remove.type = "button";
      remove.title = "Fjern dette leddet";
      remove.onclick = (e) => {
        e.preventDefault(); // knappen ligger i en <summary>/<label> som ellers reagerer på klikket
        e.stopPropagation();
        arr.splice(i, 1);
        render();
        onChange();
      };
      const editor = buildEditor(item, (v) => (arr[i] = v), onChange, felt, barnesti);
      if (item !== null && typeof item === "object") {
        const ledd = el("details", "item");
        ledd.open = arr.length <= ÅPNE_LEDD;
        const summary = el("summary");
        summary.append(el("span", "nummer", `${i + 1}`), el("span", "ledetekst", ledetekst(item) ?? ""), remove);
        ledd.append(summary, editor);
        wrap.append(ledd);
      } else {
        const ledd = el("label", "item flat");
        ledd.append(el("span", "nummer", `${i + 1}`), editor, remove);
        wrap.append(ledd);
      }
    });
    const add = el("button", "small", "+ Legg til");
    add.type = "button";
    add.onclick = () => {
      arr.push(structuredClone(arr[arr.length - 1] ?? ""));
      render();
      onChange();
    };
    wrap.append(add);
  };
  render();
  return wrap;
}

// Nedtrekksliste for felt som er enum. Alternativet er enten "VERDI" eller
// ["VERDI", "Etikett"]; option-verdien er plassen i listen, så verdier som null
// og tall overlever turen gjennom DOM-en.
function buildValg(value, alternativer, set, onChange) {
  const valg = alternativer.map((a) => (Array.isArray(a) ? a : [a, a]));
  // En verdi utenfor listen (typisk redigert i JSON-modus) skal ikke gå tapt.
  if (!valg.some(([verdi]) => verdi === value)) valg.push([value, `${value} (ukjent verdi)`]);
  const select = el("select");
  valg.forEach(([verdi, etikett], i) => {
    const option = new Option(etikett, String(i));
    option.selected = verdi === value;
    select.append(option);
  });
  const vis = () => (select.title = `Verdi: ${valg[Number(select.value)][0]}`);
  select.onchange = () => {
    set(valg[Number(select.value)][0]);
    vis();
    onChange();
  };
  vis();
  return select;
}

function buildScalar(value, set, onChange, alternativer) {
  if (alternativer) return buildValg(value, alternativer, set, onChange);
  let input;
  if (typeof value === "boolean") {
    input = el("input");
    input.type = "checkbox";
    input.checked = value;
    input.oninput = () => {
      set(input.checked);
      onChange();
    };
  } else if (typeof value === "number") {
    input = el("input");
    input.type = "number";
    input.step = "any";
    input.value = value;
    input.oninput = () => {
      set(input.value === "" ? 0 : Number(input.value));
      onChange();
    };
  } else {
    const text = value ?? "";
    input = text.length > 60 || text.includes("\n") ? el("textarea") : el("input");
    input.value = text;
    input.oninput = () => {
      set(input.value);
      onChange();
    };
  }
  return input;
}
