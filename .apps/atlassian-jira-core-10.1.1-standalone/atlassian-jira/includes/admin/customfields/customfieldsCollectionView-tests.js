AJS.test.require(['jira.webresources:viewcustomfields'], function () {
  'use strict';

  var CustomfieldsCollectionView = require('jira/customfields/customfieldCollectionView');
  var analytics = require('jira/analytics');
  module('CustomfieldsCollectionView', {
    setup: function setup() {
      this.sandbox = sinon.sandbox.create();
      this.sandbox.spy(analytics, 'send');
    },
    teardown: function teardown() {
      this.sandbox.restore();
    }
  });
  test('Sends analytics event', function () {
    var _CustomfieldsCollecti = new CustomfieldsCollectionView(),
      sendSortingAnalyticsEvent = _CustomfieldsCollecti.sendSortingAnalyticsEvent;
    function stripTime(obj) {
      delete obj.time;
      return obj;
    }
    sendSortingAnalyticsEvent('issues', 'ascending');
    deepEqual(stripTime(analytics.send.lastCall.args[0]), {
      name: 'administration.customfields.sorted',
      properties: {
        sortColumn: 'issues',
        sortOrder: 'ascending'
      }
    }, 'Sends strings');
    sendSortingAnalyticsEvent(null, "");
    deepEqual(stripTime(analytics.send.lastCall.args[0]), {
      name: 'administration.customfields.sorted',
      properties: {
        sortColumn: 'none',
        sortOrder: 'none'
      }
    }, 'Handles falsy values');
  });
});