define("jira/project/admin/change-project-type-dialog",["jira/util/formatter","jquery","underscore","jira/analytics","jira/message","jira/ajs/select/single-select","wrm/context-path"],(function(e,t,o,n,a,r,c){"use strict";function p(r){var p=t(".project-type-select",r.dialogBody).val()[0],d=o.findWhere(r.projectTypes,{key:p});t(".dialog-change-button",r.dialogBody).attr("disabled","disabled");t(t.ajax({url:c()+"/rest/api/2/project/"+r.projectId+"/type/"+p,dataType:"json",contentType:"application/json",type:"PUT"}).done((function(){r.changeProjectTypeDialog.hide();r.onProjectTypeChanged&&r.onProjectTypeChanged(r.trigger,d);a.showSuccessMsg(JIRA.Templates.project.ChangeType.successMsg({projectName:r.projectName,projectTypeName:d.formattedKey}));n.send({name:"administration.projecttype.change",properties:{projectId:r.projectId,sourceProjectType:i(r.sourceProjectType),destinationProjectType:i(p)}})})).fail((function(){t(".aui-dialog2-content",r.dialogBody).prepend(aui.message.error({content:e.I18n.getText("admin.projects.change.project.type.error",'<a href="https://support.atlassian.com/">',"</a>")}))}))).throbber({target:t(".throbber",r.dialogBody)})}function i(e){return e&&e.replace("_","")}function d(e,t,o){e==t?o.find(".dialog-change-button").attr("disabled","disabled"):o.find(".dialog-change-button").removeAttr("disabled")}function s(o){var n=t(JIRA.Templates.project.ChangeType.changeProjectTypeDialog({projectId:o.projectId})),a=AJS.dialog2(n);a.on("show",(function(){t(".aui-dialog2-content",n).html(JIRA.Templates.project.ChangeType.dialogSpinner());t(".dialog-spinner",n).spin();t(".dialog-change-button",n).unbind("click").addClass("hidden")}));t(o.trigger).click((function(i){i.preventDefault();a.show();(s=o.projectId,t.ajax({url:c()+"/rest/internal/2/projects/"+s+"/changetypedata",dataType:"json",contentType:"application/json",type:"GET"})).done((function(e){n.find(".aui-dialog2-content").html(JIRA.Templates.project.ChangeType.changeProjectTypeForm(e));new r({element:t(".project-type-select",n),revertOnInvalid:!0,width:165});n.find(".dialog-change-button").removeClass("hidden");d(t(".project-type-select",n).val(),e.project.projectTypeKey,n);var c={dialogBody:n,changeProjectTypeDialog:a,projectName:e.project.name,projectTypes:e.projectTypes,trigger:o.trigger,projectId:o.projectId,onProjectTypeChanged:o.onProjectTypeChanged,sourceProjectType:e.project.projectTypeKey};t(".dialog-change-button",n).click((function(e){e.preventDefault();p(c)}));t(".change-project-type-form",n).on("submit",(function(e){e.preventDefault();p(c)}));t(".project-type-select",n).on("change",(function(){d(t(this).val(),e.project.projectTypeKey,n)}))})).fail((function(){t(".aui-dialog2-content",n).html(aui.message.error({content:e.I18n.getText("admin.projects.change.project.type.data.error",'<a href="https://support.atlassian.com/">',"</a>")}))}));var s}));t(".dialog-close-button",n).click((function(e){e.preventDefault();a.hide()}))}return function(e){s(e)}}));