require(["jira/util/formatter","aui/inline-dialog","aui/message","wrm/context-path","jquery"],(function(e,t,i,s,n){"use strict";var o=s();n((function(){n("#show-services").click((function(e){e.preventDefault();var t=document.getElementById("builtinServices"),i=document.getElementById("builtinServicesArrow");if("none"===t.style.display){t.style.display="";i.src=o+"/images/icons/navigate_down.gif"}else{t.style.display="none";i.src=o+"/images/icons/navigate_right.gif"}}));n(".set-service").click((function(e){e.preventDefault();n("#serviceClass").val(n(this).attr("data-service-type"));n("#serviceName").focus()}));var s=n(".obsolete-settings-hover");if(s.length>0){new t(s,"obsolete-settings-popup",(function(e,t,i){e.html(n("#obsolete-settings-message").html());i()}),{width:450,onHover:!0,onTop:!0,hideDelay:0});i.warning(n("#obsolete-settings-warning"),{body:e.I18n.getText("jmp.viewservices.obsolete.options"),shadowed:!1,closeable:!1})}}))}));