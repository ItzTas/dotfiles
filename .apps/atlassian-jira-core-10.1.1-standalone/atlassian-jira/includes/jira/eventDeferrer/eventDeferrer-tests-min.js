AJS.test.require(["jira.webresources:event-deferrer"],(function(){"use strict";module("eventDeferrer");function e(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"a",t=document.createElement(e);document.getElementById("qunit-fixture").appendChild(t);return t}test("blocks default behaviour of anchor element when it hasn't loaded its inline functionality yet",(function(){var t=e("a");t.href="#";t.dataset.queuedClick="";t.click();ok(!window.location.href.endsWith("#"),"Should have blocked the default behaviour of the anchor element")}));test("does not block button if it does not have data-queued-click attribute",(function(){var t=sinon.spy(),n=e("button");n.addEventListener("click",t);n.click();ok(t.called,"Should not block the default behaviour of the button element")}));test("triggers callback when data-queued-click attribute is removed",(function(t){var n=t.async(),i=sinon.spy(),c=e("a");c.dataset.queuedClick="";c.addEventListener("click",i);c.click();c.removeAttribute("data-queued-click");setTimeout((function(){t.ok(i.called,"Should trigger callback when data-queued-click attribute is removed");n()}),10)}));test("does not trigger callback if user interacted with other element",(function(t){var n=t.async(),i=sinon.spy(),c=e("a");c.dataset.queuedClick="";c.addEventListener("click",i);c.click();document.body.click();c.removeAttribute("data-queued-click");setTimeout((function(){t.ok(!i.called,"Should not trigger callback if user interacted with other element");n()}),10)}));test("does not trigger callback if user pressed key",(function(t){var n=t.async(),i=sinon.spy(),c=e("a");c.dataset.queuedClick="";c.addEventListener("click",i);c.click();var a=new KeyboardEvent("keydown",{key:"Enter"});document.body.dispatchEvent(a);c.removeAttribute("data-queued-click");setTimeout((function(){t.ok(!i.called,"Should not trigger callback if user pressed key");n()}),10)}))}));