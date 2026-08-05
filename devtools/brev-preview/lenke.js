// Delbar lenke til et bestemt brev med bestemt innhold.
//
// Alt ligger i fragmentet (#brev=…&data=…), som aldri sendes til serveren:
// flettedataene inneholder syntetiske fødselsnumre og har ingenting i en
// accesslogg å gjøre. Lenken er selvbærende — hele payloaden ligger i den, ikke
// en diff mot data/tpts — så en gammel lenke viser det samme brevet selv om
// testdatasettet endrer seg senere.
//
// Flettedataene tas bare med når de er endret; ellers er lenken kort og peker
// på datasettet slik det står i repoet.

// Base64url uten padding, så URL-en tåler å bli limt inn hvor som helst.
const tilBase64 = (bytes) =>
  btoa(String.fromCharCode(...bytes)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

const fraBase64 = (tekst) => Uint8Array.from(atob(tekst.replace(/-/g, "+").replace(/_/g, "/")), (c) => c.charCodeAt(0));

async function pakk(tekst) {
  const strøm = new Blob([tekst]).stream().pipeThrough(new CompressionStream("gzip"));
  return tilBase64(new Uint8Array(await new Response(strøm).arrayBuffer()));
}

async function pakkUt(pakket) {
  const strøm = new Blob([fraBase64(pakket)]).stream().pipeThrough(new DecompressionStream("gzip"));
  return await new Response(strøm).text();
}

// {brev, data, feil} fra fragmentet. Kaster ikke: en ødelagt «data»-del skal ikke
// ta brevvalget med seg i fallet, så da vises datasettet med en beskjed om hvorfor.
async function lesLenke() {
  const params = new URLSearchParams(location.hash.slice(1));
  const brev = params.get("brev");
  if (!brev) return null;
  const pakket = params.get("data");
  if (!pakket) return { brev, data: null };
  try {
    return { brev, data: JSON.parse(await pakkUt(pakket)) };
  } catch (e) {
    // Feilen fra DecompressionStream er «Failed to fetch», som leder tanken til
    // nettverket. Den sier vi ikke videre - årsaken er uansett en ødelagt lenke.
    return { brev, data: null, feil: "Flettedataene i lenken kunne ikke leses; lenken er trolig avkortet. Viser datasettet i stedet." };
  }
}

async function byggLenke(brev, data, endret) {
  const params = new URLSearchParams({ brev });
  if (endret) params.set("data", await pakk(JSON.stringify(data)));
  return `${location.origin}${location.pathname}#${params}`;
}

// Holder adressefeltet i takt med det som vises, uten å fylle opp historikken.
async function skrivLenke(brev, data, endret) {
  history.replaceState(null, "", await byggLenke(brev, data, endret));
}
