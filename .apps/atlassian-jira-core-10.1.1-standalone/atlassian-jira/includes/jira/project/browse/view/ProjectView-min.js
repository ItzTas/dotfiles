define("jira/project/browse/projectview",["jquery","jira/marionette-4.1","jira/util/data/meta","jira/moment","wrm/context-path","aui/flag","jira/ajs/ajax/ajax-util","jira/dialog/form-dialog2"],(function(e,t,r,a,i,o,c,l){"use strict";return t.View.extend({template:JIRA.Templates.Project.Browse.projectRow,templateContext:function(){var e={isAdminMode:r.get("in-admin-mode"),archivingEnabled:r.get("archiving-enabled")},t=this.model.get("archivedTimestamp");t&&(e.archivedDate=a(t).format("Do MMM YYYY"));var i=this.model.get("lastUpdatedTimestamp");i&&(e.lastUpdatedDate=a(i).format("Do MMM YYYY"));return e},ui:{name:"td.cell-type-name a",leadUser:"td.cell-type-user a",category:"td.cell-type-category a",url:"td.cell-type-url a",archive:".aui-list-truncate li a.archive-project",restore:".aui-list-truncate li a.restore-project"},triggers:{"click @ui.name":{event:"project-view.click-project-name",preventDefault:!1},"click @ui.leadUser":{event:"project-view.click-lead-user",preventDefault:!1},"click @ui.category":{event:"project-view.click-category"},"click @ui.url":{event:"project-view.click-url",preventDefault:!1}},onRender:function(){this.unwrapTemplate();this.ui.archive.on("click",this.archiveProject.bind(this));this.ui.restore.on("click",this.restoreProject.bind(this))},archiveProject:function(e){var t=this;e.preventDefault();new l({id:"".concat(e.target.id,"-dialog"),refreshOnSubmit:!1,ajaxOptions:{url:e.target.href,data:{decorator:"dialog",inline:!0}},onSuccessfulSubmit:function(){t.model.trigger("destroy",t.model)}}).show()},restoreProject:function(t){var r=this;t.preventDefault();var a=this.model.get("key");e.ajax({url:i()+"/rest/api/2/project/".concat(a,"/restore"),type:"PUT",dataType:"text"}).success((function(){r.model.trigger("destroy",r.model);o({type:"success",close:"manual",body:JIRA.Templates.Project.Browse.restoreSuccessFlag({projectKey:a})})})).error((function(e){var t=c.getErrorMessageFromXHR(e);o({type:"error",close:"manual",body:t})}))}})}));