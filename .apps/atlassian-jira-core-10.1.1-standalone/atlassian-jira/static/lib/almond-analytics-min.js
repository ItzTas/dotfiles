!function(){var e,t=[],a=function(){var e=window.location.pathname;return e=(e=e.replace(/(projects?|issues?|browse)\/[A-Z][A-Z0-9]+\-\d+(.*|$)/gi,"$1/ISSUEKEY$2")).replace(/(projects?|issues?|browse)\/[A-Z][A-Z0-9](\/|$)/gi,"$1/PROJECTKEY$2")}();if("function"==typeof require.analytics){var n=document.querySelector("meta[name=ajs-enabled-dark-features]");if((n=n&&n.getAttribute("content")||"")&&-1!==n.indexOf("amd.loader.analytics.enabled")){e=require.analytics;require.analytics=function(e,n,r){var i={path:a,moduleName:n,deps:r,afterDomReady:"interactive"===document.readyState||"complete"===document.readyState};t.push({name:"amd.loader."+e,properties:i})};setTimeout((function(){if(AJS&&void 0!==AJS.EventQueue){for(var a=0,n=t.length;a<n;a++)AJS.EventQueue.push(t[a]);t=AJS.EventQueue}else{t.length=0;require.analytics=e}}),5e3)}}}();