// VERSJONSSAMMENLIGNING: pdfgenrs mot pdfgenrs.
// Sammenlikner arbeidskatalogen (med lokale/uncommittede endringer) mot en
// vilkårlig git-ref, eller to refs mot hverandre. serve.py/versions.py lager
// et git-worktree og starter en egen pdfgenrs-container per ref.
(async () => {
  const WORKTREE = "arbeidskatalogen";

  let refsInfo;
  try {
    refsInfo = await (await fetch("/api/refs")).json();
  } catch {
    return; // /api/refs utilgjengelig - skjul hele funksjonen
  }
  $("compare-rs-nav").hidden = false;

  let active = false;
  const refs = {
    a: localStorage.getItem("devtools-ref-a") || WORKTREE,
    b: localStorage.getItem("devtools-ref-b") || refsInfo.default,
  };

  // Nedtrekksliste med arbeidskatalogen/grener/siste commits, pluss «Egen ref …»
  // som bytter til et fritekstfelt (native datalist filtrerer på feltets innhold
  // og skjuler dermed alle forslagene når noe er forhåndsutfylt).
  function refPicker(key, fallback) {
    const select = $(`ref-${key}-select`);
    const input = $(`ref-${key}-input`);
    const CUSTOM = "__egen__";

    select.append(new Option("arbeidskatalogen (med lokale endringer)", WORKTREE));
    const groups = { Grener: refsInfo.branches.map((b) => [b, b]) };
    groups["Siste commits"] = refsInfo.commits.map((c) => [`${c.sha} ${c.subject}`, c.sha]);
    for (const [name, options] of Object.entries(groups)) {
      const group = document.createElement("optgroup");
      group.label = name;
      for (const [text, value] of options) group.append(new Option(text, value));
      select.append(group);
    }
    select.append(new Option("Egen ref …", CUSTOM));
    const known = new Set([WORKTREE, ...refsInfo.branches, ...refsInfo.commits.map((c) => c.sha)]);

    const show = () => {
      const custom = !known.has(refs[key]);
      select.hidden = custom;
      input.hidden = !custom;
      if (custom) input.value = refs[key];
      else select.value = refs[key];
    };

    const apply = (value) => {
      refs[key] = value;
      localStorage.setItem(`devtools-ref-${key}`, value);
      show();
      updateCaptions();
      window.brevPreview.generate();
    };

    select.onchange = () => {
      if (select.value === CUSTOM) {
        select.hidden = true;
        input.hidden = false;
        input.value = "";
        input.focus(); // apply skjer først når noe er skrevet (change ved blur/enter)
      } else {
        apply(select.value);
      }
    };
    input.onchange = () => apply(input.value.trim() || fallback);
    input.onkeydown = (e) => {
      if (e.key === "Enter") input.blur();
      if (e.key === "Escape") {
        input.value = "";
        input.blur();
      }
    };
    show();
  }
  refPicker("a", WORKTREE);
  refPicker("b", refsInfo.default);

  const errB = (message) => ($("caption-b").querySelector(".err").textContent = message || "");
  const panelB = pdfPanel($("pdf-b"), errB);
  const label = (ref) => (ref === WORKTREE ? "arbeidskatalogen (med lokale endringer)" : ref);

  // Klargjør (eller gjenbruker) container for ref-en og gir genpdf-URL-en dit.
  // Ref-en resolves på nytt hver gang, så nye commits på en gren plukkes opp.
  async function target(ref, template) {
    if (ref === WORKTREE) return `/api/genpdf/tpts/${template}`;
    const res = await fetch("/api/ref/prepare", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ ref }),
    });
    if (!res.ok) throw new Error(await res.text());
    return `/api/ref/${(await res.json()).sha}/genpdf/tpts/${template}`;
  }

  function updateCaptions() {
    if (active) {
      window.brevPreview.setMainCaption(label(refs.a));
      $("caption-b").querySelector(".label").textContent = label(refs.b);
    } else {
      // LEGACY PDFGEN: hovedpanelet trenger fortsatt merkelapp når gammel pdfgen vises ved siden av
      window.brevPreview.setMainCaption(window.brevPreview.legacyActive ? "pdfgenrs (ny)" : null);
    }
  }

  function setActive(on) {
    active = on;
    window.brevPreview.compareActive = on;
    $("compare-rs").checked = on;
    $("compare-rs-controls").hidden = !on;
    $("figure-b").hidden = !on;
    window.brevPreview.setMainTarget(on ? (template) => target(refs.a, template) : null);
    updateCaptions();
    localStorage.setItem("devtools-compare-rs", on ? "1" : "");
    window.brevPreview.generate();
  }

  $("compare-rs").onchange = () => setActive($("compare-rs").checked);

  window.brevPreview.onGenerate(async (template, body, { legacyOnly }) => {
    if (!active) return;
    if (legacyOnly) {
      panelB.blank(); // LEGACY PDFGEN: malen finnes ikke i pdfgenrs i det hele tatt
      return;
    }
    try {
      await panelB.load(await target(refs.b, template), body);
    } catch (e) {
      errB(String(e));
    }
  });

  if (localStorage.getItem("devtools-compare-rs") === "1") setActive(true);
})();
