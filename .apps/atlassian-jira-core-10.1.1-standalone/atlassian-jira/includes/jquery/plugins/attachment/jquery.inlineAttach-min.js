define("jira/jquery/plugins/attachment/inline-attach",["jira/attachment/inline-attach","jquery"],(function(n,t){t.fn.inlineAttach=function(){var t=[];this.each((function(){t.push(new n(this))}));return t};return t.fn.inlineAttach}));require("jira/jquery/plugins/attachment/inline-attach");