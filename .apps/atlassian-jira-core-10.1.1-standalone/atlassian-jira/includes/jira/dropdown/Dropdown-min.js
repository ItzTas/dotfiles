define("jira/dropdown",["require"],(function(i){"use strict";var o=i("jira/util/top-same-origin-window")(window),n=i("jira/ajs/layer/layer-interactions"),e=i("jquery"),t=i("jira/util/key-code"),d=[];var r={current:null,addInstance:function(){d.push(this)},hideInstances:function(){var i=this;e(d).each((function(){i!==this&&this.hideDropdown()}))},getHash:function(){this.hash||(this.hash={container:this.dropdown,hide:this.hideDropdown,show:this.displayDropdown});return this.hash},displayDropdown:function(){if(this.current!==this){this.hideInstances();this.current=this;this.dropdown.css({display:"block"});this.displayed=!0;var i=this.dropdown;(function(){try{return Boolean(o.require("jira/dialog/dialog").current)}catch(i){}return!1})()||setTimeout((function(){var o=e(window),n=i.offset().top+i.prop("offsetHeight")-o.height()+10;o.scrollTop()<n&&e("html,body").animate({scrollTop:n},300,"linear")}),100)}},hideDropdown:function(){if(!1!==this.displayed){this.current=null;this.dropdown.css({display:"none"});this.displayed=!1}},init:function(i,o){var n=this;this.addInstance(this);this.dropdown=e(o);this.dropdown.css({display:"none"});e(document).keydown((function(i){i.keyCode===t.TAB&&n.hideDropdown()}));if(i.target)e.aop.before(i,(function(){n.displayed||n.displayDropdown()}));else{n.dropdown.css("top",e(i).outerHeight()+"px");i.click((function(i){if(n.displayed)n.hideDropdown();else{n.displayDropdown();i.stopPropagation()}i.preventDefault()}))}e(document.body).click((function(){n.displayed&&n.hideDropdown()}))}};n.preventDialogHide(r);n.hideBeforeDialogShown(r);return r}));AJS.namespace("JIRA.Dropdown",null,require("jira/dropdown"));AJS.namespace("jira.widget.dropdown",null,require("jira/dropdown"));