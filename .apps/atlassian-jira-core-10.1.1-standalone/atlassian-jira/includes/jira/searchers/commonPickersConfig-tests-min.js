AJS.test.require(["jira.webresources:searchers"],(function(){"use strict";var e=this;module("commonPickersConfig",{setup:function(){e.commonPickersConfig=require("jira/searchers/element/common-pickers-config")},teardown:function(){}});test("should define default options for pickers",(function(){equal(e.commonPickersConfig.DEFAULT_MAX_RESULTS,100,"`Max results` option is correctly set");equal(e.commonPickersConfig.DEFAULT_START_AT,0,"`Start at` option is correctly set");equal(e.commonPickersConfig.DEFAULT_MAX_RESULTS_PER_GROUP,100,"`Max results` per group option is correctly set")}))}));