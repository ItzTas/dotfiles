define("jira/ajs/layer/inline-layer-factory",["jira/ajs/layer/inline-layer","jira/util/objects","jquery","exports"],(function(e,n,t,r){"use strict";r.createInlineLayers=function(r){var i=[];if(r.content){r.content=t(r.content);t.each(r.content,(function(){var a=n.copyObject(r);a.content=t(this);i.push(new e(a))}))}return 1===i.length?i[0]:i}}));