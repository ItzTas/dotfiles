function _toConsumableArray(arr) { return _arrayWithoutHoles(arr) || _iterableToArray(arr) || _unsupportedIterableToArray(arr) || _nonIterableSpread(); }
function _nonIterableSpread() { throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }
function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }
function _iterableToArray(iter) { if (typeof Symbol !== "undefined" && iter[Symbol.iterator] != null || iter["@@iterator"] != null) return Array.from(iter); }
function _arrayWithoutHoles(arr) { if (Array.isArray(arr)) return _arrayLikeToArray(arr); }
function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) arr2[i] = arr[i]; return arr2; }
AJS.test.require(["jira.webresources:jquery-plugin-shortener"], function () {
  'use strict';

  var Shortener = require('jira/ajs/shorten/shortener');
  var element;
  module("Shortener", {
    setup: function setup() {
      element = createMarkup();
      document.querySelector('#qunit-fixture').appendChild(element);
      document.querySelector('#qunit-fixture').style.top = 'auto';
      document.querySelector('#qunit-fixture').style.left = 'auto';
    },
    teardown: function teardown() {
      element.remove();
    }
  });
  test('should render only one expand button when called multiple times', function () {
    var options = {
      element: element
    };
    new Shortener(options);
    equal(getAllExpanders().length, 1, 'short expand');
    equal(getAllBreakLines().length, 1, 'br');
    new Shortener({
      element: getExpander()
    });
    equal(getAllExpanders().length, 1, 'short expand');
    equal(getAllBreakLines().length, 1, 'br');
  });
  test('should show proper count of hidden items when called multiple times', function () {
    var options = {
      element: element
    };
    new Shortener(options);
    equal(document.querySelector('.shortener-expand').textContent, '(9)', 'short expand');
    new Shortener({
      element: getExpander()
    });
    equal(document.querySelector('.shortener-expand').textContent, '(9)', 'short expand');
  });
  function getAllBreakLines() {
    return document.querySelectorAll('br');
  }
  function getAllExpanders() {
    return document.querySelectorAll('.shortener-expand');
  }
  function getExpander() {
    return document.querySelector('.shortener-expand');
  }
  function createMarkup() {
    var wrapper = document.createElement('div');
    wrapper.classList.add('shorten');
    _toConsumableArray(Array(5)).map(function () {
      return wrapper.appendChild(document.createElement('span'));
    });
    _toConsumableArray(Array(5)).map(function () {
      return wrapper.appendChild(document.createElement('a'));
    });
    var expander = document.createElement('a');
    expander.classList.add('shortener-expand');
    wrapper.appendChild(expander);
    return wrapper;
  }
});