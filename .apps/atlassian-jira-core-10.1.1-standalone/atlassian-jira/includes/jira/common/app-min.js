!function(){"use strict";var e=require("jquery"),t=require("aui/params"),i=require("aui/inline-dialog"),a=require("aui/tabs"),n=require("jira/toggleblock/toggle-block"),r=require("jira/ajs/browser/describe-browser"),o=require("jira/issue"),s=require("jira/message"),l=require("jira/data/cookie"),d=require("jira/util/forms"),c=require("jira/util/formatter"),u=require("jira/util/data/meta"),g=require("jira/util/events"),f=require("jira/util/navigator"),h=require("jira/skate"),m=require("jira/util/strings"),p=require("wrm/context-path")(),v=e(document);function b(){var t=function(){e('[name="timetracking_targetsubfield"]').length&&e("#cbtimetracking").attr("checked",!!e('[name="timetracking_targetsubfield"]:checked').length)};e("#availableActionsTable tr.availableActionRow").children("td:last-child").find(":input").change((function(){!function(i){e(i).closest(".availableActionRow").find("td:first :checkbox").attr("checked",!0);"timetracking_targetsubfield"===i.name&&t()}(this)}));["originalestimate","remainingestimate"].forEach((function(t){var i=e("#timetracking_"+t+"_subfield");e("#timetracking_"+t).change((function(){i.attr("checked",!0)}))}));e("form#bulkedit").submit(t)}function w(){e("#availableActionsTable .availableActionRowMultiSelect").children("td:last-child").find(":input").change((function(){e(this).closest("tr").prev().find("td:first :checkbox").attr("checked",!0)}))}h("shared-item-trigger",{type:h.type.CLASSNAME,attached:function(t){var a=t.getAttribute("href");new i(t,a.substring(1),(function(t,i,n){t.html(e(a).html());n()}),{width:240})}});e((function(){!function(){new n({blockSelector:".twixi-block",storageCollectionName:"twixi"}).addCallback("toggle",(function(){o.getStalker().trigger("stalkerHeightUpdated")})).addTrigger(".action-head .action-details","click");new n({blockSelector:"#issue-filter .toggle-wrap:not(#navigator-filter-subheading-textsearch-group)",triggerSelector:".toggle-trigger",collapsedClass:"expanded",expandedClass:"collapsed",storageCollectionName:"navSimpleSearch"});new n({blockSelector:".twixi-block",triggerSelector:".twixi-trigger",storageCollectionName:"twixi"});new n({blockSelector:"#issuenav",triggerSelector:"a.toggle-lhc",collapsedClass:"lhc-collapsed",storageCollectionName:"lhc-state",autoFocusTrigger:!1});e(".error","#issue-filter").parents(".toggle-wrap").removeClass("collapsed").addClass("expanded");e("fieldset.content-toggle input[type='radio']").live("change",(function(){var t=e(this);t.closest(".content-toggle").find("input[type='radio']").each((function(){var t=e(this);e("#"+t.attr("name")+"-"+t.val()+"-content").addClass("hidden")}));e("#"+t.attr("name")+"-"+t.val()+"-content").removeClass("hidden")}))}();e("label.overlabel").overlabel();!function(){var t=e("div.results"),i=t.width();t.bind("resultsWidthChanged",(function(){e(this).css("width",100/i*(i-(parseInt(e(document.documentElement).prop("scrollWidth"),10)-e(window).width()))+"%")}));e(window).resize((function(){t.trigger("resultsWidthChanged")}));t.trigger("resultsWidthChanged");e("#issuenav").bind("contractBlock expandBlock",(function(){e(".results").trigger("resultsWidthChanged")}))}();e(".fieldTabs li").click((function(t){t.preventDefault();t.stopPropagation();var i=e(this);if(!i.hasClass("active")){e(".fieldTabs li.active").removeClass("active");i.addClass("active");e(".fieldTabArea.active").removeClass("active");e("#"+i.attr("rel")).addClass("active")}}));!function(){e("form").handleAccessKeys();v.bind("dialogContentReady",(function(){e("form",this.$content).handleAccessKeys({selective:!1})}))}();!function(){e("#log-work-adjust-estimate-new-value,#log-work-adjust-estimate-manual-value").attr("disabled","disabled");e("#log-work-adjust-estimate-"+e("input[name=worklog_adjustEstimate]:checked,input[name=adjustEstimate]:checked").val()+"-value").removeAttr("disabled");e("input[name=worklog_adjustEstimate],input[name=adjustEstimate]").change((function(){e("#log-work-adjust-estimate-new-value,#log-work-adjust-estimate-manual-value").attr("disabled","disabled");e("#log-work-adjust-estimate-"+e(this).val()+"-value").removeAttr("disabled")}))}();!function(){var t=e("input:checked");if(0!==t.length)if("forgot-login-rb-forgot-password"===t.attr("id")){e("#username,#password").addClass("hidden");e("#password").removeClass("hidden")}else if("forgot-login-rb-forgot-username"===t.attr("id")){e("#username,#password").addClass("hidden");e("#username").removeClass("hidden")}e("#forgot-login-rb-forgot-password").change((function(){e("#username,#password").addClass("hidden");e("#password").removeClass("hidden")}));e("#forgot-login-rb-forgot-username").change((function(){e("#username,#password").addClass("hidden");e("#username").removeClass("hidden")}))}();e("input.upfile").each((function(){var t=e(this),i=t.closest(".field-group");t.change((function(){t.val().length>0&&i.next(".field-group").removeClass("hidden")}))}));!function(){v.on("keydown","textarea",d.submitOnCtrlEnter);e("#jqltext").keypress(d.submitOnEnter)}();a=e("#browser-warning"),e(".aui-close-button",a).click((function(){a.slideUp("fast");l.save("UNSUPPORTED_BROWSER_WARNING","handled")}));var a,r,s,c;e("form").submit((function(t){var i=new e.Event("before-submit");e(this).trigger(i);i.isDefaultPrevented()&&t.preventDefault()}));!function(){var t="#comment, #environment, #description";v.bind("tabSelect",(function(e,i){i.pane.find(t).expandOnInput()}));e(t).expandOnInput(200);v.bind("dialogContentReady",(function(e,i){i.get$popupContent().bind("tabSelect",(function(e,i){i.pane.find(t).expandOnInput(200)})).find(t).expandOnInput(200)}));v.bind("showWikiInput",(function(e,i){i.find(t).expandOnInput()}))}();r=e("form.aui"),s=e("a.cancel",r),f.isIE()&&f.majorVersion()<12&&s.attr("accessKey")&&s.focus((function(t){if(t.altKey){e(this).mousedown();window.location.href=s.attr("href")}}));b();w();e("#availableActionsTable .availableActionMultiSelect select").change((function(){var t=e(this);t.closest("tr").next().toggleClass("hidden","removeall"===t.val())}));v.keydown((function(t){i.current&&27===t.which&&!e(t.target).is(":input")&&i.current.hide()}));!function(){if(t.showmonitor){var a=e("<div class='perf-monitor'/>"),n=t["jira.request.server.time"]>2e3,r=t.jiraSQLstatements>50;n&&a.addClass("tooslow");r&&a.addClass("toomanysql");e("#header-top").append(a);new i(a,"perf-monitor-dialog",(function(e,i,a){var n="<div>Page render time <strong>"+t["jira.request.server.time"]+" ms</strong>";if(t.jiraSQLstatements){n+=" / SQL <strong>"+t.jiraSQLstatements+"@"+t.jiraSQLtime+" ms</strong></br>";n+='<a target="_blank" href='+p+"/sqldata.jsp?requestId="+t["jira.request.id"]+">More...</a>"}else n+=" / No SQL statments";n+="</div>";e.empty().append(n);a()}))}}();e(".clickable").click((function(){window.location.href=e(this).find("a").attr("href")}));v.on("click","[data-helplink=local]",(function(e){var t=this.getAttribute("href"),i=window.open(t,"jiraLocalHelp");i&&i.focus();e.preventDefault();return!1}));!function(){var t="jiraTooltipInitialized",i=function(i){return function(a){var n=e(a);if(!i||n.is(i)){n.tooltip();a[t]=!0}}},a=function(i){if(i[t]){delete i[t];var a=e(i);a.tooltip&&a.tooltip("destroy")}};h("help-lnk",{type:h.type.CLASSNAME,attached:i("a[title]"),detached:a});h("grouppicker-trigger",{type:h.type.CLASSNAME,attached:i("[title]"),detached:a});h("popup-trigger",{type:h.type.CLASSNAME,attached:i("[title]"),detached:a})}();e(".projects-list-trigger",c).each((function(){var t=e(this);t.click(!1);var a=t.attr("href");new i(this,a.substring(1),(function(t,i,n){t.html(e(a).html());n()}),{onHover:!0,hideDelay:500,width:240})}))}));r();g.bind("dialogContentReady",(function(){a.setup()}));h("js-filter-form-edit",{type:h.type.CLASSNAME,extends:"form",events:{submit:function(e,t){if(!t.defaultPrevented){var i=m.escapeHtml(e.elements.filterName.value);s.showMsgOnReload(c.I18n.getText("editfilter.save.success",i),{type:"SUCCESS",closeable:!0,target:"body:not(:has(#edit-entity))"})}}}});h("js-filter-form-subscription",{type:h.type.CLASSNAME,extends:"form",events:{submit:function(e,t){if(!t.defaultPrevented){var i=e.elements.groupName.value||u.get("remote-user-fullname");s.showMsgOnReload(c.I18n.getText("subscriptions.add.success",m.escapeHtml(i)),{type:"SUCCESS",closeable:!0,target:"body:not(:has(#filter-subscription))"})}}}})}();