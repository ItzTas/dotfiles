define("jira/searchers/element/version-sparkler",["jira/ajs/select/checkbox-multi-select","jira/searchers/element/version-picker-options","jira/skate","jira/searchers/element/common-pickers-utils"],(function(e,r,s,t){"use strict";return s("js-default-checkboxmultiselectversion",{type:s.type.CLASSNAME,created:function(s){var i={element:s,content:"mixed",baseAjaxOptions:{projectIds:t.getSelectedProjectsIds(),useIdPrefixInValue:!0}};new e(r(i))}})}));require(["jira/searchers/element/version-sparkler"]);