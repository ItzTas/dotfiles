define("jira/field/init-inline-attach",["jira/util/events","jira/util/events/types","jira/util/events/reasons","jquery","jira/jquery/plugins/attachment/inline-attach"],(function(i,n,t){"use strict";i.bind(n.NEW_CONTENT_ADDED,(function(i,n,e){e!==t.panelRefreshed&&function(i){i.find("input[type=file]:not('.ignore-inline-attach')").inlineAttach()}(n)}))}));