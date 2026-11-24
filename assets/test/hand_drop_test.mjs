import assert from "node:assert/strict";
import test from "node:test";
import { getHandDropTarget } from "../js/hand_drop.mjs";

function handWithHits(hitTest) {
  const table = {matches: () => false, closest: () => null};
  const hand = {
    matches: () => false,
    closest: selector => selector === "#container" ? table : null,
    ownerDocument: {elementsFromPoint: (x, y) => hitTest(hand, table, x, y)},
  };
  return hand;
}

test("cancellation and missing release coordinates never produce a drop", () => {
  const hand = handWithHits(() => assert.fail("unexpected hit test"));
  for (const type of ["touchcancel", "pointercancel"]) {
    assert.equal(getHandDropTarget(hand, {type, clientX: 18, clientY: 24}), null);
  }
  assert.equal(getHandDropTarget(hand, {type: "pointerup"}), null);
});

test("drops on a menu or outside the game are ignored", () => {
  const menu = {
    matches: () => false,
    closest: selector => selector.includes(".top-right-container") ? menu : null,
  };
  const release = {type: "pointerup", clientX: 18, clientY: 24};
  assert.equal(getHandDropTarget(handWithHits((hand, table) => [menu, hand, table]), release), null);
  assert.equal(getHandDropTarget(handWithHits(() => []), release), null);
});

test("touch releases inside the hand sort, while mouse releases on the table discard", () => {
  const hand = handWithHits((hand, table, x, y) => {
    assert.deepEqual([x, y], [18, 24]);
    return [hand, table];
  });
  assert.equal(getHandDropTarget(hand, {type: "touchend", changedTouches: [{clientX: 18, clientY: 24}]}), "hand");
  const table = handWithHits((_hand, table) => [table]);
  assert.equal(getHandDropTarget(table, {type: "mouseup", clientX: 18, clientY: 24}), "table");
});
