require(["jquery","wrm/context-path","jira/dialog/form-dialog2"],(function(e,t,o){"use strict";e((function(){var a="diagram",i="text",r=t();function n(e){return e===i?i:a}function l(t){e.ajax({url:r+"/rest/api/2/mypreferences?key=workflow-mode",type:"PUT",contentType:"application/json",dataType:"json",data:n(t)})}var s=e(".workflow-view-toggle");e(document).on("click",".workflow-view-toggle",(function(t){t.preventDefault();var o,a=e(this);if(!a.hasClass("active")){l(o=n(a.data("mode")));!function(t){var o=e("#workflow-"+t);if(!o.hasClass("active")){s.each((function(){var t=e(this);o.is(t)?t.addClass("active"):t.removeClass("active")}));e(".workflow-view").addClass("hidden");e(o.attr("href")).removeClass("hidden").trigger(e.Event("show"));e(document.documentElement).css("overflow-y","")}}(o)}}));s.length||l(e("#jwd").length>0?a:i);new o({id:"edit-workflow-dialog",trigger:"#edit-workflow-trigger"})}))}));