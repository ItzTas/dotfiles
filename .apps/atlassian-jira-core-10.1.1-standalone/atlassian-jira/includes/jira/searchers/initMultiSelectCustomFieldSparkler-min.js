define("jira/searchers/element/multi-select-custom-field-sparkler",["jira/ajs/select/checkbox-multi-select","jira/searchers/element/common-pickers-utils","jira/searchers/element/multi-select-custom-field-picker-options","jira/skate"],(function(e,t,s,r){"use strict";return r("js-default-checkboxmultiselect-custom-field",{type:r.type.CLASSNAME,created:function(r){var c={element:r,content:"mixed",baseAjaxOptions:{customFieldId:parseInt(r.dataset.customFieldId,10),projectIds:t.getSelectedProjectsIds(),issueTypeIds:t.getSelectedIssueTypeIds()}},i=r.getAttribute("aria-label");i&&(c.ariaLabel=i);new e(s(c))}})}));require(["jira/searchers/element/multi-select-custom-field-sparkler"]);