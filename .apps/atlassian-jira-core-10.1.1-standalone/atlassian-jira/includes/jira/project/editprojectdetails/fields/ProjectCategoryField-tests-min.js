AJS.test.require(["jira.webresources:edit-project-details"],(function(){"use strict";var e=require("jquery"),t=require("underscore"),i=require("jira/project/edit/project-category-field"),o=["a","b","c","d"];module("JIRA.Project.ProjectTypeField",{setup:function(){this.$field=e(function(){var e='<div><select class="select" name="projectCategoryId" id="project-category-selector">';t.each(o,(function(t){e+='<option value="'+t+'">'+t+"</option>"}));return e+="</select></div>"}());e("#qunit-fixture").append(this.$field);new i({el:this.$field});this.changeProjectCategory=function(t){this.$field.find(".drop-menu").click();e("#projectTypeKey-suggestions").find("li.aui-list-item-li-"+t).click()}},teardown:function(){e("#project-category-selector-suggestions").parent().remove()}});test("Converts the project type select to a SingleSelect",(function(){ok(this.$field.find("#project-category-selector-field"),"Should have created it's own single select field");ok(this.$field.find("#project-category-selector").hasClass("aui-ss-select"),"Should have modified the original select box")}))}));