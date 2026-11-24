const releaseEvents = new Set(["pointerup", "mouseup", "touchend"]);

export function getHandDropTarget(hand, event) {
  if (!releaseEvents.has(event?.type)) return null;

  const {clientX, clientY} = event.changedTouches?.[0] || event;
  if (!Number.isFinite(clientX) || !Number.isFinite(clientY)) return null;

  const elements = hand.ownerDocument.elementsFromPoint(clientX, clientY);
  if (!elements.includes(hand.closest("#container")) || elements.some(elem =>
    elem.matches("button, label, input, select, textarea, a") ||
    elem.closest(".top-right-container, .rules-wrapper, .messages-outer-container")
  )) return null;

  return elements.includes(hand) ? "hand" : "table";
}
