define("jira/shifter/shifter-controller",["jira/lib/class","jira/shifter/shifter-dialog","jira/shifter/shifter-analytics","underscore"],(function(i,t,r,e){"use strict";return i.extend({MAX_RESULTS_PER_GROUP:5,init:function(i){this.id=i;this.groupFactories=[]},register:function(i){this.groupFactories.push(i);return i},unregister:function(i){this.groupFactories=e.without(this.groupFactories,i);return i},show:function(){r.show();if(!this.dialog||this.dialog.destroyed()){var i=e.chain(this.groupFactories).map((function(i){return i()})).compact().flatten().value().sort((function(i,t){return i.weight-t.weight}));this.dialog=new t(this.id,i,{maxResultsDisplayedPerGroup:this.MAX_RESULTS_PER_GROUP})}this.dialog.focus()},hide:function(){this.dialog&&this.dialog.destroy()}})}));AJS.namespace("JIRA.ShifterComponent.ShifterController",window,require("jira/shifter/shifter-controller"));