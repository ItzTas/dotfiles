AJS.test.require(["jira.webresources:event-deferrer"], function () {
  'use strict';

  module("eventDeferrer");
  function createInteractiveElement() {
    var tagName = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : "a";
    var element = document.createElement(tagName);
    var fixture = document.getElementById("qunit-fixture");
    fixture.appendChild(element);
    return element;
  }
  test("blocks default behaviour of anchor element when it hasn't loaded its inline functionality yet", function () {
    var element = createInteractiveElement("a");
    element.href = "#";
    element.dataset.queuedClick = "";
    element.click();
    ok(!window.location.href.endsWith('#'), "Should have blocked the default behaviour of the anchor element");
  });
  test("does not block button if it does not have data-queued-click attribute", function () {
    var spy = sinon.spy();
    var element = createInteractiveElement("button");
    element.addEventListener("click", spy);
    element.click();
    ok(spy.called, "Should not block the default behaviour of the button element");
  });
  test("triggers callback when data-queued-click attribute is removed", function (assert) {
    var done = assert.async();
    var spy = sinon.spy();
    var element = createInteractiveElement("a");
    element.dataset.queuedClick = "";
    element.addEventListener("click", spy);
    element.click();
    element.removeAttribute("data-queued-click");
    setTimeout(function () {
      assert.ok(spy.called, "Should trigger callback when data-queued-click attribute is removed");
      done();
    }, 10);
  });
  test("does not trigger callback if user interacted with other element", function (assert) {
    var done = assert.async();
    var spy = sinon.spy();
    var element = createInteractiveElement("a");
    element.dataset.queuedClick = "";
    element.addEventListener("click", spy);
    element.click();
    document.body.click();
    element.removeAttribute("data-queued-click");
    setTimeout(function () {
      assert.ok(!spy.called, "Should not trigger callback if user interacted with other element");
      done();
    }, 10);
  });
  test("does not trigger callback if user pressed key", function (assert) {
    var done = assert.async();
    var spy = sinon.spy();
    var element = createInteractiveElement("a");
    element.dataset.queuedClick = "";
    element.addEventListener("click", spy);
    element.click();
    var event = new KeyboardEvent("keydown", {
      key: "Enter"
    });
    document.body.dispatchEvent(event);
    element.removeAttribute("data-queued-click");
    setTimeout(function () {
      assert.ok(!spy.called, "Should not trigger callback if user pressed key");
      done();
    }, 10);
  });
});