// =============================================================================
// status_badge.js — Custom Shiny message handler for streaming/idle badges
// Created: 2026-06-19
// Purpose: Receives {id, status} messages from the server and swaps the CSS
//          class on the badge element between .status-idle and .status-streaming.
//          This is faster than renderUI for frequent state toggling.
// =============================================================================

Shiny.addCustomMessageHandler("update_status_badge", function(msg) {
  // msg = { id: "<element-id>", status: "streaming" | "idle" }
  var el = document.getElementById(msg.id);
  if (!el) return;

  // Remove both state classes then apply the current one.
  el.classList.remove("status-idle", "status-streaming");
  el.classList.add("status-" + msg.status);

  // Update the visible label text (keep the dot span, replace trailing text).
  var dot = el.querySelector(".status-dot");
  // Clear children text nodes, preserve the dot element.
  while (el.lastChild && el.lastChild !== dot) {
    el.removeChild(el.lastChild);
  }
  // Append updated label as a text node after the dot.
  var label = msg.status.charAt(0).toUpperCase() + msg.status.slice(1);
  el.appendChild(document.createTextNode(" " + label));
});
