!function(e){e.event.special.simpleClick={add:function(c){c._clickHandler=function(e){if(!e.ctrlKey&&!e.metaKey&&!e.shiftKey)return c.handler.apply(this,arguments)};e(this).on("click",c.selector,c._clickHandler)},remove:function(c){e(this).off("click",c.selector,c._clickHandler)}}}(jQuery);