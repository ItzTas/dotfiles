define("jira/project/browse/projectcollectionview",["jquery","jira/backbone.radio-2.0","jira/marionette-4.1","jira/util/users/logged-in-user","jira/util/data/meta","jira/project/browse/projectview","jira/project/project-type-keys","jira/project/browse/projects-empty-view","jira/project/browse/projects-empty-view-with-action","jira/project/browse/archived-projects-empty-view","jira/util/formatter"],(function(e,t,i,r,o,s,c,n,a,l,d){"use strict";return i.CollectionView.extend({template:JIRA.Templates.Project.Browse.projects,templateContext:function(){return{isAdmin:r.isSysadmin()||r.isAdmin(),isAdminMode:o.get("in-admin-mode")}},events:{"click th.sortable button":function(t){this._sort(e(t.currentTarget).data("sort-key"))}},childView:s,childViewContainer:"tbody",childViewEvents:{"project-view.click-project-name":function(e){var t=e.model,i=this.collection.indexOf(t);this.trigger("project-view.click-project-name",t,i);this.analyticsChannel.trigger("browse-projects.project-view.click-project-name",t,i)},"project-view.click-lead-user":function(e){var t=e.model,i=this.collection.indexOf(t);this.trigger("project-view.click-lead-user",t,i);this.analyticsChannel.trigger("browse-projects.project-view.click-lead-user",t,i)},"project-view.click-category":function(e){var t=e.model,i=this.collection.indexOf(t);this.triggerMethod("project-view.click-category",t,i);this.analyticsChannel.trigger("browse-projects.project-view.click-category",t,i)},"project-view.click-url":function(e){var t=e.model,i=this.collection.indexOf(t);this.trigger("project-view.click-url",t,i);this.analyticsChannel.trigger("browse-projects.project-view.click-url",t,i)}},emptyViewOptions:function(){return{filters:this.model,hasArchivedProjects:this.hasArchivedProjects()}},emptyView:function(){return this.hasArchivedProjects()||"archived"!==this.model.get("category").id?this.shouldUseCallToActionTemplate()?a:n:l},initialize:function(){this.analyticsChannel=t.channel("browse-projects-analytics")},onRender:function(e){this.unwrapTemplate();e.$el&&this._recoverFocusOnRender(e.$el)},_getTranslationColumn:function(e){switch(e){case"name":return d.I18n.getText("common.concepts.project");case"key":return d.I18n.getText("common.concepts.key");case"projectTypeName":return d.I18n.getText("browseprojects.project.type");case"lead":return d.I18n.getText("browseprojects.project.lead");case"projectCategoryId":return d.I18n.getText("browseprojects.project.category");case"archivedTimestamp":return d.I18n.getText("browseprojects.archived.date");case"archivedBy":return d.I18n.getText("browseprojects.archived.by");case"lastUpdatedTimestamp":return d.I18n.getText("browseprojects.updated.date");case"issueCount":return d.I18n.getText("browseprojects.issue.count");default:return!1}},_createAssistiveRegion:function(e){return JIRA.Templates.Project.Browse.assistiveRegion({ariaLiveText:e})},_getAssistiveRegionText:function(){return document.querySelector("#assistive-text")},_removeAssistiveRegionText:function(){var e=document.querySelectorAll("#assistive-text");e&&e.forEach((function(e){e.remove()}))},_updateAssistiveRegion:function(e,t){this._removeAssistiveRegionText();var i=document.getElementById("assistive-projects");if(i){var r=this._getTranslationColumn(e);if(r){i.insertAdjacentHTML("beforeend",this._createAssistiveRegion(d.I18n.getText("common.concepts.sort.region",r,t)));var o=this._getAssistiveRegionText();o&&setTimeout((function(){o.remove()}),1e3)}}},_recoverFocusOnRender:function(t){var i=e(t).find("th.sortable.active button");i&&i.focus()},_sort:function(e){if("ascending"===this.model.get("sortOrder")&&this.model.get("sortColumn")===e)this.model.set("sortOrder","descending");else{this.model.set("sortOrder","ascending");this.model.set("sortColumn",e)}this.collection.updateSorting(e,this.model.get("sortOrder"));this.trigger("sorted",e,this.model.get("sortOrder"));this._updateAssistiveRegion(e,this.model.get("sortOrder"));this.render()},hasArchivedProjects:function(){return!!this.model.filterByCategory("archived",this.collection.originalCollection).length},shouldUseCallToActionTemplate:function(){var e=[c.SOFTWARE,c.SERVICE_DESK,c.BUSINESS];return this.model.get("projectType")&&"all"===this.model.get("category").id&&""===this.model.get("contains")&&-1!==e.indexOf(this.model.get("projectType").key)}})}));