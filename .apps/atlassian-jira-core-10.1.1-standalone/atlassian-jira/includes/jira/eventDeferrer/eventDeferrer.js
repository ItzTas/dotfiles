function _createForOfIteratorHelper(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (!it) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = it.call(o); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }
function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }
function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) arr2[i] = arr[i]; return arr2; }
/**
 * This module is responsible for deferring events on elements that have data-queued-click attribute.
 * This can be useful when we want to queue events on elements that are not ready to be clicked yet, e.g. legacy add comment button.
 *
 * Assumptions:
 * - we are only interested in two interactive elements - <a/> and <button/>
 * - we are only interested in elements that have data-queued-click attribute
 * - we are only interested in click events (which can be triggered by keyboard as well)
 */
(function () {
  "use strict";

  var QUEUED_CALLBACK_DATA_ATTRIBUTE = 'data-queued-click';
  /**
   * Only one callback should exist, as we don't want the user to queue multiple events at once
   * and then have them triggered at the same time
   */
  var callbackToDefer;

  /**
   * The element that we want to potentially observe for deferring callbacks.
   *
   * @param event {Event}
   * @returns {Element | null}
   */
  function getInteractiveElement(event) {
    var isInteractive = ['A', 'BUTTON'].some(function (tagName) {
      return event.target.tagName === tagName;
    });
    if (isInteractive) {
      return event.target;
    }
    return event.target.closest('a, button');
  }
  function triggerCallback() {
    callbackToDefer && callbackToDefer();
    callbackToDefer = null;
  }

  /**
   * Observes elements and triggers the callback only when other piece of code removes the {@link QUEUED_CALLBACK_DATA_ATTRIBUTE} attribute.
   *
   * @type {MutationObserver}
   */
  var mutationObserver = new MutationObserver(function (mutationsList, observer) {
    var _iterator = _createForOfIteratorHelper(mutationsList),
      _step;
    try {
      for (_iterator.s(); !(_step = _iterator.n()).done;) {
        var mutation = _step.value;
        if (mutation.type === 'attributes' && !mutation.target.hasAttribute(QUEUED_CALLBACK_DATA_ATTRIBUTE)) {
          triggerCallback();
          observer.disconnect();
        }
      }
    } catch (err) {
      _iterator.e(err);
    } finally {
      _iterator.f();
    }
  });
  function disconnectObserver() {
    callbackToDefer = null;
    mutationObserver.disconnect();
  }

  /**
   * The main piece of logic.
   * If we don't detect interactive element with {@link QUEUED_CALLBACK_DATA_ATTRIBUTE} attribute, we don't do anything.
   * Otherwise, we prevent the default action and stop the propagation of the event, store the callback to defer and start observing the element.
   * When the element gets rid of {@link QUEUED_CALLBACK_DATA_ATTRIBUTE}, we trigger the callback and disconnect the observer.
   *
   * @param event
   */
  var clickHandler = function clickHandler(event) {
    disconnectObserver();
    var interactiveElement = getInteractiveElement(event);
    // check event target and closest element for data-queued-click
    var shouldDeferEventCallback = interactiveElement && interactiveElement.dataset.hasOwnProperty('queuedClick');
    if (!shouldDeferEventCallback) {
      return;
    }
    event.preventDefault();
    event.stopPropagation();
    callbackToDefer = function callbackToDefer() {
      return interactiveElement.click();
    };
    document.body.addEventListener('keydown', disconnectObserver, {
      once: true,
      passive: true,
      capture: true
    });
    mutationObserver.observe(interactiveElement, {
      attributes: true
    });
  };
  document.addEventListener('click', clickHandler, true);
  window.resourcePhaseCheckpoint.interaction.then(function () {
    // We delegate the callback to the next tick, so that the code that loads together with interaction phase
    // triggers first, and then we can trigger the callback and disconnect the event deferrer.
    setTimeout(function () {
      document.removeEventListener('click', clickHandler, true);
      triggerCallback();
      disconnectObserver();
    });
  });
})();