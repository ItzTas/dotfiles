!function(){"use strict";var e=require("jquery"),i=require("wrm/data"),s=function(i){if(void 0!==i.issuePickerSelect&&void 0!==i.issuePickerSelect.issuePicker){this.issuePickerSelect=i.issuePickerSelect;this.issuePicker=this.issuePickerSelect.issuePicker;this.parentContainerSelector=i.parentContainerSelector;this.subtaskIds=i.subtaskIds;var s=this.issuePickerSelect,t=this.issuePicker,r=this.subtaskIds,c=e(this.issuePickerSelect).closest(this.parentContainerSelector).find("input.project-field"),n=e(this.issuePickerSelect).closest(this.parentContainerSelector).find("input.issuetype-field");1===c.length&&c.change((function(){t.clear();t.setCurrentProjectId(c.val())}));if(1===n.length){n.change((function(){var i=e(s).closest("tr");if(!0===(-1!==r.indexOf(n.val()))){i.show();t.setCurrentProjectId(c.val())}else i.hide()}));n.change()}}e(s).addClass("bound-to-project-issuetype")},t=i.claim("jira.core:jira-bulk-edit-data.subtaskIds")||[];e((function(){e((i=".be-project-type-issue")+" .aui-field-singleissuepicker").each((function(){new s({issuePickerSelect:this,parentContainerSelector:i,subtaskIds:t})}));var i}))}();