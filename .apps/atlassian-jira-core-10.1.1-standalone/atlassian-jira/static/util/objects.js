function _typeof(o) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (o) { return typeof o; } : function (o) { return o && "function" == typeof Symbol && o.constructor === Symbol && o !== Symbol.prototype ? "symbol" : typeof o; }, _typeof(o); }
/**
 * Utility functions for manipulating objects.
 * @module jira/util/objects
 */
define('jira/util/objects', ['jquery', 'exports'], function ($, exports) {
  'use strict';

  /**
   * Create a new object with prototypal inheritance as per Douglas Crockford's technique.
   * @link http://javascript.crockford.com/prototypal.html
   * @param {Object} obj the object to use as the prototype of the new object
   * @return {*} new object with provided prototype
   */
  exports.begetObject = function begetObject(obj) {
    var F = function F() {};
    F.prototype = obj;
    return new F();
  };

  /**
   * Creates a copy of an object (or array).
   * @param {Object} object - to copy
   * @param {Boolean} deep - weather to copy objects within object
   * @returns copied object
   */
  exports.copyObject = function copyObject(object, deep) {
    var copiedObject = $.isArray(object) ? [] : {};
    $.each(object, function (name, property) {
      if (_typeof(property) !== 'object' || property === null || property instanceof $) {
        copiedObject[name] = property;
      } else if (deep !== false) {
        copiedObject[name] = exports.copyObject(property, deep);
      }
    });
    return copiedObject;
  };
});