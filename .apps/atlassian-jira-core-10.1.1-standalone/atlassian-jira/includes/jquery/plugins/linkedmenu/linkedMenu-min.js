!function(e){e.deactivateLinkedMenu=function(){};e.linkedMenuInstances=[];e.fn.linkedMenu=function(n){var o,u,i=this,s=!1,t=function(n){n=e(n);i.blur();n.trigger("click","focus","mousedown")},c=function(e){var n;if(37===e.keyCode||39===e.keyCode||27===e.keyCode){if(37===e.keyCode){n=o-1;if(o-1>=0)r(i[n])&&t(i[o=n]);else{n=i.length-1;r(i[n])&&t(i[o=n])}}else 39===e.keyCode?(n=o+1)<i.length?r(i[n])&&t(i[o=n]):r(i[n=0])&&t(i[o=n]):i.disableLinkedMenu(e);e.preventDefault()}},r=function(e){if(e!==i[o])return!0},d=function(){if(r(this)){o=e.inArray(this,i);t(this)}},l=function(){var u=e.inArray(this,e(n.reflectFocus));r(i[u])&&t(i[o=u])};i.disableLinkedMenu=function(o){e(document).unbind("keypress",c);e(document).unbind("keydown",c);i.unbind("mouseover",d);e(document).unbind("mousedown",arguments.callee);n.reflectFocus&&e(n.reflectFocus).unbind("mouseover",l);u&&u();i.blur();delete e.currentLinkedMenu;window.setTimeout((function(){s=!1}),200)};t=(n=n||{}).focusElement||t;i.click((function(){var t,r;if(!s){e.currentLinkedMenu=i;if(n.onFocusRemoveClass){t=e(n.onFocusRemoveClass);if((r=n.onFocusRemoveClass.match(/\.([a-z]*)$/))&&r[1]&&t.length>0){e(n.onFocusRemoveClass).removeClass(r[1]);u=function(){e(t).addClass(r[1])}}}s=!0;o=e.inArray(this,i);i.mouseover(d);e.browser.mozilla?e(document).keypress(c):e(document).keydown(c);e(document).mousedown(i.disableLinkedMenu);n.reflectFocus&&e(n.reflectFocus).mouseover(l)}}));return i}}(jQuery);