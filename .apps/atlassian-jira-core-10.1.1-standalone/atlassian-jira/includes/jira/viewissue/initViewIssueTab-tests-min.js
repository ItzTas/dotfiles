AJS.test.require(["jira.webresources:viewissue-tabs"],(function(){"use strict";var t=require("jquery");module("initViewIssueTab with feature flag turned off",{setup:function(){this.sandbox=sinon.sandbox.create();this.context=AJS.test.mockableModuleContext();this.context.mock("jira/featureflags/feature-manager",{isFeatureEnabled:function(){return!1}});this.fetchSpy=sinon.stub(window,"fetch").returns(Promise.resolve({text:function(){return"<div>TEST</div>"}}));this.initViewIssueTab=this.context.require("jira/viewissue/tabs/initTab")},teardown:function(){this.sandbox.restore();window.fetch.restore();this.isFeatureEnabled=!0}});test("should set is-ready attribute if feature flag is turned off",(function(e){e.expect(1);var i=e.async(),n=t('<div id="activitymodule"><div id="activity-panel-placeholder"></div></div>');this.initViewIssueTab({},n).then((function(){equal(n.data("is-ready"),!0);i()}))}));test("should not fetch data if feature flag is turned off",(function(e){var i=this;e.expect(1);var n=e.async(),s=t('<div id="activitymodule"><div id="activity-panel-placeholder"></div></div>');this.initViewIssueTab({},s).then((function(){sinon.assert.notCalled(i.fetchSpy);n()}))}));module("initViewIssueTab with feature flag turned on",{setup:function(){this.sandbox=sinon.sandbox.create();this.context=AJS.test.mockableModuleContext();this.context.mock("jira/featureflags/feature-manager",{isFeatureEnabled:function(){return!0}});this.fetchSpy=sinon.stub(window,"fetch").returns(Promise.resolve({text:function(){return"<div>TEST</div>"}}));this.initViewIssueTab=this.context.require("jira/viewissue/tabs/initTab")},teardown:function(){this.sandbox.restore();window.fetch.restore()}});test("should not fetch data if placeholder element is not present",(function(e){var i=this;e.expect(1);var n=e.async(),s=t('<div id="activitymodule"></div>');this.initViewIssueTab({},s).then((function(){sinon.assert.notCalled(i.fetchSpy);n()}))}));test("should fetch data if placeholder element is present and is-ready data attribute is not set",(function(e){var i=this;e.expect(1);var n=e.async(),s=t('<div id="activitymodule"><div id="activity-panel-placeholder"></div><div class="mod-content"></div></div>');this.initViewIssueTab({},s).then((function(){sinon.assert.calledOnce(i.fetchSpy);n()}))}));test("should not fetch data if placeholder element is present and is-ready data attribute is set",(function(e){var i=this;e.expect(1);var n=e.async(),s=t('<div id="activitymodule" data-is-ready="true"><div id="activity-panel-placeholder"></div><div class="mod-content"></div></div>');this.initViewIssueTab({},s).then((function(){sinon.assert.notCalled(i.fetchSpy);n()}))}))}));