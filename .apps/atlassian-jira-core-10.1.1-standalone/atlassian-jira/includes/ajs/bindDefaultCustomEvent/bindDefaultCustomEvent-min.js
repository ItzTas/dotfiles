define("jira/ajs/default-custom-event",["jquery","exports"],(function(e,n){"use strict";var t={};n.bind=function(n,u){if(t[n])throw new Error("You have already bound a default handler for ["+n+"] event");t[n]=function t(a){var i=e(document).data("events")[n],l=i[i.length-1].handler;if(l!==t){a.preventDefault=function(){u=null};i[i.length-1].handler=function(){l.apply(this,arguments);u&&u.apply(this,arguments);i[i.length-1].handler=l}}else u.apply(this,arguments)};e(document).bind(n,t[n])};n.unbind=function(n){if(t[n]){e(document).unbind(n,t[n]);delete t[n]}}}));AJS.namespace("AJS.bindDefaultCustomEvent",null,require("jira/ajs/default-custom-event").bind);AJS.namespace("AJS.unbindDefaultCustomEvent",null,require("jira/ajs/default-custom-event").unbind);