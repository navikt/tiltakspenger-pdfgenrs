// Skjema generert rekursivt fra JSON-strukturen i flettedataene:
// boolske felt blir checkboxer, tall og tekst blir inputs, og arrays får
// «Legg til»/«Fjern»-knapper. onChange kalles ved hver endring.
function el(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function buildEditor(value, set, onChange) {
  if (Array.isArray(value)) return buildArray(value, onChange);
  if (value !== null && typeof value === "object") return buildObject(value, onChange);
  return buildScalar(value, set, onChange);
}

function buildObject(obj, onChange) {
  const wrap = el("div", "object");
  for (const key of Object.keys(obj)) {
    const nested = obj[key] !== null && typeof obj[key] === "object";
    const row = el("div", nested ? "row nested" : "row");
    row.append(el("span", "key", key));
    row.append(buildEditor(obj[key], (v) => (obj[key] = v), onChange));
    wrap.append(row);
  }
  return wrap;
}

function buildArray(arr, onChange) {
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
        onChange();
      };
      box.append(buildEditor(item, (v) => (arr[i] = v), onChange), remove);
      wrap.append(box);
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

function buildScalar(value, set, onChange) {
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
