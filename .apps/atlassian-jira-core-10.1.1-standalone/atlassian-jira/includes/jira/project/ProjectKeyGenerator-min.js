define("jira/util/strings/character-map",(function(){"use strict";var e={199:"C",231:"c",252:"u",251:"u",250:"u",249:"u",233:"e",234:"e",235:"e",232:"e",226:"a",228:"a",224:"a",229:"a",225:"a",239:"i",238:"i",236:"i",237:"i",196:"A",197:"A",201:"E",230:"ae",198:"Ae",244:"o",246:"o",242:"o",243:"o",220:"U",255:"Y",214:"O",241:"n",209:"N"};return e}));define("jira/project/project-key-generator",["jira/util/strings/character-map","jira/lib/class","jquery","underscore"],(function(e,t,r,n){"use strict";var i=["THE","A","AN","AS","AND","OF","OR"];return t.extend({init:function(e){e=r.extend({},e);this.desiredKeyLength="number"==typeof e.desiredKeyLength?e.desiredKeyLength:4;this.maxKeyLength="number"==typeof e.maxKeyLength?e.maxKeyLength:0},generateKey:function(t){if(!(t=r.trim(t)))return"";for(var a=[],s=0,h=t.length;s<h;s++){var u=e[t.charCodeAt(s)];a.push(u||t[s])}t=a.join("");var c,o=[];r.each(t.split(/\s+/),(function(e,t){t&&(t=(t=t.replace(/[^a-zA-Z]/g,"")).toUpperCase()).length&&o.push(t)}));this.desiredKeyLength&&function(e){return e.join("").length}(o)>this.desiredKeyLength&&(o=function(e){return n.reject(e,(function(e){return-1!==r.inArray(e,i)}))}(o));if(0===o.length)c="";else if(1===o.length){var g=o[0];c=this.desiredKeyLength&&g.length>this.desiredKeyLength?function(e){var t,r,n=!1;for(t=0;t<e.length;t++)if((r=e[t])&&1===r.length&&-1!==r.search("[AEIOUY]"))n=!0;else if(n)return e.substring(0,t+1);return e}(g):g}else c=function(e){var t="";r.each(e,(function(e,r){t+=r.charAt(0)}));return t}(o);this.maxKeyLength&&c.length>this.maxKeyLength&&(c=c.substr(0,this.maxKeyLength));return c}})}));AJS.namespace("JIRA.ProjectKeyGenerator",null,require("jira/project/project-key-generator"));