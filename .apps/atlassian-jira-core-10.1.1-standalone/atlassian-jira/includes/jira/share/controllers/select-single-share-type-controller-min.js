define("jira/share/controllers/select-single-share-type-controller",["jquery"],(function(e){"use strict";function t(){this.shares=new Array;this.shareTypes={};this.singleton=!1}t.prototype={registerShareType:function(e){e&&e.type&&(this.shareTypes[String(e.type)]=e)},initialise:function(){var t,s,n=this;for(t in this.shareTypes)Object.prototype.hasOwnProperty.call(this.shareTypes,t)&&(s=this.shareTypes[t]).initialise&&s.initialise();var a,r=document.getElementById("shares_data_"+this.mode);try{var i=r.firstChild.nodeValue;(a=JSON.parse(i))instanceof Array||(a=[])}catch(e){a=[]}var l=null,o=null;if(0===a.length){l="any";s=this.shareTypes[l];o=null}else{l=a[0].type;s=this.shareTypes[l];o=a[0]}s.updateSelectionFromPermission&&s.updateSelectionFromPermission(o);var y=document.getElementById("share_type_selector");if(y){this.updateShareTypeSelectorList(y,l);e(y).change((function(e){n.selectShareTypeCallback(e)}))}var h=document.getElementById("share_busy");if(h){h.style.display="none";h.parentNode&&h.parentNode.removeChild(h)}(h=document.getElementById("share_div"))&&(h.style.display="")},updateShareTypeSelectorList:function(e,t){for(var s=e.options,n=0,a=0;a<s.length;a++){var r=s[a].value;r===t&&(n=a);document.getElementById("share_"+r).style.display="none"}s[n].selected=!0;var i=document.getElementById("share_"+s[n].value);i&&(i.style.display="")},selectShareTypeCallback:function(){for(var e,t=document.getElementById("share_type_selector"),s=t.options,n=0;n<s.length;n++){var a=document.getElementById("share_"+s[n].value);a&&(n===t.selectedIndex?e=a:a.style.display="none")}e.style.display=""},setWarning:function(e){var t=document.getElementById("share_warning");if(t)if(e.length>0){t.className="aui-message aui-message-warning";t.innerHTML=e}else{t.className="";t.innerHTML=""}}};return t}));