define("jira/util/browser",["jira/util/key-code","jira/util/elements","aui/params","jquery","exports"],(function(e,t,n,a,o){"use strict";o.canAccessIframe=function(e){var t=a(e);return!/^(http|https):\/\//.test(t.attr("src"))||n.baseURL&&0===a.trim(t.attr("src")).indexOf(n.baseURL)};function r(n){var o=n.keyCode,r=e;if("keypress"!==n.type&&(o===r.DOWN||o===r.UP||o===r.LEFT||o===r.RIGHT)){var i=a(n.target);i.hasClass("scrollable")||t.consumesKeyboardEvents(i)||n.preventDefault()}}o.disableKeyboardScrolling=function(){a(document.body).bind("keydown",r)};o.enableKeyboardScrolling=function(){a(document.body).unbind("keydown",r)};o.isSelenium=function(){return window.name.toLowerCase().indexOf("selenium")>=0};o.reloadViaWindowLocation=function(e){o.reloadViaWindowLocation._delegate(e,window.location)};o.reloadViaWindowLocation._delegate=(i=/(jwupdated=[0-9]*)/,c=function(e){if(-1===e.indexOf("#"))return e;var t,n,a,o=e.indexOf("?"),r="".concat("jwupdated","=").concat((t=new Date,n=new Date(t.getFullYear(),t.getMonth(),t.getDate(),0,0,0,0),a=(t.getTime()-n.getTime())/1e3,Math.max(Math.floor(a),1)));return e=-1===o?e.replace("#","?".concat(r,"#")):i.test(e)?e.replace(i,r):e.replace("?","?".concat(r,"&"))},function(e,t){var n=e||t.href,a=c(n);n===t.href?t.replace(a):t.assign(a)});var i,c}));