define("jira/project/browse/categorycollection",["jira/backbone-1.3.3"],(function(e){"use strict";return e.Collection.extend({unselect:function(){this.filter((function(e){return e.get("selected")})).forEach((function(e){e.set("selected",!1,{silent:!0})}))},getSelected:function(){return this.find((function(e){return e.get("selected")}))},selectCategory:function(e){var t=this.get(e);if(!t)return!1;this.unselect();t.set("selected",!0);return t}})}));