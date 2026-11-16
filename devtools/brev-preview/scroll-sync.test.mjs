import assert from "node:assert/strict";
import { test } from "node:test";
import { synchronizeScroll } from "./scroll-sync.mjs";

class ScrollPane extends EventTarget {
  constructor(scrollHeight, clientHeight) {
    super();
    this.scrollHeight = scrollHeight;
    this.clientHeight = clientHeight;
    this._scrollTop = 0;
  }

  get scrollTop() {
    return this._scrollTop;
  }

  set scrollTop(value) {
    const max = Math.max(0, this.scrollHeight - this.clientHeight);
    const next = Math.max(0, Math.min(value, max));
    if (next === this._scrollTop) return;
    this._scrollTop = next;
    queueMicrotask(() => this.dispatchEvent(new Event("scroll")));
  }
}

test("synchronizes proportional scrolling in both directions without feedback", async () => {
  const first = new ScrollPane(2000, 500);
  const second = new ScrollPane(3000, 500);
  const stop = synchronizeScroll(first, second);

  first.scrollTop = 750;
  await new Promise((resolve) => setTimeout(resolve, 0));
  assert.equal(second.scrollTop, 1250);
  second.scrollTop = 500;
  await new Promise((resolve) => setTimeout(resolve, 0));
  assert.equal(first.scrollTop, 300);

  stop();
  first.scrollTop = 1500;
  await new Promise((resolve) => setTimeout(resolve, 0));
  assert.equal(second.scrollTop, 500);
});

test("moves the other panel to the top when the source has no overflow", () => {
  const first = new ScrollPane(500, 500);
  const second = new ScrollPane(2000, 500);
  const stop = synchronizeScroll(first, second);
  second.scrollTop = 750;

  first.dispatchEvent(new Event("scroll"));

  assert.equal(second.scrollTop, 0);
  stop();
});
