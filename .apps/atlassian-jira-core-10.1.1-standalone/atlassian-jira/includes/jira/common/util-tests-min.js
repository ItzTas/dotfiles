function _typeof(e){return _typeof="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&"function"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e},_typeof(e)}AJS.test.require(["jira.webresources:jira-global"],(function(){"use strict";var e=require("jquery");module("Generic Util Tests",{setup:function(){this.sandbox=sinon.sandbox.create();this.$element=e("<input />");e("body").append(this.$element)},teardown:function(){this.$element.remove();this.$element=null;this.sandbox.restore()}});test("jQuery element is focused",(function(){this.$element.focus();ok(AJS.elementIsFocused(this.$element),"jQuery element is focused.")}));test("non jQuery element is focused",(function(){this.$element.focus();ok(AJS.elementIsFocused(this.$element.get(0)),"non jQuery element is focused.")}));test("jQuery element is not focused when blurred",(function(){this.$element.focus();this.$element.blur();ok(!AJS.elementIsFocused(this.$element.get(0)),"non jQuery element is focused.")}));test("JIRA.isSysadmin works correctly",(function(){strictEqual(_typeof(JIRA.isSysadmin()),"boolean");var e=this.sandbox.stub(AJS.Meta,"getBoolean");e.returns(void 0);strictEqual(JIRA.isSysadmin(),!1,"When the meta value is not present, isSysAdmin() should return false.");e.returns(!0);strictEqual(JIRA.isSysadmin(),!0,"When the meta value exists, isSysAdmin() should reflect it.");e.returns(!1);strictEqual(JIRA.isSysadmin(),!1,"When the meta value exists, isSysAdmin() should reflect it.")}));test("[global] addClassName",(function(){var t,o=e("<div id='thing' class='one two'/>").appendTo(e("#qunit-fixture"));addClassName("thing","three");t=e.trim(o.attr("class")).split(" ");equal(t.length,3,"should have three classes");ok(e.inArray("three",t),"the 'three' class should be added")}));test("[global] removeClassName",(function(){var t,o=e("<div id='thing' class='one two'/>").appendTo(e("#qunit-fixture"));removeClassName("thing","three");t=e.trim(o.attr("class")).split(" ");equal(t.length,2,"should still only have two classes");removeClassName("thing","one");t=e.trim(o.attr("class")).split(" ");equal(t.length,1,"should now only have one class");equal(t[0],"two","should only have the 'two' class")}));test("[global] arrayContains",(function(){var e={foo:"bar"},t=[1,2,"3",e,7];equal(arrayContains(t,1),!0,"should contain the number 1");equal(arrayContains(t,"1"),!0,"should contain the string '1', since we're truthy");equal(arrayContains(t,3),!0,"should contain the number 3, since we're truthy");equal(arrayContains(t,"3"),!0,"should contain the string '3'");equal(arrayContains(t,"foo"),!1,"should not contain a string 'foo'");equal(arrayContains(t,e),!0,"should contain the foo object");equal(arrayContains(t,t),!1,"array shouldn't contain itself")}));!function(){module("Test reloadViaWindowLocation",{setup:function(){var e=this.sandbox=sinon.sandbox.create();this.location={href:"http://localhost/somerandom/url",replace:e.stub(),assign:e.stub()}},teardown:function(){this.sandbox.restore()}});test("reloading should replace the URL",(function(){AJS.reloadViaWindowLocation._delegate(null,this.location);ok(this.location.replace.calledWith(this.location.href),"Replaced called with correct URL on reload.");ok(!this.location.assign.called,"Assign should not be called.")}));test("redirect should assign the URL",(function(){var e="http://somethingelse.com";AJS.reloadViaWindowLocation._delegate(e,this.location);ok(this.location.assign.calledWith(e),"Assign called with the correct URL.");ok(!this.location.replace.called,"Replace should not have been called.")}));function e(e,t,o,s,a){AJS.reloadViaWindowLocation._delegate(e,t);ok(s.calledOnce,"Assign called with the correct URL.");var n=s.getCall(0);o.test(n.args[0])?ok(!0,"Redirected URL matches '"+o+"'."):ok(!1,"Redirected URL '"+n.args[0]+"' does not match '"+o+"'.");ok(!a.called,"Replace should not have been called.")}test("redirect should assign the URL and and add cache buster",(function(){e("http://somethingelse.com#jsks",this.location,/http:\/\/somethingelse\.com\?jwupdated=\d+#jsks/,this.location.assign,this.location.replace)}));test("reload should replace the URL and and add cache buster",(function(){this.location.href="http://somethingelse.com#abc";e(null,this.location,/http:\/\/somethingelse\.com\?jwupdated=\d+#abc/,this.location.replace,this.location.assign)}));test("reload should replace the URL and and add cache buster with parameter",(function(){this.location.href="http://somethingelse.com?jack=two#abc";e(null,this.location,/http:\/\/somethingelse\.com\?jwupdated=\d+&jack=two#abc/,this.location.replace,this.location.assign)}));test("redirect should assign the URL and and add cache buster with parameter",(function(){e("http://somethingelse.com?def=abc#jsks",this.location,/http:\/\/somethingelse\.com\?jwupdated=\d+&def=abc#jsks/,this.location.assign,this.location.replace)}));function t(e,t,o,s,a,n){AJS.reloadViaWindowLocation._delegate(e,t);ok(a.calledOnce,"Called with the correct URL.");var i=a.getCall(0),l=o.exec(i.args[0]);if(l){var c=parseInt(l[1]);notEqual(c,s,"Buster number has been updated.")}else ok(!1,"Redirected URL '"+i.args[0]+"' does not match '"+o+"'.");ok(!n.called,"Did not call other function?")}test("redirect should assign the URL and and update cache buster",(function(){t("http://somethingelse.com?def=abc&jwupdated=1#jsks",this.location,/http:\/\/somethingelse\.com\?def=abc&jwupdated=(\d+)#jsks/,1,this.location.assign,this.location.replace)}));test("reload should replace the URL and and update cache buster",(function(){this.location.href="http://somethingelse.com?def=abc&jwupdated=1#jsks";t(null,this.location,/http:\/\/somethingelse\.com\?def=abc&jwupdated=(\d+)#jsks/,1,this.location.replace,this.location.assign)}))}()}));