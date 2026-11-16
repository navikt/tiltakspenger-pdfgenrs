export function synchronizeScroll(first, second) {
  const expectedScrollTop = new WeakMap();

  function sync(source, target) {
    const expected = expectedScrollTop.get(source);
    expectedScrollTop.delete(source);
    if (expected !== undefined && Math.abs(source.scrollTop - expected) < 1) return;

    const sourceRange = Math.max(0, source.scrollHeight - source.clientHeight);
    const targetRange = Math.max(0, target.scrollHeight - target.clientHeight);
    // Prosentvis synk treffer ikke samme side når dokumentene har ulikt sidetall; bruk sideankre hvis det blir viktig.
    const progress = sourceRange ? Math.max(0, Math.min(1, source.scrollTop / sourceRange)) : 0;
    const nextScrollTop = progress * targetRange;
    if (Math.abs(target.scrollTop - nextScrollTop) < 1) return;

    expectedScrollTop.set(target, nextScrollTop);
    target.scrollTop = nextScrollTop;
  }

  const syncFirst = () => sync(first, second);
  const syncSecond = () => sync(second, first);
  first.addEventListener("scroll", syncFirst, { passive: true });
  second.addEventListener("scroll", syncSecond, { passive: true });

  return () => {
    first.removeEventListener("scroll", syncFirst);
    second.removeEventListener("scroll", syncSecond);
  };
}
