define("jira/field/init-priority-pickers",["jira/ajs/select/single-select","jira/util/events/reasons","jira/util/events/types","jira/util/events","jira/searchers/element/priority-picker-options","jquery"],(function(e,i,t,r,n,a){"use strict";r.bind(t.NEW_CONTENT_ADDED,(function(t,r,s){s!==i.panelRefreshed&&(l=r).find("select#priority").each((function(i,t){var r={element:t,revertOnInvalid:!0},s=a.attr(t,"aria-label");s&&(r.ariaLabel=s);if(t.dataset.useRestEndpoint){var o=function(e,i,t){var r=e.find(".project-field, .project-field-readonly");return r.length>1?r.eq(t-1).val():i.dataset.projectId}(l,t,i);o&&(r.baseAjaxOptions={projectIds:o});new e(n(r))}else new e(r)}));var l}))}));