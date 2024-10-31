AJS.test.require(['jira.webresources:user-can-attach-info'], function () {
  'use strict';

  var canAttachManager = require('jira/attachments/can-attach-manager');
  var wrmContextPath = require('wrm/context-path');
  var $ = require('jquery');
  module('CanAttachManager', {
    setup: function setup() {},
    tearDown: function tearDown() {},
    beforeEach: function beforeEach() {
      this.originalAjax = $.ajax;
      this.ajaxStub = function () {
        // This function will later be replaced with the custom implementation for each test case.
      };
      $.ajax = this.ajaxStub;
    },
    afterEach: function afterEach() {
      $.ajax = this.originalAjax;
    }
  });
  test('canAttach() should return true when API response is true', function () {
    var projectKey = 'TEST';
    this.ajaxStub = function (options) {
      if (options.url === wrmContextPath() + '/rest/internal/2/attachment-permission/attach?projectKey=' + encodeURIComponent(projectKey)) {
        options.success(true);
      }
    };
    $.ajax = this.ajaxStub;
    var promise = canAttachManager.canAttach(projectKey);
    promise.then(function (result) {
      equal(result, true, 'canAttach() returns true');
      start();
    }, function () {
      ok(false, 'Promise should not be rejected');
      start();
    });
    stop();
  });
  test('canAttach() should return false when API response is false', function () {
    var projectKey = 'TEST';
    this.ajaxStub = function (options) {
      if (options.url === wrmContextPath() + '/rest/internal/2/attachment-permission/attach?projectKey=' + encodeURIComponent(projectKey)) {
        options.success(false);
      }
    };
    $.ajax = this.ajaxStub;
    var promise = canAttachManager.canAttach(projectKey);
    promise.then(function (result) {
      equal(result, false, 'canAttach() returns false');
      start();
    }, function () {
      ok(false, 'Promise should not be rejected');
      start();
    });
    stop();
  });
  test('canAttach() should return false when there is an error in the API call', function () {
    var projectKey = 'TEST';
    this.ajaxStub = function (options) {
      if (options.url === wrmContextPath() + '/rest/internal/2/attachment-permission/attach?projectKey=' + encodeURIComponent(projectKey)) {
        options.error();
      }
    };
    $.ajax = this.ajaxStub;
    var promise = canAttachManager.canAttach(projectKey);
    promise.then(function (result) {
      equal(result, false, 'canAttach() returns false');
      start();
    }, function () {
      ok(false, 'Promise should not be rejected');
      start();
    });
    stop();
  });
  test('canAttach() should return false when projectKey is not provided', function () {
    var promise = canAttachManager.canAttach();
    promise.then(function (result) {
      equal(result, false, 'canAttach() returns false when projectKey is not provided');
      start();
    }, function () {
      ok(false, 'Promise should not be rejected');
      start();
    });
    stop();
  });
});