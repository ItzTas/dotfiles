require(["jquery","jira/util/init-on-dcl","jira/util/urls"],(function(t,n,i){"use strict";function e(n){var e=t("#start-reindex"),r="atl_token="+i.atl_token(),a="indexingStrategy="+n.attr("value");e.attr("href",n.attr("boundAction")+"?"+r+"&"+a);"true"===n.attr("continueInDialog")?e.addClass("trigger-dialog"):e.removeClass("trigger-dialog")}n((function(){var n=t("input[type=radio][name=indexingStrategy]");n.on("change",(function(){e(t(this))}));n.attr("changeHandlerBound","1");e(t("input[type=radio][checked]"))}))}));