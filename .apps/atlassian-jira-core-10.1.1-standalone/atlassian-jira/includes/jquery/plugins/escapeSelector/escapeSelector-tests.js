function _typeof(o) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (o) { return typeof o; } : function (o) { return o && "function" == typeof Symbol && o.constructor === Symbol && o !== Symbol.prototype ? "symbol" : typeof o; }, _typeof(o); }
AJS.test.require(["jira.webresources:jquery-escape-selector-polyfill"], function () {
  'use strict';

  module("jQuery escapeSelector", {});
  var jQuery = require("jquery");
  test('Test $.escapeSelector presence', function () {
    equal(_typeof(jQuery.escapeSelector), "function", "jQuery.escapeSelector present");
  });
  test('Test escaping CSS selector via jQuery function', function () {
    equal(jQuery.escapeSelector("#dot.dot"), "\\#dot\\.dot", "jQuery.escapeSelector function properly");
  });
});